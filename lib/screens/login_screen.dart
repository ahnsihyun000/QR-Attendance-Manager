import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // 구글 로그인 연동 (계획서 내 Authentication 활용)
  Future<void> _signInWithGoogle() async {
    // 실제 구현 시 google_sign_in 패키지 연동 필요
    log("구글 로그인 시도 중...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("QR-Attendance Manager", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text("Google 계정으로 로그인"),
              onPressed: _signInWithGoogle,
            ),
          ],
        ),
      ),
    );
  }
}