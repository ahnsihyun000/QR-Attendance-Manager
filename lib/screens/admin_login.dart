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
  bool _isPasswordVisible = false; // 비밀번호 숨김/표시 상태

  // 스타일 상수
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossGreyBg = Color(0xFFF2F4F6);
  static const _tossTextPrimary = Color(0xFF191F28);
  static const _tossTextSecondary = Color(0xFF4E5968);
  static const _tossHint = Color(0xFFB0B8C1);

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void _tryLogin() {
    final String id = _idController.text.trim();
    final String pw = _pwController.text.trim();

    if (id == "admin" && pw == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
      );
    } else {
      _showSnackBar(id.isEmpty || pw.isEmpty ? "아이디와 비밀번호를 모두 입력해주세요." : "정보가 일치하지 않습니다.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFF333D4B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 키보드가 올라올 때 화면이 가려지지 않도록 탭하면 포커스 해제
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _tossTextPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
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
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 48),

                // ID 입력란
                _buildLabel("관리자 ID"),
                TextField(
                  controller: _idController,
                  textInputAction: TextInputAction.next, // 다음 버튼
                  decoration: _inputDecoration("ID를 입력하세요"),
                  style: const TextStyle(color: _tossTextPrimary),
                ),

                const SizedBox(height: 24),

                // 비밀번호 입력란
                _buildLabel("비밀번호"),
                TextField(
                  controller: _pwController,
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.done, // 완료 버튼
                  onSubmitted: (_) => _tryLogin(), // 키보드 완료 누르면 로그인 시도
                  decoration: _inputDecoration("비밀번호를 입력하세요").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: _tossHint,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),

                const SizedBox(height: 56),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _tossTextSecondary),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _tryLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _tossBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: const Text("인증하기"),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _tossHint, fontSize: 15),
      filled: true,
      fillColor: _tossGreyBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _tossBlue, width: 1.5),
      ),
    );
  }
}