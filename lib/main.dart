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
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 네트워크가 불안정해도 Firestore 캐시를 활용해 앱이 유지되도록 설정합니다.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    await initializeDateFormatting('ko_KR', null);
  } catch (e) {
    debugPrint("초기화 중 에러 발생: $e");
  }

  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen()),
  );
}
