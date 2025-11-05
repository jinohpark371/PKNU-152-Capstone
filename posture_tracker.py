import cv2
import mediapipe as mp
import time
from datetime import datetime
from is_stable import is_stable;

mp_face_mesh = mp.solutions.face_mesh
NOSE_INDEX = 1

cap = cv2.VideoCapture(0)
if not cap.isOpened():
    print("카메라를 열 수 없습니다.")
    exit()

calibrated = False
baseline_box = None
baseline_nose = None

# 안정 검출용 변수
stabilizing = False
stability_start = 0
nose_history = []
box_history = []



with mp_face_mesh.FaceMesh(
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5
) as face_mesh:

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame = cv2.flip(frame, 1)
        h, w, _ = frame.shape
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = face_mesh.process(rgb)

        if results.multi_face_landmarks:
            face = results.multi_face_landmarks[0]

            # bounding box 계산
            xs = [lm.x * w for lm in face.landmark]
            ys = [lm.y * h for lm in face.landmark]
            x_min, x_max = int(min(xs)), int(max(xs))
            y_min, y_max = int(min(ys)), int(max(ys))
            current_box = (x_min, y_min, x_max - x_min, y_max - y_min)

            # 코 좌표
            nose = face.landmark[NOSE_INDEX]
            nose_point = (int(nose.x * w), int(nose.y * h))
            cv2.circle(frame, nose_point, 4, (0, 255, 0), -1)

            if calibrated:
                # 기준 표시
                bx, by, bw, bh = baseline_box
                cv2.rectangle(frame, (bx, by), (bx + bw, by + bh), (255, 0, 0), 2)
                cv2.circle(frame, baseline_nose, 5, (255, 0, 0), -1)

                # 실시간 코 위치 비교
                nx, ny = nose_point
                base_x, base_y = baseline_nose
                dx, dy = nx - base_x, ny - base_y

                # 얼굴 크기 비율 (현재 face area / baseline area)
                current_area = current_box[2] * current_box[3]
                baseline_area = bw * bh
                face_scale = current_area / baseline_area

                pose = "normal"

                # 뒤로 젖힘 (멀어짐)
                if face_scale < 0.9:
                    pose = "L"

                # 좌우 기울기 (측만)
                elif abs(dx) > bw * 0.2:
                    pose = "left" if dx < 0 else "right"

                # 거북목 (얼굴 크기 거의 일정하지만 고개만 아래로)
                elif 0.9 <= face_scale <= 1.15 and dy > 25:
                    pose = "turtle"

                # 나머지 → 정자세
                else:
                    pose = "normal"

                # 텍스트 표시
                cv2.putText(frame, f"Posture: {pose}", (30, 30),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)

                # 얼굴 크기 스케일 시각화 (카메라 화면 좌상단)
                scale_text = f"Face Scale: {face_scale:.2f}x"
                cv2.putText(frame, scale_text, (30, 60),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 0), 2)

                # 디버그용 이동량
                cv2.putText(frame, f"dx:{dx}, dy:{dy}", (30, 90),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (200, 255, 200), 1)
                 # 실시간 데이터 콘솔 출력 (나중에 백엔드 전송용)
                realtime_data = {
                    "baseline": {
                        "box": {"x": bx, "y": by, "width": bw, "height": bh},
                        "nose": {"x": base_x, "y": base_y}
                    },
                    "current": {
                        "timestamp": datetime.now().isoformat(timespec='seconds'),
                        "pose": pose,
                        "dx": dx,
                        "dy": dy,
                        "face_scale": round(face_scale, 3)
                    }
                }

                print(realtime_data)


            elif stabilizing:
                # 안정 감지 중 표시
                nose_history.append(nose_point)
                box_history.append((current_box[2], current_box[3]))

                if time.time() - stability_start > 1.5:
                    if is_stable(nose_history, box_history):
                        baseline_box = (
                            x_min,
                            y_min,
                            x_max - x_min,
                            y_max - y_min
                        )
                        baseline_nose = nose_point
                        calibrated = True
                        stabilizing = False
                        print("자동 캘리브레이션 완료 (정자세 고정)")
                    else:
                        print("안정 안됨 → 다시 시도 필요")
                        stabilizing = False

                cv2.putText(frame, "Calibrating... Stay still", (30, 30),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 200, 255), 2)

            else:
                cv2.putText(frame, "Press 'c' to auto-calibrate posture", (30, 30),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 0), 2)

        # 표시 및 입력
        cv2.imshow("Auto Calibration Posture Detector", frame)
        key = cv2.waitKey(10)

        if key == ord('c') and results.multi_face_landmarks:
            # 자동 안정 캘리브레이션 시작
            stabilizing = True
            stability_start = time.time()
            nose_history.clear()
            box_history.clear()
            print("정자세 감지 중... (1.5초 동안 유지하세요)")

        elif key == 27:
            break

cap.release()
cv2.destroyAllWindows()
