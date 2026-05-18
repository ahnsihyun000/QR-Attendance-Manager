import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _nameController = TextEditingController();
  String? _selectedDept;
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

  // 학과 선택 모달
  void _showDeptPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: _tossGreyBg, borderRadius: BorderRadius.circular(2))),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("학과를 선택해 주세요", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _tossTextPrimary)),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: AppConstants.departments.length,
                    itemBuilder: (context, index) {
                      final dept = AppConstants.departments[index];
                      return ListTile(
                        title: Text(dept, style: const TextStyle(fontSize: 16, color: _tossTextPrimary)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        onTap: () {
                          setState(() => _selectedDept = dept);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 회원가입 로직 (중복 가입 방지 보강)
  Future<void> _register() async {
    final String id = _idController.text.trim();
    final String pw = _pwController.text.trim();
    final String name = _nameController.text.trim();

    // 1. 필수 입력값 확인
    if (id.isEmpty || pw.isEmpty || name.isEmpty || _selectedDept == null) {
      _showSnackBar("모든 정보를 입력해 주세요.");
      return;
    }

    // 2. 학번 자리수 간단 체크 (필요시)
    if (id.length < 5) {
      _showSnackBar("유효한 학번을 입력해 주세요.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. 🔥 학번 중복 체크 (DB에 해당 문서가 이미 있는지 조회)
      final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      
      if (doc.exists) {
        // 이미 가입된 경우 함수를 여기서 종료함
        if (mounted) setState(() => _isLoading = false);
        _showSnackBar("이미 가입된 학번입니다. 로그인해 주세요.");
        return; 
      }

      // 4. 중복이 아니면 새로운 문서 생성
      await FirebaseFirestore.instance.collection('users').doc(id).set({
        'studentId': id,
        'password': pw,
        'name': name,
        'department': _selectedDept,
        'createdAt': FieldValue.serverTimestamp(),
        'lastDeviceId': '', // 중복 로그인 방지 기능을 위한 필드 미리 생성
      });

      if (!mounted) return;
      _showSnackBar("가입을 축하합니다! 🎉");
      
      // 잠시 후 로그인 화면으로 이동
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pop(context);
      });

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("네트워크 오류가 발생했습니다. 다시 시도해 주세요.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const SizedBox(height: 10),
              const Text(
                "새로운 시작,\n정보를 입력해 주세요",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _tossTextPrimary,
                  height: 1.4,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 40),

              _buildInputField("이름", _nameController, "실명을 입력하세요"),
              const SizedBox(height: 24),

              _buildInputField("학번", _idController, "학번을 입력하세요", keyboardType: TextInputType.number),
              const SizedBox(height: 24),

              _buildLabel("소속 학과"),
              _buildDeptSelector(),
              const SizedBox(height: 24),

              _buildInputField("비밀번호", _pwController, "비밀번호를 설정하세요", isObscure: true),
              
              const SizedBox(height: 56),
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI 컴포넌트 ---

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _tossTextSecondary)),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text, bool isObscure = false}) {
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

  Widget _buildDeptSelector() {
    return InkWell(
      onTap: _showDeptPicker,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: _tossGreyBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDept ?? "학과를 선택해 주세요",
              style: TextStyle(
                color: _selectedDept == null ? _tossHint : _tossTextPrimary,
                fontSize: 15,
                fontWeight: _selectedDept == null ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: _tossHint),
          ],
        ),
      ),
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
          disabledBackgroundColor: _tossBlue.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: _isLoading 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _tossBlue, width: 1.5),
      ),
    );
  } 
}