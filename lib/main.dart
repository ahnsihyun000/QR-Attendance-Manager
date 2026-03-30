import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
// 어쩌피 메인화면에서는 import 할필요없는 부분이기 때문에 지워도 문제가 X
//import 'screens/admin_dashboard.dart';
//import 'screens/qr_scan_screen.dart';
//import 'screens/user_dashboard.dart';
//import 'screens/pre_registration_list.dart';

void main() async {
  // Firebase 초기화 등 앱 시작 전 필수 설정
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR 출석 관리 시스템',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // 🚪 앱을 켜면 무조건 처음 보이는 첫 관문!
      home: const LoginScreen(),
    );
  }
}
