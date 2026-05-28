import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 사용자가 입력한 회원가입 정보를 읽기 위한 컨트롤러입니다.
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _nameController = TextEditingController();

  // Firebase 요청 중 버튼 중복 클릭을 막고 로딩 표시를 보여주기 위한 상태값입니다.
  bool _isLoading = false;

  // 회원가입 화면에서 반복해서 쓰는 색상값입니다.
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

  // 사전 신청 명단과 일치하는 학생만 가입 승인 대기 상태로 저장합니다.
  Future<void> _register() async {
    // 앞뒤 공백 때문에 조회가 실패하지 않도록 입력값을 trim 처리합니다.
    final String id = _idController.text.trim();
    final String pw = _pwController.text.trim();
    final String name = _nameController.text.trim();

    // 필수 입력값이 비어 있으면 Firestore 조회를 하지 않고 바로 안내합니다.
    if (id.isEmpty || pw.isEmpty || name.isEmpty) {
      _showSnackBar("모든 정보를 입력해 주세요.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 사전 신청 명단에 학번과 이름이 모두 일치하는 문서가 있는지 확인합니다.
      // 학번만 맞거나 이름만 맞는 경우는 다른 사람 정보일 수 있으므로 가입을 허용하지 않습니다.
      final preRegQuery = await FirebaseFirestore.instance
          .collection('pre-investigation list')
          .where('studentId', isEqualTo: id)
          .where('userName', isEqualTo: name)
          .get();

      if (preRegQuery.docs.isEmpty) {
        _showSnackBar("사전 신청한 학생 정보와 일치하지 않습니다.\n행사에 참여하시려면 사전 신청을 진행해 주세요.");
        return;
      }

      // users 컬렉션에서 같은 학번으로 이미 가입된 기록이 있는지 1차로 확인합니다.
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .get();

      // 실제 저장은 "학번 이름" 형태의 문서 ID를 사용하므로 해당 ID도 함께 중복 확인합니다.
      String docId = '$id $name';
      final alternativeDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .get();

      if (doc.exists || alternativeDoc.exists) {
        _showSnackBar("이미 가입 승인 대기 중이거나 가입된 학생입니다.");
        return;
      }

      // 가입 요청은 바로 승인하지 않고 "비승인" 상태로 저장합니다.
      // 이후 관리자가 승인 화면에서 status를 "승인"으로 변경해야 로그인할 수 있습니다.
      await FirebaseFirestore.instance.collection('users').doc(docId).set({
        'studentId': id,
        'password': pw,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'status': "비승인",
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
                    letterSpacing: 0,
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
