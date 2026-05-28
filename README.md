# QR 출석 관리 시스템

Flutter와 Firebase Firestore를 기반으로 만든 QR 출석 관리 애플리케이션입니다. 행사 또는 수업 참여자가 사전 신청 후 가입 요청을 하면, 관리자가 승인하고 QR 스캔을 통해 출석을 실시간으로 기록할 수 있습니다.

## 프로젝트 목적

기존 출석 확인 방식은 수기 명단 확인, 중복 체크, 사전 신청자 대조 과정에서 시간이 오래 걸릴 수 있습니다. 이 프로젝트는 학생용 QR 생성 화면과 관리자용 QR 스캔 화면을 분리해 출석 처리 과정을 간단하게 만들고, Firestore를 통해 출석 현황과 통계를 실시간으로 확인할 수 있도록 구현했습니다.

## 주요 기능

- 학생 회원가입 및 로그인
- 사전 신청 명단 기반 학번/이름 검증
- 관리자 승인 후 학생 로그인 허용
- 30초마다 갱신되는 동적 QR 코드 생성
- HMAC-SHA256 기반 QR 위변조 검증
- 날짜와 학생 정보를 기준으로 중복 출석 방지
- 관리자용 QR 카메라 스캔
- 실시간 출석 명단 확인
- 사전 신청자 명단 확인
- 행사별 출석률 통계 확인
- 가입자 승인 및 승인 취소 관리

## 사용자 흐름

```text
학생
  1. 이름, 학번, 비밀번호 입력
  2. 사전 신청 명단과 일치하는지 확인
  3. 가입 요청 후 관리자 승인 대기
  4. 승인 완료 후 로그인
  5. 30초마다 갱신되는 QR 코드 제시

관리자
  1. 관리자 로그인
  2. 가입자 승인 또는 취소
  3. 학생 QR 코드 스캔
  4. QR 유효성 및 중복 출석 확인
  5. 출석 명단과 통계 확인
```

## 기술 스택

- Flutter
- Dart
- Firebase Core
- Cloud Firestore
- mobile_scanner
- qr_flutter
- crypto
- fl_chart
- intl

## 핵심 구현 내용

### 동적 QR 생성 및 검증

학생 QR은 `학번:이름:시간창` 형태의 데이터에 HMAC-SHA256 해시를 붙여 생성합니다. 관리자는 QR을 스캔한 뒤 동일한 비밀 키로 해시를 다시 계산하여 위변조 여부를 확인합니다.

QR은 30초 단위 시간창을 사용하므로 오래된 QR 코드는 자동으로 만료됩니다. 이를 통해 단순 캡처 이미지 재사용을 줄이고, 출석 처리의 신뢰도를 높였습니다.

### 사전 신청자 기반 가입 제한

회원가입 시 `pre-investigation list` 컬렉션에서 학번과 이름이 동시에 일치하는 문서가 있는지 확인합니다. 사전 신청 내역이 없는 사용자는 가입할 수 없도록 처리했습니다.

### 관리자 승인 방식

학생 가입 요청은 `users` 컬렉션에 `비승인` 상태로 저장됩니다. 관리자가 승인 화면에서 상태를 `승인`으로 변경해야 학생 로그인이 가능합니다.

### 중복 출석 방지

관리자가 QR을 스캔하면 학번, 이름, 날짜를 조합한 문서 ID로 `attendance` 컬렉션에 출석 기록을 저장합니다. 같은 날짜에 동일 학생이 다시 스캔되면 이미 출석한 사용자로 안내합니다.

## Firestore 컬렉션 구조

```text
pre-investigation list
  studentId: 사전 신청자 학번
  userName: 사전 신청자 이름
  department: 행사명 또는 소속 구분
  timestamp: 사전 신청 시간

users
  studentId: 학번
  name: 이름
  password: 비밀번호
  status: 승인 상태 ("승인" 또는 "비승인")
  createdAt: 가입 요청 시간

attendance
  studentId: 출석 학생 학번
  userName: 출석 학생 이름
  timestamp: 출석 처리 시간
```

## 폴더 구조

```text
lib/
  main.dart                       앱 시작 및 Firebase 초기화
  constants.dart                  공통 상수
  firebase_options.dart           Firebase 설정

  models/
    attendance_model.dart         출석 데이터 모델
    user_model.dart               사용자 데이터 모델

  screens/
    login_screen.dart             학생 로그인 화면
    signup_screen.dart            학생 회원가입 화면
    user_qr_screen.dart           학생 QR 표시 화면
    admin_login.dart              관리자 로그인 화면
    admin_dashboard.dart          관리자 메인 대시보드
    admin_qr_camera_tab.dart      QR 스캔 및 출석 처리 화면
    admin_attendance_list.dart    실시간 출석 명단 화면
    admin_statistics_tab.dart     출석 통계 화면
    admin_user_approval.dart      가입자 승인 관리 화면
    pre_registration_list.dart    사전 신청자 명단 화면

  services/
    database_service.dart         Firestore 출석 데이터 처리

  utils/
    qr_manager.dart               QR 생성 및 검증 로직

  widgets/
    qr_view.dart                  공통 QR 표시 위젯
```

## 실행 방법

```bash
flutter pub get
flutter run
```

Android debug APK 빌드는 다음 명령어로 확인할 수 있습니다.

```bash
flutter build apk --debug
```

빌드 결과물은 아래 경로에 생성됩니다.

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## 관리자 로그인

시연용 관리자 계정은 앱 코드에 고정되어 있습니다.

```text
ID: admin
PW: 1234
```

실제 서비스 환경에서는 관리자 계정을 Firebase Authentication 또는 별도 관리자 권한 체계로 분리하는 것이 필요합니다.

## 검증한 항목

- `flutter analyze` 통과
- `flutter build apk --debug` 성공
- Android debug APK 생성 확인

## 향후 개선점

- 학생 비밀번호 해시 저장 적용
- Firebase Authentication 기반 로그인 연동
- 관리자 계정 및 권한 관리 고도화
- Firestore 보안 규칙 세분화
- 출석 데이터 CSV 내보내기 기능
- 테스트 코드 추가
