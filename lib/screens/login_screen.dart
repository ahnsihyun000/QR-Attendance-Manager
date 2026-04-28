import 'package:flutter/material.dart';
// 1. 같은 폴더에 있으므로 파일명만 정확히 입력합니다.
import 'admin_dashboard.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const Icon(Icons.school, size: 80, color: Color(0xFF2563EB)),
                    const SizedBox(height: 10),
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
                  // ⭐ [중요] AdminDashboard가 admin_dashboard.dart의 클래스 이름과 같아야 합니다.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminLoginScreen()), 
                  );
                },
                label: const Text("관리자 로그인"),
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
            ),
          ],
        ),
      ),
    );
  }
}