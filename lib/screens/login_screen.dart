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
  bool _isLoading = false; // 로그인 처리 중 상태 확인

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

  // 알림 메시지 (SnackBar)
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF333D4B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 로그인 로직
  Future<void> _login() async {
    final String id = _idController.text.trim();
    final String pw = _pwController.text.trim();

    if (id.isEmpty || pw.isEmpty) {
      _showSnackBar("학번과 비밀번호를 모두 입력해 주세요.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(id).get();

      if (!userDoc.exists) {
        _showSnackBar("가입되지 않은 학번입니다.");
        return;
      }

      final data = userDoc.data()!;
      if (data['password'] != pw) {
        _showSnackBar("비밀번호가 맞지 않아요.");
        return;
      }

      if (!mounted) return;

      // 로그인 성공 시 QR 스캐너 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QRScannerPage(userData: data)),
      );
    } catch (e) {
      _showSnackBar("네트워크 연결을 확인해 주세요.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 화면 터치 시 키보드 닫기
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: _tossHint),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
              ),
              tooltip: "관리자 로그인",
            ),
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
                    color: _tossTextPrimary,
                    height: 1.4,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "학번과 비밀번호로 로그인하세요.",
                  style: TextStyle(fontSize: 16, color: _tossTextSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 48),

                _buildInputField(
                  label: "학번",
                  controller: _idController,
                  hint: "학번을 입력하세요",
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  label: "비밀번호",
                  controller: _pwController,
                  hint: "비밀번호를 입력하세요",
                  isObscure: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                ),

                const SizedBox(height: 56),
                _buildSubmitButton(),
                const SizedBox(height: 16),
                _buildSignUpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool isObscure = false,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _tossTextSecondary)),
        ),
        TextField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          style: const TextStyle(color: _tossTextPrimary),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: _tossBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _tossBlue.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text("로그인"),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        ),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 15, color: _tossTextSecondary),
            children: [
              TextSpan(text: "처음이신가요? "),
              TextSpan(text: "회원가입", style: TextStyle(color: _tossBlue, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
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