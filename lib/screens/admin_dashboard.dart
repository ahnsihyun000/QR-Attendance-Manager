import 'package:flutter/material.dart';
import 'admin_attendance_list.dart';
import 'pre_registration_list.dart'; 
import 'admin_login.dart';
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
  static const _tossBg = Color(0xFFF2F4F6);
  //static const _tossBlack = Color(0xFF191F28);

  // 탭 전환 메서드
  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  // 페이지 리스트를 getter로 관리
  List<Widget> get _pages => [
        AdminHomeTab(onTabChange: _changeTab),
        const AdminAttendanceList(),
        const AdminQrCameraTab(),
        const Center(
          child: Text("통계 화면 준비 중", style: TextStyle(color: _tossGreyText)),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 시스템 뒤로가기 기본 동작 방지
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        if (_currentIndex != 0) {
          _changeTab(0); // 다른 탭이면 홈으로 이동
        } else {
          // 홈 탭이면 로그아웃 유도 메시지
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("로그아웃 버튼을 이용해 주세요."),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(20),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _tossBg,
        body: SafeArea(
          child: IndexedStack( // 탭 상태 유지를 위해 IndexedStack 사용
            index: _currentIndex,
            children: _pages,
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10, 
            offset: const Offset(0, -5)
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: _currentIndex,
        selectedItemColor: _tossBlue,
        unselectedItemColor: _tossGreyText,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
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

// --- 홈 탭 클래스 ---
class AdminHomeTab extends StatelessWidget {
  final Function(int) onTabChange;

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
        const SizedBox(height: 24),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              _buildTossCard(
                context,
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
                context,
                title: "실시간 출석",
                subtitle: "QR 현황",
                icon: Icons.qr_code_scanner_rounded,
                iconColor: const Color(0xFF3182F6),
                iconBgColor: const Color(0xFFE8F3FF),
                onTap: () => onTabChange(1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("관리자 대시보드",
              style: TextStyle(color: Color(0xFF191F28), fontSize: 24, fontWeight: FontWeight.w800)),
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF8B95A1)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("로그아웃", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("인증 화면으로 돌아가시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("취소", style: TextStyle(color: Color(0xFF8B95A1)))
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                (route) => false,
              );
            },
            child: const Text("확인", style: TextStyle(color: Color(0xFF3182F6), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTossCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF191F28))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF8B95A1))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}