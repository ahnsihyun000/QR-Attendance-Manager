import 'package:flutter/material.dart';
import 'admin_attendance_list.dart';
import 'pre_registration_list.dart'; // 중복 임포트 제거함
import 'login_screen.dart';
import 'admin_qr_camera_tab.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;

  // 스타일 상수 통합
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossGreyText = Color(0xFF8B95A1);
  //static const _tossBlack = Color(0xFF191F28);
  static const _tossBg = Color(0xFFF2F4F6);

  // 탭 전환 메서드 (자식 위젯에서 호출 가능하도록)
  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  // 페이지 리스트를 getter로 관리하여 코드 가독성 향상
  List<Widget> get _pages => [
        AdminHomeTab(onTabChange: _changeTab), // 콜백 전달
        const AdminAttendanceList(),
        const AdminQrCameraTab(),
        const Center(
          child: Text("통계 화면 준비 중", style: TextStyle(color: _tossGreyText)),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        // 0번 탭이 아니면 홈으로, 홈이면 알림
        if (_currentIndex != 0) {
          _changeTab(0);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("로그아웃 버튼을 이용해 주세요."),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _tossBg,
        body: SafeArea(child: _pages[_currentIndex]),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: _currentIndex,
        selectedItemColor: _tossBlue,
        unselectedItemColor: _tossGreyText,
        type: BottomNavigationBarType.fixed,
        onTap: _changeTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.fact_check_rounded), label: "출석부"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: "QR카메라"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "통계"),
        ],
      ),
    );
  }
}

// --- 홈 탭 클래스 (정리 버전) ---
class AdminHomeTab extends StatelessWidget {
  final Function(int) onTabChange; // 탭 전환을 위한 콜백

  const AdminHomeTab({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text("무엇을 확인해 볼까요?",
              style: TextStyle(color: Color(0xFF8B95A1), fontSize: 16, fontWeight: FontWeight.w500)),
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
                title: "사전 신청",
                subtitle: "명단 확인",
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFFFF9800),
                iconBgColor: const Color(0xFFFFF3E0),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PreRegistrationScreen()),
                ),
              ),
              _buildTossCard(
                title: "실시간 출석",
                subtitle: "QR 현황",
                icon: Icons.qr_code_scanner_rounded,
                iconColor: const Color(0xFF3182F6),
                iconBgColor: const Color(0xFFE8F3FF),
                onTap: () => onTabChange(1), // 부모에게 1번 탭으로 가라고 알림
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("관리자 대시보드",
              style: TextStyle(color: Color(0xFF191F28), fontSize: 24, fontWeight: FontWeight.w800)),
          IconButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            ),
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF8B95A1)),
          ),
        ],
      ),
    );
  }

  Widget _buildTossCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return InkWell( // 터치 피드백을 위해 GestureDetector 대신 InkWell 추천
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
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
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191F28))),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF8B95A1))),
          ],
        ),
      ),
    );
  }
}