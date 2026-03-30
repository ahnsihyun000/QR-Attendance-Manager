import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart'; // 모델 위치 주의!

// =================================================================
// 🚨 1. 관리자 전용 구역: 관리자 로그인 화면
// =================================================================

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  void _tryLogin() {
    if (idController.text == "admin" && pwController.text == "1234") {
      // 💡 무한 루프 버그 해결! 이제 AdminHomePage로 정상 이동합니다.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomePage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("ID 또는 비밀번호가 틀렸습니다.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("관리자 로그인"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "QR 출석 관리 시스템",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: "관리자 ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: pwController,
              decoration: const InputDecoration(
                labelText: "비밀번호",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _tryLogin,
                child: const Text("로그인"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// 🚨 2. 관리자 메인 화면 (탭바)
// =================================================================
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const QRScannerPage(),
    const AttendanceListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'QR 스캔',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            label: '출석 명단',
          ),
        ],
      ),
    );
  }
}

// =================================================================
// 🚨 3. 대시보드 내 QR 스캔 페이지
// =================================================================
class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool isProcessing = false;

  Future<void> _handleAttendance(String code) async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    try {
      final newRecord = AttendanceModel(
        eventId: "CAPSTONE_2026",
        userUid: "user_${DateTime.now().millisecondsSinceEpoch}",
        userName: "방문객_${code.length > 4 ? code.substring(0, 4) : code}",
        timestamp: DateTime.now(),
        status: "출석 완료",
      );

      await FirebaseFirestore.instance
          .collection('attendance')
          .add(newRecord.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("출석 완료: $code"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR 출석 스캐너"), centerTitle: true),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              if (barcode.rawValue != null) {
                _handleAttendance(barcode.rawValue!);
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (isProcessing) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

// =================================================================
// 🚨 4. 대시보드 내 실시간 출석 명단 페이지
// =================================================================
class AttendanceListPage extends StatelessWidget {
  const AttendanceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("실시간 출석 명단"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.indigo],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "현재 총 출석",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      "${docs.length}명",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(data['userName'] ?? '익명'),
                        subtitle: Text("출석 상태 확인 됨"),
                        trailing: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
