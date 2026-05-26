import 'package:cloud_firestore/cloud_firestore.dart'; // 🎯 [추가] 파이어스토어 설정용 임포트
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  // 1. 플러터 엔진 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. 파이어베이스 먼저 확실하게 초기화 완료하기
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 🎯 3. [오프라인 모드 적용] Firestore 로컬 데이터 지속성 및 캐시 활성화
    // 네트워크가 단절된 오프라인 환경에서도 앱이 튕기지 않고 로컬 캐시 데이터를 활용합니다.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true, // 오프라인 지속성 활성화
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // 대규모 행사 대비 캐시 용량 제한 해제
    );

    // 4. 한국어 날짜 포맷 초기화 완료하기
    await initializeDateFormatting('ko_KR', null);
  } catch (e) {
    debugPrint("⚠️ 초기화 중 에러 발생: $e");
  }

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: LoginScreen(),
    ),
  );
}