import 'package:flutter/material.dart';
// 관리자 로그인 화면이 있는 파일을 불러옵니다 (경로는 팀장님 폴더 구조에 맞게 수정하세요!)
import 'admin_dashboard.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("학생 출석 체크"), centerTitle: true),
      body: Stack(
        children: [
          // 1. 일반 학생들을 위한 메인 화면 (민수 님이 앞으로 꾸밀 공간)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "환영합니다!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text("여기는 일반 학생/참여자용 화면입니다."),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 나중에 고유 QR 생성이나 정보 입력 로직 연결
                  },
                  child: const Text("내 QR 코드 생성하기"),
                ),
              ],
            ),
          ),

          // 2. 🕵️‍♂️ 오른쪽 아래 숨겨진 관리자 로그인 버튼 (이스터에그)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              // 버튼을 두 번 연속으로 따닥! 눌러야 넘어가게 안전장치 설정
              onDoubleTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AdminLoginScreen(), // admin_dashboard.dart 안에 있는 클래스
                  ),
                );
              },
              child: Container(
                width: 80,
                height: 80,
                color: Colors
                    .transparent, // 👈 투명해서 눈에 안 보임! (개발 중엔 Colors.red 등으로 바꿔서 확인하세요)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
