import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BulkAttendanceUploadScreen extends StatefulWidget {
  const BulkAttendanceUploadScreen({super.key});

  @override
  State<BulkAttendanceUploadScreen> createState() =>
      _BulkAttendanceUploadScreenState();
}

class _BulkAttendanceUploadScreenState
    extends State<BulkAttendanceUploadScreen> {
  final _eventIdController = TextEditingController(text: 'event01'); // 기본값 세팅
  final _rosterController = TextEditingController();
  bool _isUploading = false;

  // 스타일 상수 (Toss Style)
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossBg = Color(0xFFF2F4F6);
  static const _tossBlack = Color(0xFF191F28);
  static const _tossGrey = Color(0xFF8B95A1);

  List<_RosterRow> _parseRoster(String rawText) {
    final rowsByStudentId = <String, _RosterRow>{};
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);

    for (final line in lines) {
      final parts = line
          .split(RegExp(r'[\t, ]+'))
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();

      if (parts.length < 2) continue;

      final studentId = parts[0].replaceAll(RegExp(r'\s+'), '');
      final name = parts[1];

      if (studentId == '학번' || name == '이름') continue;
      if (studentId.isEmpty || name.isEmpty) continue;

      rowsByStudentId[studentId] = _RosterRow(
        studentId: studentId,
        name: name,
      );
    }

    return rowsByStudentId.values.toList();
  }

  // 명단 업로드 핵심 로직
  Future<void> _uploadRoster() async {
    final String eventId = _eventIdController.text.trim();
    final String rawText = _rosterController.text.trim();

    if (eventId.isEmpty || eventId.contains('/') || rawText.isEmpty) {
      _showSnackBar("행사 ID와 명단을 입력해주세요.");
      return;
    }

    final rows = _parseRoster(rawText);
    if (rows.isEmpty) {
      _showSnackBar("인식된 명단이 없습니다. 학번,이름 형식을 확인해주세요.");
      return;
    }

    setState(() => _isUploading = true);

    try {
      int count = 0;
      final firestore = FirebaseFirestore.instance;

      for (var start = 0; start < rows.length; start += 500) {
        final end = (start + 500 > rows.length) ? rows.length : start + 500;
        final batch = firestore.batch();

        for (final row in rows.sublist(start, end)) {
          // 우리 시스템의 핵심 규칙: eventId_studentId
          final docRef = firestore
              .collection('attendance')
              .doc("${eventId}_${row.studentId}");

          batch.set(docRef, {
            'studentId': row.studentId,
            'userUid': row.studentId,
            'uid': row.studentId,
            'name': row.name,
            'userName': row.name,
            'status': '대기 중',
            'eventId': eventId,
            'attendanceTime': null,
            'registeredAt': FieldValue.serverTimestamp(),
          });
          count++;
        }

        await batch.commit();
      }

      _showSnackBar("$count명의 명단 업로드 성공!");
      _rosterController.clear();
    } catch (e) {
      _showSnackBar("업로드 실패: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("명단 일괄 등록"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "1. 행사 ID 입력",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _eventIdController,
              decoration: _inputDecoration("예: event01, mt_2024"),
            ),
            const SizedBox(height: 24),
            const Text(
              "2. 명단 붙여넣기 (학번, 이름)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              "쉼표, 탭, 공백 구분을 모두 지원합니다.",
              style: TextStyle(fontSize: 12, color: _tossGrey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _rosterController,
              maxLines: 15,
              decoration: _inputDecoration("2024001,홍길동\n2024002\t김철수"),
            ),
            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: _tossBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _uploadRoster,
        style: ElevatedButton.styleFrom(
          backgroundColor: _tossBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isUploading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "명단 업로드 시작",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class _RosterRow {
  final String studentId;
  final String name;

  const _RosterRow({
    required this.studentId,
    required this.name,
  });
}
