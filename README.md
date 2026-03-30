# 📱 QR 출석 관리 시스템 (Capstone 2026)

이 프로젝트는 Flutter와 Firebase를 활용하여 행사 및 수업의 출석을 QR 코드로 간편하게 관리하기 위해 개발된 애플리케이션입니다.

## 🚀 주요 기능 (Key Features)

### 1. 학생/참여자 모드
* **메인 로그인 화면**: 앱 실행 시 가장 먼저 표시되는 일반 사용자용 화면입니다. 
* **사용자 대시보드 (구현 예정)**: 로그인 후 진입하는 일반 학생용 화면으로, 내 QR 코드 생성 및 출석 기록 확인 등의 기능을 제공할 예정입니다.

### 2. 관리자 모드 (Admin Dashboard)
* **관리자 숨김 진입점**: 일반 로그인 화면 우측 하단의 특정 영역을 탭하여 관리자 전용 로그인 화면으로 진입할 수 있습니다.
* **QR 출석 스캐너**: 기기의 카메라와 플래시 기능을 활용하여 학생들의 QR 코드를 스캔하고 실시간으로 출석을 처리합니다. (연속 스캔 방지 및 중복 출석 체크 기능 포함)
* **실시간 출석 명단 (구현 예정)**: 스캔이 완료된 방문객의 명단과 총 출석 인원을 Firebase Firestore와 연동하여 실시간으로 대시보드에서 확인할 수 있도록 구현할 예정입니다.
* **사전 신청자 명단 (구현 예정)**: QR 스캔 전, 행사에 미리 등록한 인원들의 데이터를 확인하고 관리할 수 있는 기능입니다.

## 🛠 기술 스택 (Tech Stack)
* **Frontend**: Flutter, Dart
* **Backend / Database**: Firebase Cloud Firestore
* **Packages**: 
  * `mobile_scanner`: QR 코드 스캔 및 카메라 제어
  * `firebase_core`, `cloud_firestore`: 데이터베이스 연동 및 실시간 스트림 데이터 처리

## 📁 폴더 구조 (Folder Structure)
앱의 유지보수와 협업을 위해 메인 코드와 화면(Screen) 코드를 철저히 분리하였습니다.

```text
lib/
 ┣ screens/
 ┃ ┣ login_screen.dart            # 첫 시작 화면 및 관리자 진입 포인트
 ┃ ┣ admin_dashboard.dart         # 관리자 전용 탭바 메인 화면 및 로그인 로직
 ┃ ┣ qr_scan_screen.dart          # QR 카메라 스캐너 및 출석 검증 로직
 ┃ ┣ user_dashboard.dart          # 일반 사용자(학생) 전용 대시보드 (구현 예정)
 ┃ ┗ pre_registration_list.dart   # 사전 등록자 명단 관리 화면 (구현 예정)
 ┗ main.dart                      # 앱의 진입점 (최소한의 라우팅만 담당)
