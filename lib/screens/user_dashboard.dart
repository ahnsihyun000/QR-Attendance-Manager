import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("내 출석 정보"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text("홍길동님, 환영합니다!", style: TextStyle(fontSize: 20)),
            const Text("현재 출석 상태: 대기 중", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // 나중에 QR 보여주기 기능 연결
              },
              child: const Text("내 QR 코드 보기"),
            ),
          ],
        ),
      ),
    );
  }
}
