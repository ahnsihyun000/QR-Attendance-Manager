import 'package:flutter/material.dart';
import 'admin_dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 🎯 관리자 로그인 계정 정보
  final String _correctId = "admin";
  final String _correctPassword = "1234";

  // 🎨 두 번째 코드(LoginScreen)와 동일하게 상수를 정밀 정렬
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossGreyBg = Color(0xFFF2F4F6); // _tossInputBg에서 변경
  static const _tossTextPrimary = Color(0xFF191F28); // _tossBlack에서 변경
  static const _tossTextSecondary = Color(0xFF4E5968); // _tossGreyText에서 변경
  static const _tossHint = Color(0xFFB0B8C1);

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    String inputId = _idController.text.trim();
    String inputPw = _passwordController.text.trim();

    if (inputId == _correctId && inputPw == _correctPassword) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("아이디 또는 비밀번호가 올바르지 않습니다.", style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF333D4B), // 스낵바 배경색 통일
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 화면 터치 시 키보드 닫기 추가
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _tossTextPrimary,
              size: 22,
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20), // 두 번째 코드와 여백 통일

                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 30, // 28 -> 30 변경
                      fontWeight: FontWeight.bold,
                      color: _tossTextPrimary,
                      height: 1.4, // 줄간격 추가
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(
                        text: "Checky ",
                        style: TextStyle(color: _tossBlue),
                      ),
                      TextSpan(
                        text: "\n관리자 로그인",
                        style: TextStyle(color: _tossTextPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "관리자용 ID와 비밀번호를 입력하세요.",
                  style: TextStyle(
                    fontSize: 14,
                    color: _tossTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),

                // 🎯 아이디 입력란 (_buildInputField 스타일 직접 이식)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        "관리자 아이디",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _tossTextSecondary),
                      ),
                    ),
                    TextField(
                      controller: _idController,
                      style: const TextStyle(color: _tossTextPrimary),
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration("관리자 아이디를 입력하세요"),
                    ),
                  ],
                ),
                const SizedBox(height: 24), // 두 번째 코드와 입력창 간격 통일 (28 -> 24)

                // 🎯 비밀번호 입력란 (_buildInputField 스타일 직접 이식)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        "비밀번호",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _tossTextSecondary),
                      ),
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: _tossTextPrimary),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
                      decoration: _inputDecoration("비밀번호를 입력하세요"),
                    ),
                  ],
                ),

                const SizedBox(height: 56), // Spacer() 대신 두 번째 코드와 동일한 고정 여백 적용

                // 🎯 하단 와이드 로그인 버튼 스타일 통일
                SizedBox(
                  width: double.infinity,
                  height: 60, // 58 -> 60 변경
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tossBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // 16 -> 18 변경
                    ),
                    child: const Text("로그인"),
                  ),
                ),
                const SizedBox(height: 34),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 두 번째 코드의 깔끔한 테두리 및 인풋 데코레이션 이식
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _tossHint, fontSize: 15),
      filled: true,
      fillColor: _tossGreyBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), // 18 -> 14 라운딩 통일
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _tossBlue, width: 1.5),
      ),
    );
  }
}