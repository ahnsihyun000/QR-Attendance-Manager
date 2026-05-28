import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  // Firebase 초기화 전에 Flutter 엔진 바인딩을 준비합니다.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // firebase_options.dart에 생성된 플랫폼별 설정값으로 Firebase를 연결합니다.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 네트워크가 불안정해도 Firestore 캐시를 활용해 앱이 유지되도록 설정합니다.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // 출석 시간 표시에서 한국어 오전/오후 형식이 나오도록 날짜 포맷을 초기화합니다.
    await initializeDateFormatting('ko_KR', null);
  } catch (e) {
    // 초기화 실패 시 앱이 바로 종료되지 않도록 로그만 남기고 실행을 이어갑니다.
    debugPrint("초기화 중 에러 발생: $e");
  }

  // 앱의 첫 화면은 일반 사용자 로그인 화면입니다.
  // 관리자 화면은 로그인 화면 우측 상단 아이콘을 통해 진입합니다.
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen()),
  );
}
