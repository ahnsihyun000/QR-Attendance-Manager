import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'models/attendance_model.dart'; // 출석 데이터 모델 정의
// import 'package:permission_handler/permission_handler.dart';

void main() async {
  // Flutter 엔진 및 비동기 서비스 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 서비스 초기화 (Default 옵션 사용)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 띠 제거
      home: QRScannerScreen(),
    ),
  );
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String? qrCode; // 인식된 QR 코드 값
  bool isProcessing = false; // 중복 스캔 방지 플래그

  /// QR 스캔 데이터를 Firestore에 기록하는 비동기 함수
  Future<void> _handleAttendance(String code) async {
    if (isProcessing) return; // 처리 중인 경우 중복 실행 차단

    setState(() => isProcessing = true);

    try {
      // 1. AttendanceModel 인스턴스 생성 (필드 값 설정)
      final newRecord = AttendanceModel(
        eventId: "CAPSTONE_2026_01",
        userUid: "test_user_01", // TODO: 인증 시스템 연동 후 UID 교체
        userName: "TestUser", // TODO: 유저 프로필 데이터 연동
        timestamp: DateTime.now(),
        status: "출석",
      );

      // 2. Firestore 'attendance' 컬렉션에 JSON 형태로 데이터 추가
      await FirebaseFirestore.instance
          .collection('attendance')
          .add(newRecord.toJson());

      // 시스템 로그 기록
      debugPrint("Firebase Write Success: $code");

      // 사용자 피드백 (SnackBar 표시)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("출석 정보가 서버에 기록되었습니다: $code"),
            backgroundColor: Colors.blueAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() => qrCode = code);
    } catch (e) {
      // 에러 핸들링 및 로그 기록
      debugPrint("Firebase Write Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("서버 통신 오류가 발생했습니다."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // 스캔 간격 조절 (3초 딜레이)
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 출석 관리 시스템'), // 공식적인 제목
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // QR 스캐너 뷰 영역
          Expanded(
            flex: 5,
            child: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && !isProcessing) {
                    _handleAttendance(barcode.rawValue!);
                  }
                }
              },
            ),
          ),
          // 상태 표시 영역
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 40,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    qrCode != null ? '최근 인식: $qrCode' : '스캔 대기 중...',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  if (isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: CircularProgressIndicator(), // 글자 대신 로딩 바 추가 (간지용)
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
