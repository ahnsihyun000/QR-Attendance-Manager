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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3),
        ),
        backgroundColor: const Color(0xFF333D4B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // 🎯 회원가입 로직 (학번 + 이름 실시간 동시 크로스체크 대조)
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
      // 1️⃣ [핵심 대조 단계] 사전 신청 명단에서 학번과 이름이 동시에 일치하는 문서가 있는지 쿼리합니다.
      final preRegQuery = await FirebaseFirestore.instance
          .collection('pre-investigation list')
          .where('studentId', isEqualTo: id)
          .where('userName', isEqualTo: name) // 🎯 이름 필드까지 엄격하게 검증 추가!
          .get();

      // 학번과 이름 조합이 일치하는 사전 신청 내역이 없다면 가입을 차단합니다.
      if (preRegQuery.docs.isEmpty) {
        _showSnackBar("사전 신청한 학생 정보와 일치하지 않습니다.\n행사에 참여하시려면 사전 신청을 진행해 주세요.");
        return;
      }

      // 2️⃣ 중복 가입 여부 체크 (이미 가입 처리가 완료된 유저인지 식별)
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(id) // 학번 자체를 단독 ID로 검증하거나 하단 docId 포맷에 맞춥니다.
          .get();

      // 혹시 '학번 이름' 포맷의 문서 ID 중복도 함께 안전하게 방어하기 위한 정의
      String docId = '$id $name';
      final alternativeDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .get();

      if (doc.exists || alternativeDoc.exists) {
        _showSnackBar("이미 가입 승인 대기 중이거나 가입된 학생입니다.");
        return;
      }

      // 3️⃣ 사전 신청 기록(학번+이름)이 완벽히 증명되었으므로 가입 최종 승인 대기 처리 진행
      await FirebaseFirestore.instance.collection('users').doc(docId).set({
        'studentId': id,
        'password': pw,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'status': "비승인", // 가입자 승인 화면으로 정상 이동하게 유도
      });

      if (!mounted) return;
      _showSnackBar("회원가입 요청이 완료되었습니다.\n관리자 승인 후 로그인이 가능합니다!");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("가입 처리 중 오류가 발생했습니다. 다시 시도해 주세요.");
    } finally {
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