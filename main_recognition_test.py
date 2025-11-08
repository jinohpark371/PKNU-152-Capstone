import queue
import cv2
import time  # time 임포트 (대기용)
from webcam_feature_module import WebcamModule
from pipeline_data import PipelineData

def main():
    print("--- main 함수 시작 ---")

    # 1. 큐 생성
    print("[1/9] 큐 생성 시도...")
    feature_to_auth_queue = queue.Queue(maxsize=1)
    print(" -> 큐 생성 완료 (feature_to_auth_queue)")

    # 2. 모듈 인스턴스 생성
    print("[2/9] WebcamModule 인스턴스 생성 시도...")
    try:
        webcam = WebcamModule(
            camera_id=0,
            capture_fps=30,
            processing_fps=5,
            tracking_fps=20
        )
        print(" -> WebcamModule 인스턴스 생성 완료.")
    except Exception as e:
        # __init__에서 raise한 오류(예: 카메라 열기 실패)를 여기서 잡습니다.
        print(f"\n!!! [치명적 오류] WebcamModule 초기화 실패: {e}")
        print(" -> 카메라가 연결되었는지, 다른 프로그램(Zoom, Teams 등)이 사용 중이지 않은지 확인하세요.")
        print(" -> 프로그램을 종료합니다.")
        exit(1)  # 오류 코드로 종료

    # 3. 출력 큐 설정
    print("[3/9] 출력 큐 설정 시도...")
    webcam.set_output_queue(feature_to_auth_queue)
    print(" -> 출력 큐 설정 완료.")

    # 4. 테스트 모드 활성화
    print("[4/9] 테스트 모드 활성화 시도...")
    webcam.enable_test_mode(True)
    print(" -> 테스트 모드 활성화 완료.")

    # 5. 웹캠 모듈 스레드 시작
    print("[5/9] 웹캠 스레드(Capture, Processing) 시작 시도...")
    webcam.start()
    print(" -> 웹캠 스레드 시작 완료.")

    # (기존 로그)
    print("\n--- 테스트 모드 시작. 'q'를 누르면 종료됩니다. ---")
    print("얼굴을 비추면 'RECOGNIZING' (파란색) -> 'TRACKING' (녹색)으로 변경됩니다.")
    print("메인 루프 대기 중 (GUI 창이 1초 내로 나타나야 합니다)...")

    # 현재 GUI에 표시 중인 상태를 저장 (중복 로그 방지)
    current_display_state = ""

    try:
        # 6. 메인 루프 진입
        print("[6/9] 메인 루프 진입. 데이터 수신 대기...")
        while True:
            # 6. 처리 스레드(ML)의 결과물을 가져옴 (블로킹)
            try:
                data: PipelineData = feature_to_auth_queue.get(timeout=1.0)
            except queue.Empty:
                # 1초간 데이터가 없으면 '.'을 찍어 프로그램이 살아있음을 표시
                print(f".", end="", flush=True)
                continue  # 데이터가 없으면 대기

            if data.frame is None:
                continue

            frame = data.frame.copy()

            # 7. 현재 상태에 따라 바운딩 박스 그리기
            color = (255, 0, 0)  # 파란색: RECOGNIZING
            state_text = "RECOGNIZING"

            # face_vectors가 비어있고 bbox_coords만 있으면 '추적' 상태임
            if not data.face_vectors and data.bbox_coords:
                color = (0, 255, 0)  # 녹색: TRACKING
                state_text = "TRACKING"

            # (로그 추가) 상태가 변경되었을 때만 콘솔에 알림
            if state_text != current_display_state:
                print(f"\n[상태 변경 감지] -> {state_text} 모드로 전환됨.")
                current_display_state = state_text

            for (x, y, w, h) in data.bbox_coords:
                cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)

            # 현재 상태 텍스트 표시
            cv2.putText(frame, state_text, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2)

            # 8. 화면에 표시
            cv2.imshow("WebcamModule Test (Press 'q' to quit)", frame)

            if cv2.waitKey(1) & 0xFF == ord('q'):
                print("\n[7/9] 'q' 입력 감지. 종료 절차 시작...")
                break

    finally:
        # 9. 종료 처리
        print("\n[8/9] 웹캠 모듈 정지 시도...")
        webcam.stop()
        print(" -> 웹캠 모듈 정지 완료.")
        cv2.destroyAllWindows()
        print("[9/9] 테스트 종료. (종료 코드 0)")

# (권장) Python 스크립트의 표준 실행 구문
if __name__ == "__main__":
    main()