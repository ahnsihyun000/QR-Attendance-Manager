import 'package:flutter/material.dart';
import 'admin_attendance_list.dart';
import 'pre_registration_list.dart';
import 'login_screen.dart';
//정유림
import 'admin_qr_camera_tab.dart';
import 'package:qr_attendance_manager/screens/pre_registration_list.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
  const AdminHomeTab(),
  const AdminAttendanceList(),
  //정유림
  const AdminQrCameraTab(),
  const Center(
    child: Text(
      "통계 화면 준비 중",
      style: TextStyle(color: Color(0xFF8B95A1)),
    ),
  ),
];
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 시스템 뒤로가기로 앱이 그냥 꺼지는 건 일단 방지
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // [수정 포인트] 출석부(1번)나 통계(2번) 탭에 있을 때 뒤로가기를 누르면 홈(0번)으로 보냄
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        } else {
          // 홈 탭일 때는 아무것도 안 함 (혹은 종료 팝업을 띄울 수 있음)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("로그아웃 버튼을 이용해 주세요."),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F4F6),
        body: SafeArea(child: _pages[_currentIndex]),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            currentIndex: _currentIndex,
            selectedItemColor: const Color(0xFF3182F6),
            unselectedItemColor: const Color(0xFF8B95A1),
            type: BottomNavigationBarType.fixed,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: "홈",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fact_check_rounded),
                label: "출석부",
              ),
              //정유림
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner_rounded),
                label: "QR카메라",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded),
                label: "통계",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 홈 탭 클래스는 기존과 동일 (생략 없이 그대로 유지)
class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "관리자 대시보드",
                style: TextStyle(
                  color: Color(0xFF191F28),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFF8B95A1),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "무엇을 확인해 볼까요?",
            style: TextStyle(
              color: Color(0xFF8B95A1),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: [
              _buildTossCard(
                context,
                title: "사전 신청",
                subtitle: "명단 확인",
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFFFF9800),
                iconBgColor: const Color(0xFFFFF3E0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreRegistrationScreen(),
                    ),
                  );
                },
              ),
              _buildTossCard(
                context,
                title: "실시간 출석",
                subtitle: "QR 현황",
                icon: Icons.qr_code_scanner_rounded,
                iconColor: const Color(0xFF3182F6),
                iconBgColor: const Color(0xFFE8F3FF),
                onTap: () {
                  // 홈 탭의 대시보드에서 이 카드를 누르면 탭 번호를 바꿔서 바로 이동하게 수정
                  final state = context
                      .findAncestorStateOfType<_AdminDashboardPageState>();
                  state?.setState(() => state._currentIndex = 1);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTossCard(
    context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191F28),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8B95A1)),
            ),
          ],
        ),
      ),
    );
  }
}
