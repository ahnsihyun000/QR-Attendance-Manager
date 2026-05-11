import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';
import 'qr_scan_screen.dart'; // 위에서 만든 파일 임포트
import 'admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  String? _selectedDept;

  final List<String> _departments = ['컴퓨터공학과', '게임공학과', '정보통신공학과', '인공지능학과'];

  Future<void> _login() async {
    final id = _idController.text.trim();
    final pw = _pwController.text.trim();

    if (id.isEmpty || pw.isEmpty || _selectedDept == null) return;

    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(id).get();

      if (!mounted) return;

      if (userDoc.exists && userDoc.data()!['password'] == pw && userDoc.data()!['department'] == _selectedDept) {
        String role = userDoc.data()!['role'] ?? 'student';

        if (role == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminScreen()));
        } else {
          // 여기서 'userData' 파라미터가 qr_scan_screen.dart와 연결됩니다.
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => QRScannerPage(userData: userDoc.data()!))
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("로그인 정보가 틀렸습니다.")));
      }
    } catch (e) {
      debugPrint("로그인 에러: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text("배재대 스마트 출석", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedDept,
              items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => _selectedDept = v),
              decoration: const InputDecoration(labelText: "학과 선택", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(controller: _idController, decoration: const InputDecoration(labelText: "학번", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _pwController, decoration: const InputDecoration(labelText: "비밀번호", border: OutlineInputBorder()), obscureText: true),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
              child: const Text("로그인"),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
              child: const Text("처음이신가요? 회원가입"),
            ),
          ],
        ),
      ),
    );
  }
}