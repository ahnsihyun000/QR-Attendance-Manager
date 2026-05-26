import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminAttendanceList extends StatefulWidget {
  const AdminAttendanceList({super.key});

  @override
  State<AdminAttendanceList> createState() => _AdminAttendanceListState();
}

class _AdminAttendanceListState extends State<AdminAttendanceList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 토스 스타일 상수 정의
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossGreen = Color(0xFF00AD5C);
  static const _tossGrey = Color(0xFF8B95A1);
  static const _tossBg = Color(0xFFF2F4F6);
  static const _tossBlack = Color(0xFF191F28);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _tossBg,
      appBar: AppBar(
        backgroundColor: _tossBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        // 🎯 이미지와 매칭되는 토스 스타일 얇은 뒤로가기 화살표 반영
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded, // 얇고 꺾인 디자인의 아이콘
            color: _tossBlack,
            size: 20, // 토스 특유의 컴팩트한 사이즈
          ),
        ),
        title: const Text(
          "실시간 출석 명단",
          style: TextStyle(
            color: _tossBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSummaryHeader(),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '실시간 출석 현황',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333D4B),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('attendance')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("데이터를 불러오는 중 오류가 발생했습니다."));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _tossBlue),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildAttendanceListItem(docs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 상단 총 출석 인원 요약 헤더 카드
  Widget _buildSummaryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('attendance').snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return Text(
                  '현재 총 $count명 출석되었습니다.',
                  style: const TextStyle(
                    color: _tossBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 데이터가 없을 때 표시할 빈 UI 상태창
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              size: 48,
              color: Color(0xFFD1D6DB),
            ),
            SizedBox(height: 12),
            Text(
              '아직 출석한 학생이 없습니다.\nQR 코드를 스캔하면 실시간으로 반영됩니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _tossGrey, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // 실제 Firestore 문서 필드 기반으로 매칭한 출석 명단 리스트 카드 위젯
  Widget _buildAttendanceListItem(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final String name = data['userName'] ?? '이름 없음';
    final String studentId = data['studentId'] ?? '학번 없음';
    final Timestamp? timestamp = data['timestamp'] as Timestamp?;

    String formattedTime = '-';
    if (timestamp != null) {
      formattedTime = DateFormat('a hh:mm', 'ko_KR').format(timestamp.toDate());
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _tossGreen.withValues(alpha: 0.1),
            child: const Icon(Icons.check_rounded, color: _tossGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _tossBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "학번: $studentId",
                  style: const TextStyle(fontSize: 13, color: _tossGrey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _tossGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "출석 완료",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _tossGreen,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 12,
                  color: _tossGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}