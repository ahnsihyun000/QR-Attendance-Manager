import 'package:flutter/material.dart';
import 'admin_dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();

  // 스타일 상수 (전체 앱 공통 느낌 유지)
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossGreyBg = Color(0xFFF2F4F6);
  static const _tossTextPrimary = Color(0xFF191F28);
  static const _tossTextSecondary = Color(0xFF4E5968);
  static const _tossHint = Color(0xFFB0B8C1);

  @override
  void dispose() {
    // 컨트롤러 해제로 메모리 관리
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void _tryLogin() {
    // 실제 운영 시에는 이 부분을 서버나 Firebase Auth로 교체하는 것이 좋습니다.
    if (_idController.text.trim() == "admin" &&
        _pwController.text.trim() == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
      );
    } else {
      _showSnackBar("아이디 또는 비밀번호가 틀렸어요.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF333D4B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _tossTextPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "관리자님,\n인증이 필요합니다",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _tossTextPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // 입력 필드 통합 메서드 사용
              _buildInputField("관리자 ID", _idController, "ID를 입력하세요"),
              const SizedBox(height: 20),
              _buildInputField("비밀번호", _pwController, "비밀번호를 입력하세요", isObscure: true),

              const SizedBox(height: 50),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI 재사용 위젯 ---

  Widget _buildInputField(String label, TextEditingController controller, String hint, {bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _tossTextSecondary),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _tryLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: _tossBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: const Text("인증하기"),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _tossHint, fontSize: 15),
      filled: true,
      fillColor: _tossGreyBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _tossBlue, width: 1.5),
      ),
    );
  }
}