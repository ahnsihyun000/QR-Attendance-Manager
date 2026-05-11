//정유림

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AdminQrCameraTab extends StatefulWidget {
  const AdminQrCameraTab({super.key});

  @override
  State<AdminQrCameraTab> createState() => _AdminQrCameraTabState();
}

class _AdminQrCameraTabState extends State<AdminQrCameraTab> {
  bool _isProcessing = false;

  Future<void> _saveAttendance(String rawValue) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // QR 형식:
      // UID:20240001, NAME:홍길동

      final parts = rawValue.split(',');

      if (parts.length < 2) {
        throw Exception('잘못된 QR 형식');
      }

      final uid = parts[0].replaceAll('UID:', '').trim();
      final name = parts[1].replaceAll('NAME:', '').trim();

      await FirebaseFirestore.instance
          .collection('attendance')
          .add({
        'uid': uid,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('$name 출석 저장 완료'),
        ),
      );

      // 연속 스캔 방지
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('오류 발생: $e'),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('QR 출석 카메라'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;

              for (final barcode in barcodes) {
                final rawValue = barcode.rawValue;

                if (rawValue == null) continue;

                // 우리 앱 QR만 허용
                if (!rawValue.contains('UID:') ||
                    !rawValue.contains('NAME:')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('유효하지 않은 QR입니다'),
                    ),
                  );
                  return;
                }

                await _saveAttendance(rawValue);
                break;
              }
            },
          ),

          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  '학생 QR을 스캔하세요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '정보가 자동 저장됩니다',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
