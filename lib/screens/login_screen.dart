import 'package:flutter/material.dart';
import '../main.dart'; // 로그인 성공 시 이동할 화면이 있는 파일

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 아이디와 비번을 입력받는 상자의 "컨트롤러"입니다.
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  void _tryLogin() {
    // 캡스톤 시연용 계정 설정 (나중에 바꿀 수 있어요!)
    if (idController.text == "admin" && pwController.text == "1234") {
      // 로그인 성공! 스캐너 화면으로 이동 (뒤로가기 방지용 pushReplacement)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminHomePage(),
        ), // QRScannerScreen이 아니라 AdminHomePage로!
      );
    } else {
      // 로그인 실패! 메시지 띄우기
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("ID 또는 비밀번호가 틀렸습니다.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("관리자 로그인"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "QR 출석 관리 시스템",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: "관리자 ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: pwController,
              decoration: const InputDecoration(
                labelText: "비밀번호",
                border: OutlineInputBorder(),
              ),
              obscureText: true, // 비번 안 보이게 별표 처리
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _tryLogin,
                child: const Text("로그인"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
