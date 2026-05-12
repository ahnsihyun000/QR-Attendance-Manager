import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Firebase 초기화와 함께 날짜 포맷 데이터도 초기화합니다
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    initializeDateFormatting('ko_KR', null), // 한국어 날짜 데이터 로드
  ]);

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(), 
  ));
}