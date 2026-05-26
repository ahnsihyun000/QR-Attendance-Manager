import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PreRegistrationScreen extends StatefulWidget {
  const PreRegistrationScreen({super.key});

  @override
  State<PreRegistrationScreen> createState() => _PreRegistrationScreenState();
}

class _PreRegistrationScreenState extends State<PreRegistrationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 토스 스타일 색상 에셋 동일 유지
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossGreyText = Color(0xFF8B95A1);
  static const _tossBg = Color(0xFFF2F4F6);
  static const _tossBlack = Color(0xFF191F28);
  static const _cardBorder = Color(0xFFE5E8EB);

  // 📂 파이어베이스 데이터 안전 로드 및 정렬 로직
  Future<List<Map<String, dynamic>>> _loadApplicants() async {
    try {
      final snapshot = await _firestore
          .collection('pre-investigation list')
          .get()
          .timeout(const Duration(seconds: 5));
          
      final List<Map<String, dynamic>> applicantList = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        final uid = data['studentId']?.toString().trim() ?? '';
        final name = data['userName']?.toString().trim() ?? '';
        final formTitle = data['department']?.toString().trim() ?? '행사 참여 명단';

        // ⏱️ 타임스탬프 파싱 및 포맷 최적화
        String formattedTime = '';
        DateTime rawDateTime = DateTime(1970); 
        
        final timestampData = data['timestamp'];
        
        if (timestampData != null) {
          if (timestampData is Timestamp) {
            rawDateTime = timestampData.toDate();
          } else if (timestampData is String) {
            rawDateTime = DateTime.tryParse(timestampData) ?? DateTime(1970);
          }
          
          final month = rawDateTime.month.toString().padLeft(2, '0');
          final day = rawDateTime.day.toString().padLeft(2, '0');
          final hour = rawDateTime.hour.toString().padLeft(2, '0');
          final minute = rawDateTime.minute.toString().padLeft(2, '0');
          formattedTime = '$month월 $day일 $hour시 $minute분';
        }

        // 식별 데이터 안전 검증 후 추가
        if (uid.isNotEmpty || name.isNotEmpty) {
          applicantList.add({
            'uid': uid.isEmpty ? "학번 누락" : uid,
            'name': name.isEmpty ? "이름 없음" : name,
            'time': formattedTime,
            'formTitle': formTitle,
            'rawDateTime': rawDateTime,
          });
        }
      }

      // 최신 등록 날짜 순 정렬
      applicantList.sort((a, b) => (b['rawDateTime'] as DateTime).compareTo(a['rawDateTime'] as DateTime));
      return applicantList;

    } catch (e) {
      debugPrint("🚨 데이터 로드 중 예외 발생: $e");
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _tossBg, // 🎯 배경색 일치화 완료
      appBar: AppBar(
        backgroundColor: _tossBg, // 🎯 실시간 출석 명단 화면과 동일하게 배경을 토스 그레이로 연장합니다.
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '사전 신청 명단',
          style: TextStyle(
            color: _tossBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _tossBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        color: _tossBlue,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadApplicants(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _tossBlue, strokeWidth: 3),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          '데이터를 불러오지 못했습니다.\n네트워크 상태나 관리자 권한을 확인해 주세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _tossGreyText, fontWeight: FontWeight.w500, height: 1.5, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final data = snapshot.data ?? [];
           
            if (data.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(
                      child: Text(
                        '사전 신청 내역이 비어 있습니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _tossGreyText, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40), // 앱바와의 간격 최적화
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return _buildApplicantItem(item);
              },
            );
          },
        ),
      ),
    );
  }

  // 👤 커스텀 리스트 타일 컴포넌트
  Widget _buildApplicantItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // 카드 본체는 흰색으로 유지하여 배경과 완벽하게 대비되게 처리
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015), // 구버전/신버전 호환용 호환성 확보
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item['name'], 
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _tossBlack,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.badge_rounded, size: 14, color: _tossGreyText),
                  const SizedBox(width: 5),
                  Text(
                    '학번: ${item['uid']}', // 실시간 출석 명단 폼인 '학번: XXXXX' 스타일과 포맷 일치
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _tossGreyText,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item['formTitle'],
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _tossGreyText,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3FF), // 실시간 출석 완료 뱃지 스타일처럼 강조 배경 추가
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '신청 완료',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _tossBlue,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (item['time'].toString().isNotEmpty)
                Text(
                  item['time'],
                  style: const TextStyle(
                    color: _tossGreyText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}