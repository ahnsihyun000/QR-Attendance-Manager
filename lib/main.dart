import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainPage(), 
  ));
}

// ---------------------------------------------------------
// [0] 메인 페이지 (사용자용)
// ---------------------------------------------------------
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  // 관리자 로그인 팝업 호출 함수
  void _showAdminLogin(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("관리자 인증"),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "비밀번호를 입력하세요",
            icon: Icon(Icons.lock),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
          ElevatedButton(
            onPressed: () {
              // 💡 초기 비밀번호는 '1234'로 설정되어 있습니다.
              if (passwordController.text == '1234') {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")),
                );
              }
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack( // 👈 우측 하단 버튼 배치를 위해 Stack 사용
          children: [
            // 중앙 메인 콘텐츠
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, size: 100, color: Colors.blueAccent),
                    const SizedBox(height: 20),
                    const Text(
                      "배재대학교",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "QR 출석관리 시스템",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const QRScannerPage()),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("QR 코드 스캔으로 가기", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "© 2024 Pai Chai University. All rights reserved.",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            // ⚙️ 우측 하단 관리자 설정 버튼 (톱니바퀴)
            Positioned(
              right: 20,
              bottom: 20,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.grey, size: 32),
                onPressed: () => _showAdminLogin(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// [1] QR 스캐너 페이지
// ---------------------------------------------------------
class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});
  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("출석 스캐너"), centerTitle: true),
      body: MobileScanner(
        onDetect: (capture) async {
          if (isProcessing) return;
          final barcode = capture.barcodes.first;
          if (barcode.rawValue != null) {
            setState(() => isProcessing = true);
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegistrationPage(qrData: barcode.rawValue!)),
            );
            setState(() => isProcessing = false);
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------
// [2] 관리자 대시보드 (탭 메뉴 구성)
// ---------------------------------------------------------
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const AttendanceListPage(), // 출석 명단 창
    const AnalyticsDashboardPage(), // 통계 대시보드 창
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("관리자 모드"),
        centerTitle: true,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '출석 명단'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: '통계 분석'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// [3] 출석 명단 탭 (실시간 Firestore 연동)
// ---------------------------------------------------------
class AttendanceListPage extends StatelessWidget {
  const AttendanceListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('attendance').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("아직 출석 기록이 없습니다."));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text("${data['userName']} [${data['studentId']}]", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${data['department']}\n${data['qrData']}"),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------
// [4] 통계 분석 탭 (새로 추가한 빈 대시보드)
// ---------------------------------------------------------
class AnalyticsDashboardPage extends StatelessWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.insights, size: 80, color: Colors.blueAccent),
          SizedBox(height: 16),
          Text(
            "실시간 통계 분석",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "데이터를 분석하여 차트를 구성할 예정입니다.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// [5] 학생 정보 등록 페이지 (기존 유지)
// ---------------------------------------------------------
class RegistrationPage extends StatefulWidget {
  final String qrData;
  const RegistrationPage({super.key, required this.qrData});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  String? _selectedDept;
  bool _isSaving = false;

  final List<String> _paiChaiDepts = [
    '국어국문학과', '영어영문학과', '일어일문학과', '중국학과', '행정학과', '경찰학과', 
    '경영학과', '회계학과', '무역학과', '관광경영학과', '컴퓨터공학과', '정보통신공학과', 
    '전자공학과', '건축학과', '토목환경공학과', '수학과', '물리학과', '화학과', 
    '음악학과', '미술학과', '공연예술학과', '간호학과', '사회복지학과'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("출석 정보 등록")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("성함", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "이름 입력"),
            ),
            const SizedBox(height: 20),
            const Text("학번", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "학번 8자리 입력"),
            ),
            const SizedBox(height: 20),
            const Text("학과 선택", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              menuMaxHeight: 350,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text("학과를 선택하세요"),
              value: _selectedDept,
              items: _paiChaiDepts.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() { _selectedDept = newValue; });
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isSaving ? null : _submitData,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: _isSaving 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("최종 출석 완료"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitData() async {
    if (_nameController.text.isEmpty || _idController.text.isEmpty || _selectedDept == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("모든 정보를 입력해주세요!")));
      return;
    }
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('attendance').add({
        'userName': _nameController.text.trim(),
        'studentId': _idController.text.trim(),
        'department': _selectedDept,
        'qrData': widget.qrData,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("출석 등록 성공!")));
      }
    } catch (e) {
      debugPrint("오류: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}