# neck_check

거북목/자세 체크를 돕는 Flutter 앱입니다. iOS/Android에서 동일한 코드베이스로 동작하며, 플랫폼 맞춤형 UI를 제공합니다.

## 주요 기능

- 하단 탭 네비게이션
  - 측정, 일지 탭 제공.
  - 플랫폼별 아이콘/스타일 자동 적용.
- 적응형 UI
  - `adaptive_platform_ui` 기반의 네이티브스러운 UI.
  - iOS 아이콘 대응 처리.

핵심 화면:
- [`MainPage`](lib/pages/main_page.dart) 구현: [neck_check/lib/pages/main_page.dart](neck_check/lib/pages/main_page.dart)

## 프로젝트 구조

- Flutter 앱: [neck_check/](.)
  - 앱 엔트리 및 화면: [neck_check/lib/](neck_check/lib/)
  - 메인 화면: [`MainPage`](neck_check/lib/pages/main_page.dart)
  - 의존성: [neck_check/pubspec.yaml](neck_check/pubspec.yaml)
- 백엔드(옵션): [posture-back/](../posture-back/)
  - Node/Docker 기반 백엔드 템플릿(컨테이너 실행 스크립트 포함).
- 실험/유틸 스크립트(루트):
  - 자세 인식 파이프라인 관련 파이썬 스크립트: [auth_worker.py](../auth_worker.py), [posture_tracker.py](../posture_tracker.py), [pipeline_data.py](../pipeline_data.py), [is_stable.py](../is_stable.py), [webcam_feature_module.py](../webcam_feature_module.py)

## 실행 방법

사전 준비:
- Flutter SDK 설치(안정 채널 권장)
- Xcode( iOS ), Android Studio( Android ) 환경 변수 설정

의존성 설치:
```sh
cd neck_check
flutter pub get
```

앱 실행:
```sh
# 연결된 디바이스에 실행
flutter run

# 특정 플랫폼 지정
flutter run -d ios
flutter run -d android
```

빌드:
```sh
# Android APK
flutter build apk

# iOS(아카이브는 Xcode에서 진행)
flutter build ios
```

## 기술 포인트

- 적응형 네비게이션과 아이콘 처리
  - [`MainPage`](neck_check/lib/pages/main_page.dart)에서 AdaptiveScaffold/BottomNavigationBar 적용.
  - iOS 16.2+ 아이콘 분기 처리.

- 크로스 플랫폼 UI 일관성
  - Material/Cupertino 컴포넌트를 조합하여 네이티브 경험 제공.

## 개발 가이드

- 코드 스타일: Dart 공식 스타일 준수, 위젯·상태 분리
- 상태 관리: 페이지/위젯별 명확한 상태 소유
- 테스트: 위젯/단위 테스트 추가 권장
```sh
flutter test
```

## TODO

- 스크린샷 추가
- 측정/일지 데이터 모델 및 저장소 연동
- 백엔드 API 스펙 정리 및 연결
- 접근성(VoiceOver/TalkBack) 점검

## 라이선스

프로젝트 라이선스 파일 추가 예정.