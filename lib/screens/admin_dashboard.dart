import 'package:flutter/material.dart';
// =================================================================
// 🚨 여기서부터 관리자 전용 구역: 관리자 로그인 화면 (admin_dashboard.dart)
// =================================================================

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  void _tryLogin() {
    if (idController.text == "admin" && pwController.text == "1234") {
      // 💡 AdminHomePage는 같은 파일 안에 있으므로 import '../main.dart'가 필요 없습니다!
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      );
    } else {
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
              obscureText: true,
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
