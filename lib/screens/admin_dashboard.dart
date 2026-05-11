import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
//정유림
import 'package:fl_chart/fl_chart.dart';
import 'qr_scan_page.dart';
// [1] 관리자 로그인 화면 (Flat 디자인 & 파란색 버튼)
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  void _tryLogin() {
    if (idController.text.trim() == "admin" && pwController.text.trim() == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("ID 또는 비밀번호가 올바르지 않습니다."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      appBar: AppBar(
        title: const Text("관리자 인증"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person_rounded, size: 85, color: Color(0xFF2563EB)),
              const SizedBox(height: 24),
              const Text(
                "관리자 로그인",
                style: TextStyle(
                  fontSize: 30, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "관리를 위해 로그인이 필요합니다.", 
                style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
              ),
              const SizedBox(height: 48),

              // --- 🛡️ 그림자 없는 입력 폼 카드 ---
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  // Flat 디자인을 위해 boxShadow 제거됨
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: idController,
                      decoration: InputDecoration(
                        labelText: "관리자 ID",
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: pwController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "비밀번호",
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _tryLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text(
                          "인증 및 로그인", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("학생 출석 화면으로", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// [2] 관리자 대시보드 (탭 구성 및 UI 고도화)
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
 final List<Widget> _pages = [
  const AttendanceListPage(),
  const AnalyticsDashboardPage(),
  //정유림
  const QrScanPage(), // 👈 추가
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("관리자 대시보드", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          // ignore: deprecated_member_use
          child: Container(color: Colors.grey.withOpacity(0.1), height: 1.0),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: '출석 명단'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: '통계 분석'),
          //정유림
          BottomNavigationBarItem(
           icon: Icon(Icons.qr_code_scanner),
           label: 'QR 스캔', // 👈 추가
           ),
        ],
      ),
    );
  }
}
//정유림
class AttendancePieChart extends StatelessWidget {
  final int total;
  final int present;

  const AttendancePieChart({
    super.key,
    required this.total,
    required this.present,
  });

  @override
  Widget build(BuildContext context) {
    int absent = total - present;

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "출석 통계",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: present.toDouble(),
                  title: "참석\n$present",
                  color: Colors.blue,
                  radius: 80,
                  titleStyle: const TextStyle(color: Colors.white),
                ),
                PieChartSectionData(
                  value: absent.toDouble(),
                  title: "불참\n$absent",
                  color: Colors.redAccent,
                  radius: 80,
                  titleStyle: const TextStyle(color: Colors.white),
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ],
    );
  }
}

// [3] 출석 명단 리스트 (현황판 추가 버전)
//신청자 명단 비교리스트 추가(정유림)
class AttendanceListPage extends StatefulWidget {
  const AttendanceListPage({super.key});

  @override
  State<AttendanceListPage> createState() => _AttendanceListPageState();
}

class _AttendanceListPageState extends State<AttendanceListPage> {

  // 전체 신청자 + 출석 비교
  Future<List<Map<String, dynamic>>> loadCombinedList() async {
    var attendance = await DatabaseService().getAttendance();
    var applicants = await DatabaseService().getApplicants();
    print("attendance: $attendance");
print("applicants: $applicants");

    List<Map<String, dynamic>> result = applicants.map((applicant) {
      bool isPresent = attendance.any(
      (a) => (a['userName'] ?? '').trim() == (applicant['name'] ?? '').trim()
    );
      return {
        'name': applicant['name'],
        'studentId': applicant['studentId'],
        'status': isPresent ? "출석" : "미출석",
      };
    }).toList();

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('attendance').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));

        final docs = snapshot.data!.docs;

        return CustomScrollView(
          slivers: [
            // 실시간 출석 현황
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("현재 총 출석 인원", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text("${docs.length} 명", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),

            // 실시간 출석 리스트
            docs.isEmpty 
              ? const SliverFillRemaining(child: Center(child: Text("기록된 출석 데이터가 없습니다.")))
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0.5,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              // ignore: deprecated_member_use
                              backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                              child: const Icon(Icons.person, color: Color(0xFF2563EB)),
                            ),
                            title: Text("${data['userName'] ?? '이름 없음'} [${data['studentId'] ?? '-'}]", style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${data['department'] ?? '학과 미지정'}"),
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                          ),
                        );
                      },
                      childCount: docs.length,
                    ),
                  ),
                ),

            // 전체 신청자 출석 현황(정유림)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: const Text(
                  "👥 전체 신청자 출석 현황",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: loadCombinedList(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));

                  final combinedList = snapshot.data!;

                  return Column(
                    children: combinedList.map((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0.5,
                        child: ListTile(
                          title: Text("${item['name']} (${item['studentId']})"),
                          trailing: Text(
                            item['status'],
                            style: TextStyle(color: item['status'] == "출석" ? Colors.green : Colors.red),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
  

 

// [4] 통계 분석 (정유림)
class AnalyticsDashboardPage extends StatelessWidget {
  const AnalyticsDashboardPage({super.key});

  Future<List<Map<String, dynamic>>> loadCombinedList() async {
    var attendance = await DatabaseService().getAttendance();
    var applicants = await DatabaseService().getApplicants();

    return applicants.map((applicant) {
      bool isPresent = attendance.any(
        (a) => (a['userName'] ?? '').trim() == (applicant['name'] ?? '').trim()
      );

      return {
        'status': isPresent ? "출석" : "미출석",
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loadCombinedList(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = snapshot.data!;

        int total = list.length;
        int present = list.where((e) => e['status'] == "출석").length;

        return Center(
          child: AttendancePieChart(
            total: total,
            present: present,
          ),
        );
      },
    );
  }
}
