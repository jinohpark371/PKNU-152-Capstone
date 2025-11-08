import threading, queue, time, cv2
import face_recognition
from pipeline_data import PipelineData
from dataclasses import dataclass, field
from typing import Optional, List, Tuple
import numpy as np


class WebcamModule:
    """
    작성: 김푸른들
    이중 스레드 웹캠 & 특징 추출 모듈이다.
    메인 스레드: 고속 프레임 캡쳐
    워커 스레드: ML 처리를 위한 프레임 전송
    """

    def __init__(self, camera_id=0, capture_fps=60, processing_fps=6, tracking_fps=60,
                 bbox_reduce_ratio=0.1, auto_brightness=False):
        """
        웹캠 모듈 초기화.

        :param camera_id: 카메라 장치 ID (기본값: 0)
        :param capture_fps: 디스플레이 스레드 목표 FPS (기본값: 60)
        :param processing_fps: ML 처리 프레임 전송 FPS (기본값: 6)
        :param tracking_fps: 바운딩 박스 추적 FPS (기본값: 60)
        :param bbox_reduce_ratio: 바운딩 박스 축소 비율 (기본값: 0.1, 10% 축소)
        :param auto_brightness: 자동 밝기 조정 활성화 (기본값: False)
        """
        # 카메라 설정
        self.cap = cv2.VideoCapture(camera_id)
        self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
        self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

        if not self.cap.isOpened():
            print(f"오류: 카메라 ID {camera_id}를 열 수 없습니다.")
            print("카메라가 연결되어 있는지, 다른 프로그램에서 사용 중이지 않은지 확인하세요.")
            raise cv2.error(f"카메라 {camera_id}를 열 수 없습니다.")

        # 목표 FPS 설정
        self.capture_fps = capture_fps
        self.processing_fps = processing_fps
        self.tracking_fps = tracking_fps

        # [△]실험실 기능 설정
        self.bbox_reduce_ratio = bbox_reduce_ratio  # 바운딩 박스 축소 비율
        self.auto_brightness = auto_brightness  # 자동 밝기 조정 활성화
        self.brightness_threshold = 80  # 밝기 임계값 (0~255, 80 미만이면 어두운 것으로 판단)

        # 스레드 간 공유 프레임 (최신 프레임만 유지)
        self.latest_frame = None
        self.frame_lock = threading.Lock()

        # 플러터 앱으로 전송할 큐 (JPEG 인코딩 프레임)
        self.frame_queue = queue.Queue(maxsize=2)

        # ML 파이프라인으로 전송할 큐
        self.output_queue = None

        # 스레드 제어 및 플래그
        self.running = False
        self.capture_thread = None
        self.processing_thread = None
        self.tracker = None

        # 동작 상태 관리
        self.processing_state = "RECOGNIZING"
        self.tracker = None
        self.state_lock = threading.Lock()
        self.pending_bbox_to_track = None

        # 테스트 모드 플래그
        self.test_mode = False

        # 하이브리드 추적 설정
        self.tracking_frame_count = 0
        self.redetection_interval = 10
        self.last_known_bbox = None
        self.tracked_face_encoding = None
        self.face_match_threshold = 0.6

    def get_latest_frame_jpeg(self):
        try:
            return self.frame_queue.get_nowait()
        except queue.Empty:
            return None

    def set_output_queue(self, output_queue):
        self.output_queue = output_queue

    def start(self):
        self.running = True

        self.capture_thread = threading.Thread(
            target=self._capture_and_encode_loop,
            name="WebcamCapture",
            daemon=True
        )
        self.capture_thread.start()

        self.processing_thread = threading.Thread(
            target=self._processing_loop,
            name="WebcamProcessing",
            daemon=True
        )
        self.processing_thread.start()

    def stop(self):
        self.running = False

        if self.capture_thread:
            self.capture_thread.join(timeout=1.0)
        if self.processing_thread:
            self.processing_thread.join(timeout=1.0)

        self.cap.release()

    def start_tracking_request(self, bbox: Tuple[int, int, int, int]):
        with self.state_lock:
            print(f"WebcamModule: 추적 시작 요청 수신 (BBox: {bbox})")
            self.pending_bbox_to_track = bbox
            self.processing_state = "START_TRACKING"

    def stop_tracking_request(self):
        with self.state_lock:
            print("WebcamModule: 추적 중지 요청 수신")
            self.processing_state = "RECOGNIZING"
            self.tracker = None
            self.pending_bbox_to_track = None
            self.tracking_frame_count = 0
            self.last_known_bbox = None
            self.tracked_face_encoding = None

    def enable_test_mode(self, enabled=True):
        print(f"WebcamModule: 테스트 모드 {'활성화' if enabled else '비활성화'}")
        self.test_mode = enabled

    def set_auto_brightness(self, enabled=True):
        """
        자동 밝기 조정 활성화/비활성화
        :param enabled: True이면 활성화, False이면 비활성화
        """
        self.auto_brightness = enabled
        print(f"WebcamModule: 자동 밝기 조정 {'활성화' if enabled else '비활성화'}")

    def _reduce_bbox(self, bbox: Tuple[int, int, int, int], ratio: float) -> Tuple[int, int, int, int]:
        """
        바운딩 박스를 중심을 유지하면서 축소합니다.

        :param bbox: (x, y, w, h) 형태의 바운딩 박스
        :param ratio: 축소 비율 (0.2 = 20% 축소)
        :return: 축소된 (x, y, w, h) 바운딩 박스
        """
        x, y, w, h = bbox

        # 축소할 크기 계산
        reduce_w = int(w * ratio / 2)  # 양쪽에서 줄일 너비
        reduce_h = int(h * ratio / 2)  # 위아래에서 줄일 높이

        # 새로운 바운딩 박스 계산 (중심 유지)
        new_x = x + reduce_w
        new_y = y + reduce_h
        new_w = w - (reduce_w * 2)
        new_h = h - (reduce_h * 2)

        # 최소 크기 보장 (너무 작아지지 않도록)
        new_w = max(new_w, 20)
        new_h = max(new_h, 20)

        return (new_x, new_y, new_w, new_h)

    def _adjust_brightness(self, frame: np.ndarray) -> Tuple[np.ndarray, bool]:
        """
        프레임의 밝기를 분석하고 필요시 조정합니다.

        :param frame: 입력 프레임 (BGR)
        :return: (조정된 프레임, 조정 여부)
        """
        # 그레이스케일 변환하여 평균 밝기 계산
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        avg_brightness = np.mean(gray)

        # 어두운 경우에만 조정
        if avg_brightness < self.brightness_threshold:
            # CLAHE (Contrast Limited Adaptive Histogram Equalization) 적용
            # 지역적으로 히스토그램 평활화를 수행하여 자연스러운 밝기 조정
            lab = cv2.cvtColor(frame, cv2.COLOR_BGR2LAB)
            l, a, b = cv2.split(lab)

            # CLAHE 적용 (밝기 채널에만)
            clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
            l = clahe.apply(l)

            # 채널 병합 및 BGR로 변환
            adjusted_lab = cv2.merge([l, a, b])
            adjusted_frame = cv2.cvtColor(adjusted_lab, cv2.COLOR_LAB2BGR)

            return adjusted_frame, True

        return frame, False

    def _capture_and_encode_loop(self):
        print("WebcamModule._capture_and_encode_loop(): Capture Thread 시작")

        frame_interval = 1.0 / self.capture_fps

        while self.running:
            start_time = time.time()

            ret, frame = self.cap.read()
            if not ret:
                time.sleep(0.1)
                continue

            # 자동 밝기 조정 적용 (활성화된 경우)
            if self.auto_brightness:
                frame, was_adjusted = self._adjust_brightness(frame)

            with self.frame_lock:
                self.latest_frame = frame.copy()

            _, jpeg_buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 80])
            jpeg_bytes = jpeg_buffer.tobytes()

            try:
                self.frame_queue.put(jpeg_bytes, block=False)
            except queue.Full:
                try:
                    self.frame_queue.get_nowait()
                    self.frame_queue.put(jpeg_bytes, block=False)
                except (queue.Empty, queue.Full):
                    pass

            elapsed = time.time() - start_time
            sleep_time = frame_interval - elapsed
            if sleep_time > 0:
                time.sleep(sleep_time)

        print("WebcamModule._capture_and_encode_loop(): Capture Thread 종료")

    def _processing_loop(self):
        print("WebcamModule._processing_loop(): Processing Thread 시작 (Background)")

        frame_interval = 1.0 / self.processing_fps

        while self.running:
            start_time = time.time()

            frame_to_process = None

            with self.frame_lock:
                if self.latest_frame is None:
                    time.sleep(0.01)
                    continue
                frame_to_process = self.latest_frame.copy()

            if frame_to_process is None:
                time.sleep(0.01)
                continue

            with self.state_lock:
                current_state = self.processing_state

            pipeline_data = PipelineData(frame=frame_to_process)

            if current_state == "START_TRACKING":
                with self.state_lock:
                    bbox = self.pending_bbox_to_track
                    self.pending_bbox_to_track = None

                if bbox is not None:
                    try:
                        x, y, w, h = bbox
                        x, y, w, h = int(x), int(y), int(w), int(h)
                        original_bbox = (x, y, w, h)

                        # 바운딩 박스 축소 적용
                        reduced_bbox = self._reduce_bbox(original_bbox, self.bbox_reduce_ratio)
                        x, y, w, h = reduced_bbox

                        print(f"  → BBox 축소: {original_bbox} → {reduced_bbox} ({self.bbox_reduce_ratio * 100:.0f}% 축소)")

                        # 얼굴 임베딩 저장 (원본 bbox 사용)
                        rgb_frame = cv2.cvtColor(frame_to_process, cv2.COLOR_BGR2RGB)
                        orig_x, orig_y, orig_w, orig_h = original_bbox
                        face_encodings = face_recognition.face_encodings(
                            rgb_frame,
                            [(orig_y, orig_x + orig_w, orig_y + orig_h, orig_x)]
                        )

                        if face_encodings:
                            self.tracked_face_encoding = face_encodings[0]
                            print(f"  → 추적 대상 얼굴 임베딩 저장 완료 (벡터 크기: {len(self.tracked_face_encoding)})")
                        else:
                            print("  ⚠️ 경고: 얼굴 임베딩 추출 실패 (추적은 계속됨)")
                            self.tracked_face_encoding = None

                        # 축소된 bbox로 트래커 초기화
                        self.tracker = cv2.legacy.TrackerCSRT_create()
                        success = self.tracker.init(frame_to_process, (x, y, w, h))

                        if success:
                            with self.state_lock:
                                self.processing_state = "TRACKING"
                            print(f"WebcamModule: 추적 시작 성공 (TRACKING 모드 진입) - 축소된 BBox: ({x},{y},{w},{h})")
                            self.last_known_bbox = reduced_bbox
                            self.tracking_frame_count = 0
                            pipeline_data.bbox_coords = [reduced_bbox]
                        else:
                            print("WebcamModule: 트래커 초기화 실패 (init 반환값 False)")
                            with self.state_lock:
                                self.processing_state = "RECOGNIZING"
                                self.tracker = None

                    except Exception as e:
                        print(f"WebcamModule: 트래커 초기화 실패: {e}")
                        print(f"  - BBox 값: {bbox}")
                        print(f"  - Frame shape: {frame_to_process.shape}")
                        with self.state_lock:
                            self.processing_state = "RECOGNIZING"
                            self.tracker = None
                else:
                    with self.state_lock:
                        self.processing_state = "RECOGNIZING"

            elif current_state == "TRACKING":
                self.tracking_frame_count += 1

                if self.tracking_frame_count % self.redetection_interval == 0:
                    print(f"\n{'=' * 60}")
                    print(f"WebcamModule: 주기적 재감지 수행 (프레임 {self.tracking_frame_count})")
                    print(f"{'=' * 60}")

                    rgb_frame = cv2.cvtColor(frame_to_process, cv2.COLOR_BGR2RGB)
                    face_locations = face_recognition.face_locations(rgb_frame)

                    if face_locations:
                        print(f"  → {len(face_locations)}개의 얼굴 감지됨")

                        face_encodings = face_recognition.face_encodings(rgb_frame, face_locations)

                        best_match = None
                        best_encoding = None
                        min_distance = float('inf')
                        best_face_distance = None
                        best_iou = 0.0

                        for idx, ((top, right, bottom, left), encoding) in enumerate(
                                zip(face_locations, face_encodings)):
                            x, y = int(left), int(top)
                            w, h = int(right - left), int(bottom - top)
                            detected_bbox = (x, y, w, h)

                            # IoU 계산
                            iou = 0.0
                            if self.last_known_bbox:
                                # 축소된 bbox와 비교하므로 원본 크기로 복원하여 비교
                                expanded_last_bbox = self._expand_bbox(self.last_known_bbox, self.bbox_reduce_ratio)
                                iou = self._calculate_iou(expanded_last_bbox, detected_bbox)

                            # 얼굴 임베딩 거리 계산
                            face_distance = None
                            if self.tracked_face_encoding is not None:
                                face_distance = face_recognition.face_distance([self.tracked_face_encoding], encoding)[
                                    0]

                            # 복합 점수 계산
                            if face_distance is not None:
                                face_similarity = 1.0 - face_distance
                                combined_score = (iou * 0.4) + (face_similarity * 0.6)
                                distance = 1 - combined_score
                            else:
                                distance = 1 - iou

                            print(f"  얼굴 #{idx + 1}: BBox={detected_bbox}")
                            print(f"    - IoU: {iou:.3f}")
                            if face_distance is not None:
                                print(f"    - 얼굴 거리: {face_distance:.3f} (임계값: {self.face_match_threshold})")
                                print(
                                    f"    - 매칭 여부: {'✓ 같은 사람' if face_distance < self.face_match_threshold else '✗ 다른 사람'}")
                            print(f"    - 종합 점수: {(1 - distance):.3f}")

                            if distance < min_distance:
                                min_distance = distance
                                best_match = detected_bbox
                                best_encoding = encoding
                                best_face_distance = face_distance
                                best_iou = iou

                        # 최종 판단
                        is_same_person = True
                        rejection_reason = None

                        if best_iou < 0.1:
                            is_same_person = False
                            rejection_reason = f"위치 불일치 (IoU: {best_iou:.3f} < 0.1)"
                        elif best_face_distance is not None and best_face_distance > self.face_match_threshold:
                            is_same_person = False
                            rejection_reason = f"얼굴 불일치 (거리: {best_face_distance:.3f} > {self.face_match_threshold})"

                        print(f"\n  [최종 판정]")
                        if is_same_person and best_match:
                            print(f"  ✅ 동일 인물 확인")
                            print(f"    - 감지된 BBox (원본): {best_match}")

                            # 감지된 bbox를 축소하여 트래커에 전달
                            reduced_best_match = self._reduce_bbox(best_match, self.bbox_reduce_ratio)
                            print(f"    - 축소된 BBox: {reduced_best_match}")
                            print(f"    - IoU: {best_iou:.3f}")

                            if best_face_distance is not None:
                                print(f"    - 얼굴 거리: {best_face_distance:.3f}")
                            print(f"  → 트래커 재초기화 진행...")

                            try:
                                x, y, w, h = reduced_best_match
                                self.tracker = cv2.legacy.TrackerCSRT_create()
                                success = self.tracker.init(frame_to_process, (x, y, w, h))

                                if success:
                                    old_bbox = self.last_known_bbox
                                    self.last_known_bbox = reduced_best_match
                                    self.tracked_face_encoding = best_encoding
                                    pipeline_data.bbox_coords = [reduced_best_match]
                                    print(f"  ✓ 트래커 재초기화 성공")

                                    # 크기 변화 표시
                                    if old_bbox:
                                        old_w, old_h = old_bbox[2], old_bbox[3]
                                        size_change = ((w - old_w) / old_w * 100, (h - old_h) / old_h * 100)
                                        print(f"  📏 크기 변화: 너비 {size_change[0]:+.1f}%, 높이 {size_change[1]:+.1f}%")
                                else:
                                    print("  ✗ 트래커 재초기화 실패, 기존 추적 유지")
                                    success, bbox = self.tracker.update(frame_to_process)
                                    if success and bbox is not None:
                                        x, y, w, h = bbox
                                        bbox_int = (int(x), int(y), int(w), int(h))
                                        self.last_known_bbox = bbox_int
                                        pipeline_data.bbox_coords = [bbox_int]
                            except Exception as e:
                                print(f"  ✗ 재초기화 중 오류: {e}")
                                with self.state_lock:
                                    self.processing_state = "RECOGNIZING"
                                    self.tracker = None
                                    self.tracking_frame_count = 0
                        else:
                            print(f"  ❌ 다른 인물로 판단: {rejection_reason}")
                            print(f"  → 인식 모드로 복귀")
                            with self.state_lock:
                                self.processing_state = "RECOGNIZING"
                                self.tracker = None
                                self.tracking_frame_count = 0
                                self.tracked_face_encoding = None
                    else:
                        print("  ✗ 얼굴 미감지")
                        print("  → 인식 모드로 복귀")
                        with self.state_lock:
                            self.processing_state = "RECOGNIZING"
                            self.tracker = None
                            self.tracking_frame_count = 0
                            self.tracked_face_encoding = None

                    print(f"{'=' * 60}\n")
                else:
                    # 일반 추적 수행
                    success, bbox = self.tracker.update(frame_to_process)
                    if success and bbox is not None:
                        x, y, w, h = bbox
                        bbox_int = (int(x), int(y), int(w), int(h))
                        self.last_known_bbox = bbox_int
                        pipeline_data.bbox_coords = [bbox_int]
                    else:
                        print("WebcamModule: 추적 실패. (RECOGNIZING 모드 복귀)")
                        with self.state_lock:
                            self.processing_state = "RECOGNIZING"
                            self.tracker = None
                            self.tracking_frame_count = 0

            elif current_state == "RECOGNIZING":
                rgb_frame = cv2.cvtColor(frame_to_process, cv2.COLOR_BGR2RGB)

                face_locations_dlib = face_recognition.face_locations(rgb_frame)
                face_encodings = face_recognition.face_encodings(rgb_frame, face_locations_dlib)

                bboxes_cv2 = []
                largest_bbox_area = -1
                largest_bbox = None

                for (top, right, bottom, left), encoding in zip(face_locations_dlib, face_encodings):
                    x, y = int(left), int(top)
                    w, h = int(right - left), int(bottom - top)
                    cv2_bbox = (x, y, w, h)

                    bboxes_cv2.append(cv2_bbox)
                    pipeline_data.face_vectors.append(encoding.tolist())

                    area = w * h
                    if area > largest_bbox_area:
                        largest_bbox_area = area
                        largest_bbox = cv2_bbox

                pipeline_data.bbox_coords = bboxes_cv2

                if self.test_mode and largest_bbox:
                    print(f"WebcamModule (Test Mode): 가장 큰 얼굴 감지, 추적 시작")
                    self.start_tracking_request(largest_bbox)

            if self.output_queue is not None:
                try:
                    self.output_queue.put(pipeline_data, block=False)
                except queue.Full:
                    try:
                        self.output_queue.get_nowait()
                        self.output_queue.put(pipeline_data, block=False)
                    except (queue.Empty, queue.Full):
                        pass

            elapsed = time.time() - start_time
            sleep_time = frame_interval - elapsed
            if sleep_time > 0:
                time.sleep(sleep_time)

        print("WebcamModule._processing_loop(): Processing Thread 종료")

    def _expand_bbox(self, bbox: Tuple[int, int, int, int], ratio: float) -> Tuple[int, int, int, int]:
        """
        축소된 바운딩 박스를 원본 크기로 복원합니다.

        :param bbox: (x, y, w, h) 형태의 축소된 바운딩 박스
        :param ratio: 원래 축소에 사용된 비율
        :return: 확장된 (x, y, w, h) 바운딩 박스
        """
        x, y, w, h = bbox

        # 확장할 크기 계산 (축소의 역연산)
        expand_w = int(w * ratio / (2 * (1 - ratio)))
        expand_h = int(h * ratio / (2 * (1 - ratio)))

        # 원본 크기로 복원
        orig_x = x - expand_w
        orig_y = y - expand_h
        orig_w = w + (expand_w * 2)
        orig_h = h + (expand_h * 2)

        return (orig_x, orig_y, orig_w, orig_h)

    def _calculate_iou(self, bbox1, bbox2):
        """
        두 바운딩 박스 간의 IoU (Intersection over Union) 계산
        :param bbox1: (x, y, w, h)
        :param bbox2: (x, y, w, h)
        :return: IoU 값 (0~1)
        """
        x1, y1, w1, h1 = bbox1
        x2, y2, w2, h2 = bbox2

        # 교집합 영역 계산
        x_left = max(x1, x2)
        y_top = max(y1, y2)
        x_right = min(x1 + w1, x2 + w2)
        y_bottom = min(y1 + h1, y2 + h2)

        if x_right < x_left or y_bottom < y_top:
            return 0.0

        intersection_area = (x_right - x_left) * (y_bottom - y_top)

        # 합집합 영역 계산
        bbox1_area = w1 * h1
        bbox2_area = w2 * h2
        union_area = bbox1_area + bbox2_area - intersection_area

        return intersection_area / union_area if union_area > 0 else 0.0

