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
      ),
    );
  }

  // 학과 선택 모달
  void _showDeptPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // 높이 조절 가능하게
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

  // 회원가입 로직
  Future<void> _register() async {
    final String id = _idController.text.trim();
    final String pw = _pwController.text.trim();
    final String name = _nameController.text.trim();

    if (id.isEmpty || pw.isEmpty || name.isEmpty || _selectedDept == null) {
      _showSnackBar("모든 정보를 입력해 주세요.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 학번 중복 체크 (선택 사항)
      final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (doc.exists) {
        _showSnackBar("이미 가입된 학번입니다.");
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(id).set({
        'studentId': id,
        'password': pw,
        'name': name,
        'department': _selectedDept,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSnackBar("가입을 축하합니다! 🎉");
      Navigator.pop(context); // 로그인 화면으로 이동
    } catch (e) {
      _showSnackBar("가입에 실패했습니다. 다시 시도해 주세요.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

              _buildInputField("학번", _idController, "학번 7자리를 입력하세요", keyboardType: TextInputType.number),
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
          disabledBackgroundColor: _tossBlue.withValues(alpha: 0.6),
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