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
  final _adminKeyController = TextEditingController();
  String? _selectedDept;
  String _role = 'student';
  final String adminSecretKey = "pcu1234";

  Future<void> _register() async {
    if (_idController.text.isEmpty || _nameController.text.isEmpty || _selectedDept == null) return;

    if (_role == 'admin' && _adminKeyController.text != adminSecretKey) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("관리자 인증 코드가 틀렸습니다.")));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(_idController.text).set({
        'studentId': _idController.text,
        'password': _pwController.text,
        'name': _nameController.text,
        'department': _selectedDept,
        'role': _role,
      });
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "이름")),
            TextField(controller: _idController, decoration: const InputDecoration(labelText: "학번")),
            TextField(controller: _pwController, decoration: const InputDecoration(labelText: "비밀번호"), obscureText: true),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio(value: 'student', groupValue: _role, onChanged: (v) => setState(() => _role = v!)),
                const Text("학생"),
                const SizedBox(width: 20),
                Radio(value: 'admin', groupValue: _role, onChanged: (v) => setState(() => _role = v!)),
                const Text("관리자"),
              ],
            ),
            if (_role == 'admin')
              TextField(controller: _adminKeyController, decoration: const InputDecoration(labelText: "관리자 인증 코드"), obscureText: true),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("가입하기"),
            ),
          ],
        ),
      ),
    );
  }
}