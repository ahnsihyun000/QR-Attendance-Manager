import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // 1. 플러터 엔진 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. 파이어베이스 먼저 확실하게 초기화 완료하기
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 3. 날짜 포맷 초기화 완료하기
    await initializeDateFormatting('ko_KR', null);
  } catch (e) {
    debugPrint("⚠️ 초기화 중 에러 발생: $e");
  }

  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen()),
  );
}
