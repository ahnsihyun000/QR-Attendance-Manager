import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';
import 'qr_scan_screen.dart';
import 'admin_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF333D4B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _login() async {
    final String id = _idController.text.trim();
    final String pw = _pwController.text.trim();

    if (id.isEmpty || pw.isEmpty) {
      _showSnackBar("학번과 비밀번호를 모두 입력해 주세요.");
      return;
    }

    try {
      // 1. 학번으로 유저 정보를 먼저 가져옴
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .get();

      if (!userDoc.exists) {
        _showSnackBar("가입되지 않은 학번입니다.");
        return;
      }

      final data = userDoc.data()!;

      // 2. 비밀번호만 체크 (학과 체크는 이제 안 함!)
      if (data['password'] != pw) {
        _showSnackBar("비밀번호가 맞지 않아요.");
        return;
      }

      if (!mounted) return;

      // 로그인 성공 시 QR 화면으로 이동 (데이터는 DB에 있는 거 그대로 사용)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QRScannerPage(userData: data)),
      );
    } catch (e) {
      _showSnackBar("네트워크 연결을 확인해 주세요.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Color(0xFFB0B8C1),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "배재대학교\n스마트 출석관리",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191F28),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "학번과 비밀번호로 로그인하세요.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8B95A1),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              _buildLabel("학번"),
              TextField(
                controller: _idController,
                decoration: _inputDecoration("학번을 입력하세요"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              _buildLabel("비밀번호"),
              TextField(
                controller: _pwController,
                obscureText: true,
                decoration: _inputDecoration("비밀번호를 입력하세요"),
              ),

              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3182F6),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("로그인"),
              ),

              const SizedBox(height: 15),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  ),
                  child: const Text(
                    "처음이신가요? 회원가입",
                    style: TextStyle(
                      color: Color(0xFF4E5968),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 기존과 동일한 스타일 가이드 ---
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0B8C1), fontSize: 15),
      filled: true,
      fillColor: const Color(0xFFF2F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3182F6), width: 1.5),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4E5968),
        ),
      ),
    );
  }
}
