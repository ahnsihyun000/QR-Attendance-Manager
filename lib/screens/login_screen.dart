import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';
import 'qr_scan_screen.dart'; // 위에서 만든 파일 임포트
import 'admin_screen.dart';
=======
// 1. 같은 폴더에 있으므로 파일명만 정확히 입력합니다.
import 'admin_dashboard.dart'; 
>>>>>>> d2db8d3d27b4f008696145395196e2784dd7244a

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
<<<<<<< HEAD
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
=======
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
>>>>>>> d2db8d3d27b4f008696145395196e2784dd7244a

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
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
=======
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            // --- 중앙 로그인 폼 ---
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // [수정] Icon을 Image.asset으로 교체
                    // school_logo.png 이미지를 assets/images/ 폴더에 넣고 pubspec.yaml에 등록해야 합니다.
                    Image.asset(
                      'assets/images/school_logo.png', // 이미지 경로
                      height: 160, // 아이콘 크기와 동일하게 설정
                      width: 160,
                      fit: BoxFit.contain, // 비율 유지
                    ),
                    const SizedBox(height: 20), // 간격 유지
                    const Text(
                      "배재대학교",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),

                    // 아이디 입력창
                    TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        labelText: "아이디(학번)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 비밀번호 입력창
                    TextField(
                      controller: _pwController,
                      obscureText: true, // 비밀번호 가리기
                      decoration: InputDecoration(
                        labelText: "비밀번호",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // 로그인 버튼 클릭 시 실행될 로직
                          debugPrint("로그인 시도 아이디: ${_idController.text}");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("로그인", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    // --- 회원가입 연결 버튼 ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("계정이 없으신가요?"),
                        TextButton(
                          onPressed: () {
                            // 아래 정의된 회원가입 페이지로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpPage()),
                            );
                          },
                          child: const Text("회원가입", 
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- 우측 하단 관리자 로그인 버튼 ---
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminLoginScreen()), 
                  );
                },
                label: const Text(""),
                icon: const Icon(Icons.settings),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black54,
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 별도의 파일로 분리하기 전까지 사용할 회원가입 화면 ---
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: "이름")),
            const SizedBox(height: 15),
            const TextField(decoration: InputDecoration(labelText: "학번")),
            const SizedBox(height: 15),
            const TextField(decoration: InputDecoration(labelText: "비밀번호"), obscureText: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // 가입 완료 후 이전 화면(로그인창)으로 돌아가기
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("회원가입이 요청되었습니다.")),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("가입하기", style: TextStyle(color: Colors.white)),
              ),
>>>>>>> d2db8d3d27b4f008696145395196e2784dd7244a
            ),
          ],
        ),
      ),
    );
  }
}