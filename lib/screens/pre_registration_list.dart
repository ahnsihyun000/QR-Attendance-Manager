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
  static const _tossBlack = Color(0xFF191F28);

  // 데이터 로드 로직
  Future<List<Map<String, dynamic>>> _loadApplicants() async {
    // 1. Realtime DB(신청자)와 Firestore(출석자) 동시 호출
    final results = await Future.wait([
      _realtimeDb.get(),
      _firestore.collection('attendance').get(),
    ]);

    final DataSnapshot realtimeSnapshot = results[0] as DataSnapshot;
    final QuerySnapshot firestoreSnapshot = results[1] as QuerySnapshot;

    // 2. 출석 완료자 UID 세트 생성 (중복 제거 및 빠른 검색용)
    final Set<String> attendedUids = firestoreSnapshot.docs
        .map((doc) => "${(doc.data() as Map)['uid']}".trim())
        .where((uid) => uid.isNotEmpty)
        .toSet();

    // 3. 신청자 명단 파싱 및 출석 대조
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadApplicants(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: _tossBlue));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('데이터를 불러오지 못했습니다.\n네트워크를 확인해 주세요.', 
                  textAlign: TextAlign.center, style: const TextStyle(color: _tossGreyText))
              );
            }

            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return const Center(
                child: Text('신청한 학생이 없습니다.', 
                  style: TextStyle(color: _tossGreyText, fontSize: 16))
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(), // RefreshIndicator를 위해 필요
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: data.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildApplicantItem(data[index]),
            );
          },
        ),
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