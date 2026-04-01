import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// [1] QR 스캐너 화면
class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool isProcessing = false; // 중복 스캔 방지 플래그

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("출석 QR 스캔"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) async {
              if (isProcessing) return; // 이미 처리 중이면 무시

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                final String qrCode = barcodes.first.rawValue!;
                
                setState(() => isProcessing = true);
                
                // 스캔 성공 시 정보 등록 페이지로 이동
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrationPage(qrData: qrCode),
                  ),
                );
                
                // 돌아오면 다시 스캔 가능하도록 설정
                setState(() => isProcessing = false);
              }
            },
          ),
          // QR 스캔 가이드 라인 (시각적 효과)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// [2] 정보 등록 페이지 (스캔 후 학번/이름 입력)
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

  // 배재대학교 학과 리스트 (필요에 따라 수정)
  final List<String> _paiChaiDepts = [
    '컴퓨터공학과',
    '정보통신공학과',
    'AI소프트웨어공학과',
    '간호학과',
    '경영학과',
    '행정학과',
    '게임공학과'
  ];

  // 데이터 전송 함수
  Future<void> _submitData() async {
    // 유효성 검사
    if (_nameController.text.trim().isEmpty || 
        _idController.text.trim().isEmpty || 
        _selectedDept == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 정보를 정확히 입력해주세요.")),
      );
      return;
    }

    try {
      // Firebase Firestore에 저장
      await FirebaseFirestore.instance.collection('attendance').add({
        'userName': _nameController.text.trim(),
        'studentId': _idController.text.trim(),
        'department': _selectedDept,
        'qrData': widget.qrData,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      
      // 완료 알림 후 메인화면으로 돌아가기
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("출석이 완료되었습니다!"), backgroundColor: Colors.green),
      );
      
      // 등록 페이지 닫고 스캐너 페이지까지 닫아서 메인으로 이동
      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류가 발생했습니다: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("출석 정보 입력")),
      body: SingleChildScrollView( // 키보드 올라올 때 가려짐 방지
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("성함", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: "이름을 입력하세요"),
            ),
            const SizedBox(height: 20),
            
            const Text("학번", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "학번을 입력하세요"),
            ),
            const SizedBox(height: 20),
            
            const Text("학과", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              hint: const Text("학과를 선택하세요"),
              initialValue: _selectedDept,
              items: _paiChaiDepts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() => _selectedDept = val),
              decoration: const InputDecoration(contentPadding: EdgeInsets.zero),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("출석 완료", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}