import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PreRegistrationScreen extends StatefulWidget {
  const PreRegistrationScreen({super.key});

  @override
  State<PreRegistrationScreen> createState() => _PreRegistrationScreenState();
}

class _PreRegistrationScreenState extends State<PreRegistrationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _eventIdController = TextEditingController(text: 'event01');
  String _selectedEventId = 'event01';

  // 스타일 상수
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossRed = Color(0xFFF04452);
  static const _tossGreen = Color(0xFF00AD5C);
  static const _tossGreyText = Color(0xFF8B95A1);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("올바른 행사 ID를 입력해주세요.")),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _selectedEventId = eventId);
  }

  // 데이터 로드 로직
  Future<List<Map<String, dynamic>>> _loadApplicants() async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('eventId', isEqualTo: _selectedEventId)
        .get();
    final List<Map<String, dynamic>> applicantList = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final uid = '${data['studentId'] ?? data['uid'] ?? data['userUid'] ?? ''}'.trim();
      final name = '${data['userName'] ?? data['name'] ?? ''}'.trim();
      final status = '${data['status'] ?? '대기 중'}';

      if (uid.isEmpty || name.isEmpty) {
        continue;
      }

      applicantList.add({
        'uid': uid,
        'name': name,
        'status': status,
        'isAttend': status == '출석 완료',
      });
    }

    // 이름순 정렬
    applicantList.sort((a, b) => a['name'].compareTo(b['name']));
    return applicantList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('사전 신청 명단', 
          style: TextStyle(color: _tossBlack, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _tossBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator( // 당겨서 새로고침 추가
        onRefresh: () async {
          setState(() {}); // 화면 갱신
        },
        color: _tossBlue,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            _buildEventFilter(),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadApplicants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Center(
                      child: CircularProgressIndicator(color: _tossBlue),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Center(
                      child: Text(
                        '데이터를 불러오지 못했습니다.\n네트워크를 확인해 주세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _tossGreyText),
                      ),
                    ),
                  );
                }

                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Center(
                      child: Text(
                        '신청한 학생이 없습니다.',
                        style: TextStyle(color: _tossGreyText, fontSize: 16),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final item in data) ...[
                      _buildApplicantItem(item),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: _tossBg,
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
    );
  }

  Widget _buildApplicantItem(Map<String, dynamic> item) {
    final bool isAttend = item['isAttend'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _tossBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // 상태 아이콘 (버전 호환성을 위해 withOpacity 사용)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAttend ? _tossGreen.withValues(alpha: 0.1) : _tossRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAttend ? Icons.check_circle_rounded : Icons.access_time_filled_rounded,
              color: isAttend ? _tossGreen : _tossRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // 학생 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], 
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _tossBlack)),
                const SizedBox(height: 4),
                Text('학번: ${item['uid']}', 
                  style: const TextStyle(fontSize: 13, color: _tossGreyText)),
              ],
            ),
          ),
          // 상태 라벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAttend ? _tossGreen.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isAttend ? '참석 완료' : '미출석',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isAttend ? _tossGreen : _tossRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
