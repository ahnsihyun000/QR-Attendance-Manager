import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminAttendanceList extends StatefulWidget {
  const AdminAttendanceList({super.key});

  @override
  State<AdminAttendanceList> createState() => _AdminAttendanceListState();
}

class _AdminAttendanceListState extends State<AdminAttendanceList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _eventIdController = TextEditingController(text: 'event01');
  String _selectedEventId = 'event01';

  // 스타일 상수 (Toss Style)
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossGreen = Color(0xFF00AD5C);
  static const _tossGrey = Color(0xFF8B95A1);
  static const _tossBg = Color(0xFFF2F4F6);
  static const _tossBlack = Color(0xFF191F28);

  @override
  void dispose() {
    _eventIdController.dispose();
    super.dispose();
  }

  void _applyEventFilter() {
    final eventId = _eventIdController.text.trim();
    if (eventId.isEmpty || eventId.contains('/')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("올바른 행사 ID를 입력해주세요.")));
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _selectedEventId = eventId);
  }

  // 정렬 함수: QueryDocumentSnapshot 타입을 명시적으로 사용
  int _sortAttendanceDocs(
    QueryDocumentSnapshot<Map<String, dynamic>> a,
    QueryDocumentSnapshot<Map<String, dynamic>> b,
  ) {
    final dataA = a.data();
    final dataB = b.data();

    // 1. 출석 완료 상태를 최상단으로 (상태 우선 정렬)
    final String statusA = dataA['status'] ?? '대기 중';
    final String statusB = dataB['status'] ?? '대기 중';

    if (statusA == '출석 완료' && statusB != '출석 완료') return -1;
    if (statusA != '출석 완료' && statusB == '출석 완료') return 1;

    // 2. 같은 상태 내에서는 시간순 정렬 (최신순)
    final Timestamp? timeA = dataA['attendanceTime'] as Timestamp?;
    final Timestamp? timeB = dataB['attendanceTime'] as Timestamp?;

    if (timeA == null && timeB == null) return 0;
    if (timeA == null) return 1;
    if (timeB == null) return -1;

    return timeB.compareTo(timeA); // 최신 출석자가 위로
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _tossBg,
      appBar: AppBar(
        backgroundColor: _tossBg,
        elevation: 0,
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Firestore에서 실시간 데이터 구독
        stream: _firestore
            .collection('attendance')
            .where('eventId', isEqualTo: _selectedEventId)
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

          // 에러의 핵심이었던 부분: 명확한 타입 캐스팅 후 정렬
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
              List.from(snapshot.data!.docs);

          docs.sort(_sortAttendanceDocs);

          return Column(
            children: [
              _buildEventFilter(),
              Expanded(
                child: docs.isEmpty
                    ? const Center(
                        child: Text(
                          "해당 행사 출석 데이터가 없습니다.",
                          style: TextStyle(color: _tossGrey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: docs.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildAttendanceListItem(docs[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_available_rounded, color: _tossBlue),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _eventIdController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _applyEventFilter(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: "행사 ID",
                ),
              ),
            ),
            TextButton(
              onPressed: _applyEventFilter,
              child: const Text(
                "조회",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 각 학생의 출석 정보를 보여주는 카드 위젯
  Widget _buildAttendanceListItem(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final String name = data['name'] ?? '이름 없음';
    final String studentId = data['userUid'] ?? data['studentId'] ?? 'ID 없음';
    final String status = data['status'] ?? '대기 중';
    final bool isAttend = status == '출석 완료';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isAttend ? _tossGreen.withOpacity(0.1) : _tossBg,
            child: Icon(
              isAttend ? Icons.check_rounded : Icons.person_outline_rounded,
              color: isAttend ? _tossGreen : _tossGrey,
            ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isAttend ? _tossGreen.withOpacity(0.1) : _tossBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isAttend ? _tossGreen : _tossGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
