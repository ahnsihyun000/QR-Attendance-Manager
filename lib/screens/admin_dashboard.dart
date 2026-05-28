import 'package:flutter/material.dart';
import 'admin_login.dart';
import 'admin_qr_camera_tab.dart';
import 'admin_statistics_tab.dart';
import 'pre_registration_list.dart';
import 'admin_attendance_list.dart';
import 'admin_user_approval.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // 하단 탭바에서 현재 선택된 화면 인덱스입니다.
  int _currentIndex = 0;

  // 로그아웃 처리 중 카메라 탭이 계속 살아있지 않도록 제어합니다.
  bool _isLoggingOut = false;

  static const _tossBlue = Color(0xFF3182F6);
  static const _tossGreyText = Color(0xFF8B95A1);
  static const _tossBg = Color(0xFFF2F4F6);

  // IndexedStack에 들어갈 관리자 주요 화면 목록입니다.
  // IndexedStack을 사용하면 탭을 바꿔도 화면 상태가 갑자기 초기화되지 않습니다.
  List<Widget> get _pages => [
    AdminHomeTab(onLogoutPress: () => _showLogoutDialog(context)),
    const AdminAttendanceList(),
    (!_isLoggingOut && _currentIndex == 2)
        ? const AdminQrCameraTab()
        : const SizedBox.shrink(),
    const AdminStatisticsTab(),
  ];

  void _changeTab(int index) {
    // 로그아웃 중에는 탭 이동을 막아 화면 전환 충돌을 방지합니다.
    if (_isLoggingOut) return;
    setState(() => _currentIndex = index);
  }

  // 관리자 로그아웃 여부를 한 번 더 확인하는 팝업입니다.
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "로그아웃",
          style: TextStyle(
            color: Color(0xFF191F28),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: const Text(
          "로그아웃 하시겠습니까?",
          style: TextStyle(color: Color(0xFF191F28), fontSize: 15),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              "취소",
              style: TextStyle(
                color: Color(0xFF8B95A1),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // 카메라가 켜진 탭에서 로그아웃할 때 컨트롤러 충돌이 생기지 않도록 홈 탭으로 먼저 돌립니다.
              setState(() {
                _isLoggingOut = true;
                _currentIndex = 0;
              });

              await Future.delayed(const Duration(milliseconds: 350));

              if (!context.mounted) return;

              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AdminLoginScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            child,
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text(
              "로그아웃",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 관리자 화면에서는 시스템 뒤로가기 대신 홈 탭 이동 또는 로그아웃 안내를 제공합니다.
        if (_currentIndex != 0) {
          _changeTab(0);
        } else {
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
          child: IndexedStack(index: _currentIndex, children: _pages),
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
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: _currentIndex,
        selectedItemColor: _tossBlue,
        unselectedItemColor: _tossGreyText,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: _changeTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "홈"),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_rounded),
            label: "출석부",
          ),
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
    );
  }
}

/// 관리자 홈에서 각 기능 화면으로 이동하는 카드 메뉴입니다.
class AdminHomeTab extends StatelessWidget {
  final VoidCallback onLogoutPress;

  const AdminHomeTab({super.key, required this.onLogoutPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
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
                onTap: () {
                  // 사전 신청자 목록을 Firestore에서 읽어 보여주는 화면으로 이동합니다.
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
                icon: Icons.fact_check_rounded,
                iconColor: const Color(0xFF00AD5C),
                iconBgColor: const Color(0xFFE5F7ED),
                onTap: () {
                  // QR 스캔으로 저장된 attendance 컬렉션의 출석 기록을 확인합니다.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminAttendanceList(),
                    ),
                  );
                },
              ),
              _buildTossCard(
                context,
                title: "QR 스캔",
                subtitle: "카메라 연동",
                icon: Icons.qr_code_scanner_rounded,
                iconColor: const Color(0xFF3182F6),
                iconBgColor: const Color(0xFFE8F3FF),
                onTap: () {
                  // 카메라를 열어 학생 QR을 스캔하고 출석 처리하는 화면입니다.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminQrCameraTab(),
                    ),
                  );
                },
              ),
              _buildTossCard(
                context,
                title: "출석 통계",
                subtitle: "실시간 그래프",
                icon: Icons.bar_chart_rounded,
                iconColor: const Color(0xFFFF6B6B),
                iconBgColor: const Color(0xFFFFEAEA),
                onTap: () {
                  // 사전 신청자 수와 출석자 수를 비교해 행사별 출석률을 보여줍니다.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminStatisticsTab(),
                    ),
                  );
                },
              ),
              _buildTossCard(
                context,
                title: "가입자 승인",
                subtitle: "신규 승인 대기",
                icon: Icons.person_add_alt_1_rounded,
                iconColor: const Color(0xFF6B66FF),
                iconBgColor: const Color(0xFFF0F0FF),
                onTap: () {
                  // users 컬렉션의 승인 상태를 관리하는 화면입니다.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminUserApprovalScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
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
            onPressed: onLogoutPress,
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF8B95A1)),
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
    // 관리자 기능을 동일한 형태의 카드로 보여주기 위한 재사용 UI입니다.
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191F28),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8B95A1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
