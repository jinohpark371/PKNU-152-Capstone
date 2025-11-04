# auth_worker.py
import time, queue, numpy as np
from dataclasses import dataclass, field
from typing import Optional, List, Tuple, Dict

@dataclass
class PipelineData:
    frame: Optional[np.ndarray] = None
    face_vectors: List[List[float]] = field(default_factory=list)
    bbox_coords: List[Tuple[int,int,int,int]] = field(default_factory=list)
    current_user_id: Optional[int] = None
    is_calibration_needed: bool = False
    current_posture_status: str = "unknown"

webcam_to_feature_queue = queue.Queue(maxsize=1)
feature_to_auth_queue  = queue.Queue(maxsize=1)
auth_to_engine_queue   = queue.Queue(maxsize=1)

#DB가 아닌 메모리로 저장중 (나중에 바꿔야함)
class InMemoryUserStore:
    def __init__(self):
        self.user_embs: Dict[int, List[np.ndarray]] = {}
        self.next_id = 1
    def next_user_id(self) -> int:
        uid = self.next_id; self.next_id += 1; return uid
    def add_embedding(self, uid: int, emb: np.ndarray):
        self.user_embs.setdefault(uid, []).append(emb.astype(np.float32))
    def all(self) -> Dict[int, List[np.ndarray]]:
        return self.user_embs

def l2n(v: np.ndarray) -> np.ndarray:
    v = v.astype(np.float32); n = np.linalg.norm(v) + 1e-9; return v / n
def cos(a: np.ndarray, b: np.ndarray) -> float:
    return float(np.dot(a,b)/((np.linalg.norm(a)+1e-9)*(np.linalg.norm(b)+1e-9)))

class AuthWorker:
    def __init__(self,
                 in_q: queue.Queue,
                 out_q: queue.Queue,
                 absence_threshold_sec: int = 10,
                 match_thr: float = 0.63,
                 enroll_thr: float = 0.40,
                 unknown_streak_for_enroll: int = 15,
                 samples_per_user: int = 4,
                 store: Optional[InMemoryUserStore] = None,
                 calib_frames: int = 2):   #캘리브레이션 신호 유지 프레임 수
        self.in_q = in_q
        self.out_q = out_q
        self.absent_thr = absence_threshold_sec
        self.MATCH_THR = match_thr
        self.ENROLL_THR = enroll_thr
        self.N_STREAK = unknown_streak_for_enroll
        self.N_SAMPLES = samples_per_user
        self.store = store or InMemoryUserStore()
        self.CALIB_FRAMES = max(1, int(calib_frames))

        self.current_user_id: Optional[int] = None
        self.last_seen_ts = 0.0
        self.unknown_streak = 0
        self.enrolling = False
        self.enroll_uid: Optional[int] = None
        self.enroll_buf: List[np.ndarray] = []
        self._calib_left = 0

    def _best_match(self, emb: np.ndarray) -> Tuple[Optional[int], float]:
        best_uid, best_sim = None, -1.0
        for uid, embs in self.store.all().items():
            if not embs: continue
            s = max(cos(emb, e) for e in embs)
            if s > best_sim:
                best_sim, best_uid = s, uid
        return (best_uid if best_sim >= self.MATCH_THR else None), best_sim

    def _start_enroll(self):
        self.enrolling = True
        self.enroll_uid = self.store.next_user_id()
        self.enroll_buf = []
        print(f"[AUTH] 등록 시작 user_{self.enroll_uid}")

    def _commit_enroll(self):
        mean_emb = l2n(np.mean(np.stack(self.enroll_buf), axis=0))
        self.store.add_embedding(self.enroll_uid, mean_emb)
        print(f"[AUTH] 등록 완료 user_{self.enroll_uid} (샘플 {len(self.enroll_buf)})")
        self.current_user_id = self.enroll_uid
        self.last_seen_ts = time.time()
        self.unknown_streak = 0
        self.enrolling = False
        self.enroll_uid = None
        self.enroll_buf = []
        self._calib_left = self.CALIB_FRAMES
        return True

    def _put_latest(self, pdata: PipelineData):
        try: self.out_q.get_nowait()
        except queue.Empty: pass
        self.out_q.put_nowait(pdata)

    def run_forever(self, poll=0.2):
        print("[AUTH] start")
        while True:
            try:
                p: PipelineData = self.in_q.get(timeout=poll)
            except queue.Empty:
                # 부재 체크
                if self.current_user_id and (time.time() - self.last_seen_ts) > self.absent_thr:
                    print(f"[AUTH] 부재 user_{self.current_user_id}")
                    self.current_user_id = None
                    self._put_latest(PipelineData(current_user_id=None, is_calibration_needed=False))
                continue

            out = PipelineData(frame=p.frame)

            if not p.face_vectors:
                # 얼굴 없음 → 부재 전이
                if self.current_user_id and (time.time() - self.last_seen_ts) > self.absent_thr:
                    print(f"[AUTH] 부재 user_{self.current_user_id}")
                    self.current_user_id = None
                out.current_user_id = self.current_user_id
                out.is_calibration_needed = (self._calib_left > 0)
                if self._calib_left > 0: self._calib_left -= 1
                self._put_latest(out)
                continue

            # 가장 큰 얼굴 선택
            idx = 0
            if p.bbox_coords:
                areas = [(w*h) for (_,_,w,h) in p.bbox_coords]
                if areas: idx = int(np.argmax(areas))
            if idx >= len(p.face_vectors):
                print(f"[AUTH] 경고: BBox({len(p.bbox_coords)})와 FaceVec({len(p.face_vectors)}) 불일치 -> 스킵")
                out.current_user_id = self.current_user_id
                out.is_calibration_needed = (self._calib_left > 0)
                if self._calib_left > 0: self._calib_left -= 1
                self._put_latest(out)
                continue

            emb = l2n(np.array(p.face_vectors[idx], dtype=np.float32))

            # 등록 수집 중
            if self.enrolling:
                self.enroll_buf.append(emb)
                self.last_seen_ts = time.time()
                trig = False
                if len(self.enroll_buf) >= self.N_SAMPLES:
                    trig = self._commit_enroll()
                out.current_user_id = self.current_user_id
                out.is_calibration_needed = (self._calib_left > 0)
                if self._calib_left > 0: self._calib_left -= 1
                self._put_latest(out)
                continue

            # 매칭 시도
            uid, best_sim = self._best_match(emb)
            if uid is not None:
                trig = (uid != self.current_user_id) or ((time.time() - self.last_seen_ts) > self.absent_thr)
                self.current_user_id = uid
                self.last_seen_ts = time.time()
                self.unknown_streak = 0
                if trig:
                    print(f"[AUTH] 로그인/재인식 user_{uid} -> 캘리브레이션 (sim={best_sim:.3f})")
                    self._calib_left = self.CALIB_FRAMES
                out.current_user_id = uid
                out.is_calibration_needed = (self._calib_left > 0)
                if self._calib_left > 0: self._calib_left -= 1
                self._put_latest(out)
                continue

            # Unknown → 자동등록 후보
            self.unknown_streak += 1
            print(f"[AUTH] Unknown streak={self.unknown_streak} best_sim={best_sim:.3f}")
            if (self.unknown_streak >= self.N_STREAK):
                self._start_enroll()
                self.enroll_buf.append(emb)
                self.last_seen_ts = time.time()
                out.current_user_id = self.current_user_id
                out.is_calibration_needed = (self._calib_left > 0)
                if self._calib_left > 0: self._calib_left -= 1
                self._put_latest(out)
                continue

            # 유지
            out.current_user_id = self.current_user_id
            out.is_calibration_needed = (self._calib_left > 0)
            if self._calib_left > 0: self._calib_left -= 1
            self._put_latest(out)