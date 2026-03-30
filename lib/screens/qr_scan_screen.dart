import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/database_service.dart';
import '../models/attendance_model.dart';

class QRScanScreen extends StatefulWidget {
  final String eventId; // 현재 진행 중인 행사 ID (예: "capstone_2026")

  const QRScanScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  final DatabaseService _dbService = DatabaseService();
  bool isScanning = true; // 중복 스캔 방지용 락(Lock)

  @override
  Widget build(BuildContext context) {
    // 💡 날아갔던 Scaffold와 AppBar가 다시 돌아왔습니다!
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 출석 스캐너'),
        actions: [
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.bolt), // 심플한 번개 플래시 아이콘
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (!isScanning) return; // 스캔 처리 중이면 무시 (연속 스캔 방지)

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? scannedUid = barcode.rawValue;

                if (scannedUid != null) {
                  setState(() => isScanning = false); // 스캔 멈춤

                  // 모델 생성 (팀원이 추가한 필수 항목인 이름과 시간을 채워줍니다!)
                  AttendanceModel newAttendance = AttendanceModel(
                    eventId: widget.eventId,
                    userUid: scannedUid,
                    userName: '스캔된 학생', // 👈 팀원이 필수로 만들어둬서 임시로 넣은 값
                    timestamp: DateTime.now(), // 👈 스캔한 현재 시간 (필수)
                    status: '사전 등록',
                  );

                  String result = await _dbService.recordAttendance(
                    newAttendance,
                  );
                  _showResultSnackBar(result);

                  Future.delayed(const Duration(milliseconds: 1500), () {
                    if (mounted) {
                      setState(() => isScanning = true);
                    }
                  });
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResultSnackBar(String result) {
    String message = '';
    Color bgColor = Colors.black;

    if (result == 'success') {
      message = '✅ 출석 처리 완료!';
      bgColor = Colors.green;
    } else if (result == 'already_checked') {
      message = '⚠️ 이미 출석 완료된 학생입니다.';
      bgColor = Colors.orange;
    } else if (result == 'not_registered') {
      message = '❌ 사전 신청 명단에 없습니다.';
      bgColor = Colors.red;
    } else {
      message = '오류 발생: 다시 스캔해주세요.';
      bgColor = Colors.grey;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
