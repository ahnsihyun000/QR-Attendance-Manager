import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';
import 'user_qr_screen.dart';
import 'admin_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 로그인 입력값을 가져오기 위한 컨트롤러입니다.
  final _idController = TextEditingController();
  final _pwController = TextEditingController();

  // 로그인 요청 중 버튼을 잠그고 로딩 인디케이터를 보여주기 위한 값입니다.
  bool _isLoading = false;

  // 로그인 화면에서 반복해서 쓰는 색상값입니다.
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

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF333D4B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 관리자가 가입을 승인하기 전에는 학생 로그인을 막습니다.
  void _showApprovalWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(
              Icons.lock_clock_rounded,
              color: Colors.orangeAccent,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              "승인 대기 중",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _tossTextPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          "아직 가입 승인이 되지 않았습니다.\n관리자가 승인 완료한 후 로그인이 가능합니다.",
          style: TextStyle(
            fontSize: 14,
            color: _tossTextSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "확인",
              style: TextStyle(
                color: _tossBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 학번, 비밀번호, 승인 상태를 순서대로 확인합니다.
  Future<void> _login() async {
    // Firestore 저장값과 비교하기 전에 입력 공백을 제거합니다.
    final String id = _idController.text.trim();
    final String pw = _pwController.text.trim();

    if (id.isEmpty || pw.isEmpty) {
      _showSnackBar("학번과 비밀번호를 모두 입력해 주세요.");
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      // users 컬렉션에서 입력한 학번과 같은 회원 문서를 찾습니다.
      // 회원가입 때 저장한 studentId 필드를 기준으로 조회합니다.
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('studentId', isEqualTo: id)
          .get();

      if (userQuery.docs.isEmpty) {
        _showSnackBar("가입되지 않은 학번입니다.");
        return;
      }

      final userDoc = userQuery.docs.first;
      final data = userDoc.data();

      // 현재 프로젝트에서는 입력 비밀번호와 Firestore 비밀번호 문자열을 직접 비교합니다.
      // 실제 서비스에서는 비밀번호 해시 저장 방식으로 확장하는 것이 좋습니다.
      final String dbPassword = '${data['password'] ?? ''}'.trim();
      if (dbPassword != pw) {
        _showSnackBar("비밀번호가 맞지 않아요.");
        return;
      }

      // 관리자가 승인하지 않은 사용자는 QR 화면으로 이동하지 못하게 차단합니다.
      final String status = data['status'] ?? "비승인";
      if (status != "승인") {
        if (!mounted) return;
        _showApprovalWarningDialog();
        return;
      }

      if (!mounted) return;

      // 로그인에 성공하면 사용자 데이터를 QR 화면에 넘겨 QR 생성에 사용합니다.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QRScannerPage(userData: data)),
      );
    } catch (e) {
      _showSnackBar("네트워크 연결이나 Firestore 권한을 확인해 주세요.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.admin_panel_settings_rounded,
                color: _tossHint,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminLoginScreen(),
                ),
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
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: _tossTextPrimary,
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                    children: [
                      TextSpan(text: "반가워요, \n"),
                      TextSpan(
                        text: "Checky",
                        style: TextStyle(color: _tossBlue),
                      ),
                      TextSpan(text: " 에요"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "학번과 비밀번호로 로그인하세요.",
                  style: TextStyle(
                    fontSize: 14,
                    color: _tossTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
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
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _tossTextSecondary,
            ),
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
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
        child: const Text(
          "회원가입",
          style: TextStyle(
            color: _tossBlue,
            fontWeight: FontWeight.bold,
            fontSize: 15,
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _tossBlue, width: 1.5),
      ),
    );
  }
}
