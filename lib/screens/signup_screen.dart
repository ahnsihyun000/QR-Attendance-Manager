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

  // 스타일 상수 (Toss Style Colors)
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDeptPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "학과를 선택해 주세요",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _tossTextPrimary),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: AppConstants.departments.length,
                  itemBuilder: (context, index) {
                    final dept = AppConstants.departments[index];
                    return ListTile(
                      title: Text(dept, style: const TextStyle(fontSize: 16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                      onTap: () {
                        setState(() => _selectedDept = dept);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _register() async {
    final String id = _idController.text.trim();
    final String pw = _pwController.text.trim();
    final String name = _nameController.text.trim();

    if (id.isEmpty || pw.isEmpty || name.isEmpty || _selectedDept == null) {
      _showSnackBar("모든 정보를 입력해 주세요.");
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(id).set({
        'studentId': id,
        'password': pw,
        'name': name,
        'department': _selectedDept,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      _showSnackBar("반가워요! 가입이 완료되었습니다.");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("가입에 실패했습니다.");
    }
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
              const Text(
                "새로운 시작,\n정보를 입력해 주세요",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _tossTextPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // 중복 코드를 메서드로 대체
              _buildInputField("이름", _nameController, "실명을 입력하세요"),
              const SizedBox(height: 20),

              _buildInputField("학번", _idController, "학번 7자리를 입력하세요", keyboardType: TextInputType.number),
              const SizedBox(height: 20),

              _buildLabel("소속 학과"),
              _buildDeptSelector(),
              const SizedBox(height: 20),

              _buildInputField("비밀번호", _pwController, "비밀번호를 설정하세요", isObscure: true),
              
              const SizedBox(height: 50),
              _buildSubmitButton(),
              const SizedBox(height: 40), // 하단 여유 공간
            ],
          ),
        ),
      ),
    );
  }

  // --- 재사용 가능한 위젯 메서드들 ---

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _tossTextSecondary),
      ),
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
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildDeptSelector() {
    return InkWell(
      onTap: _showDeptPicker,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: _tossGreyBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDept ?? "학과를 선택해 주세요",
              style: TextStyle(
                color: _selectedDept == null ? _tossHint : _tossTextPrimary,
                fontSize: 15,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF8B95A1)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _register,
      style: ElevatedButton.styleFrom(
        backgroundColor: _tossBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: const Text("가입하기"),
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