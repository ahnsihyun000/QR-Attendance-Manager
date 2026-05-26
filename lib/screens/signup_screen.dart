import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  // 스타일 상수 (Toss Style)
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossGreyBg = Color(0xFFF2F4F6);
  static const _tossTextPrimary = Color(0xFF191F28);
  static const _tossTextSecondary = Color(0xFF4E5968);
  static const _tossHint = Color(0xFFB0B8C1);

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!mounted) return; // 화면이 사라진 상태에서 스낵바 호출 방지
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
      ),
    );
  }

  // 회원가입 로직
  Future<void> _register() async {
    final String id = _idController.text.trim();
    final String pw = _pwController.text.trim();
    final String name = _nameController.text.trim();

    if (id.isEmpty || pw.isEmpty || name.isEmpty) {
      _showSnackBar("모든 정보를 입력해 주세요.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. ✨ [가장 안전한 방법] 고유한 값인 학번(Document ID)으로 중복 가입 여부 확인
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .get();

      if (doc.exists) {
        _showSnackBar("이미 가입된 학생입니다.");
        return; // finally 블록에서 로딩 상태가 자동으로 해제됩니다.
      }

      // 2. 중복된 학번이 없다면 신규 회원 정보 Firestore에 저장
      // 문자열 안에서 $id와 $name을 사용하고 사이에 공백을 한 칸 둡니다.
      String docId = '$id $name';

      await FirebaseFirestore.instance.collection('users').doc(docId).set({
        'studentId': id,
        'password': pw,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSnackBar("가입을 축하합니다! 🎉");
      Navigator.pop(context); // 로그인 화면으로 이동
    } catch (e) {
      _showSnackBar("가입에 실패했습니다. 다시 시도해 주세요.");
    } finally {
      // 가입 성공, 중복 차단, 통신 에러 등 어떤 경로로 종료되든 로딩 애니메이션 안전하게 해제
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _tossTextPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "새로운 시작,\n정보를 입력해 주세요",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: _tossTextPrimary,
                    height: 1.4,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 40),

                _buildInputField("이름", _nameController, "실명을 입력하세요"),
                const SizedBox(height: 24),

                _buildInputField(
                  "학번",
                  _idController,
                  "학번 7자리를 입력하세요",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                _buildInputField(
                  "비밀번호",
                  _pwController,
                  "비밀번호를 설정하세요",
                  isObscure: true,
                ),

                const SizedBox(height: 56),
                _buildSubmitButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI 컴포넌트 ---

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _tossTextSecondary,
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
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
        onPressed: _isLoading ? null : _register,
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
                  strokeWidth: 2,
                ),
              )
            : const Text("가입하기"),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _tossHint, fontSize: 15),
      filled: true,
      fillColor: _tossGreyBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
