import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PreRegistrationScreen extends StatefulWidget {
  const PreRegistrationScreen({super.key});

  @override
  State<PreRegistrationScreen> createState() => _PreRegistrationScreenState();
}

class _PreRegistrationScreenState extends State<PreRegistrationScreen> {
  final DatabaseReference _realtimeDb = FirebaseDatabase.instance.ref("attendance");
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 스타일 상수
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossRed = Color(0xFFF04452);
  static const _tossGreen = Color(0xFF00AD5C);
  static const _tossGreyText = Color(0xFF8B95A1);
  static const _tossBg = Color(0xFFF2F4F6);

  Future<List<Map<String, dynamic>>> _loadApplicants() async {
    // 성능 최적화: 두 DB를 동시에 호출
    final results = await Future.wait([
      _realtimeDb.get(),
      _firestore.collection('attendance').get(),
    ]);

    final DataSnapshot realtimeSnapshot = results[0] as DataSnapshot;
    final QuerySnapshot firestoreSnapshot = results[1] as QuerySnapshot;

    // 1. 출석 완료자 목록 생성 (Firestore)
    final Set<String> attendedUids = firestoreSnapshot.docs
        .map((doc) => "${(doc.data() as Map)['uid']}".trim())
        .where((uid) => uid.isNotEmpty)
        .toSet();

    // 2. 신청자 목록 파싱 및 비교 (Realtime DB)
    final List<Map<String, dynamic>> applicantList = [];
    
    if (realtimeSnapshot.value != null) {
      final Map<dynamic, dynamic> data = realtimeSnapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        if (value is Map) {
          final String uid = "${value['studentId']}".trim();
          final String name = "${value['userName']}".trim();
          final bool isAttend = attendedUids.contains(uid);

          applicantList.add({
            'uid': uid,
            'name': name,
            'isAttend': isAttend,
          });
        }
      });
    }

    // 이름순 정렬 (추가 기능)
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
          style: TextStyle(color: Color(0xFF191F28), fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: const BackButton(color: Color(0xFF191F28)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadApplicants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _tossBlue));
          }

          if (snapshot.hasError) {
            return Center(child: Text('데이터를 불러오지 못했습니다.\n${snapshot.error}', 
              textAlign: TextAlign.center, style: const TextStyle(color: _tossGreyText)));
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('신청한 학생이 없습니다.', 
              style: TextStyle(color: _tossGreyText, fontSize: 16)));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: data.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildApplicantItem(data[index]),
          );
        },
      ),
    );
  }

  Widget _buildApplicantItem(Map<String, dynamic> item) {
    final bool isAttend = item['isAttend'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _tossBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 상태 아이콘
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAttend ? _tossGreen.withValues(alpha: 0.5) : _tossRed.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAttend ? Icons.check_circle_rounded : Icons.cancel_rounded,
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
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF191F28))),
                const SizedBox(height: 2),
                Text('학번: ${item['uid']}', 
                  style: const TextStyle(fontSize: 13, color: _tossGreyText)),
              ],
            ),
          ),
          // 상태 텍스트 레이블
          Text(
            isAttend ? '참석 완료' : '미출석',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isAttend ? _tossGreen : _tossRed,
            ),
          ),
        ],
      ),
    );
  }
}