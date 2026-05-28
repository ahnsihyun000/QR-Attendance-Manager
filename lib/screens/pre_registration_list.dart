import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PreRegistrationScreen extends StatefulWidget {
  const PreRegistrationScreen({super.key});

  @override
  State<PreRegistrationScreen> createState() => _PreRegistrationScreenState();
}

class _PreRegistrationScreenState extends State<PreRegistrationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 사전 신청 명단 화면에서 반복해서 쓰는 색상값입니다.
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossGreyText = Color(0xFF8B95A1);
  static const _tossBg = Color(0xFFF2F4F6);
  static const _tossBlack = Color(0xFF191F28);
  static const _cardBorder = Color(0xFFE5E8EB);

  // Firestore 신청자 문서를 화면 표시용 Map 목록으로 변환합니다.
  Future<List<Map<String, dynamic>>> _loadApplicants() async {
    try {
      // 사전 신청자 명단은 pre-investigation list 컬렉션에서 가져옵니다.
      // timeout을 둬서 네트워크 지연이 길어질 때 사용자에게 오류 상태를 보여줄 수 있게 합니다.
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

        // Timestamp와 문자열 날짜를 모두 처리해 표시 형식을 맞춥니다.
        String formattedTime = '';
        DateTime rawDateTime = DateTime(1970);

        final timestampData = data['timestamp'];

        if (timestampData != null) {
          // Firestore Timestamp로 저장된 경우 DateTime으로 변환합니다.
          if (timestampData is Timestamp) {
            rawDateTime = timestampData.toDate();
            // 문자열로 들어온 예외 데이터도 최대한 파싱해 화면에 표시합니다.
          } else if (timestampData is String) {
            rawDateTime = DateTime.tryParse(timestampData) ?? DateTime(1970);
          }

          final month = rawDateTime.month.toString().padLeft(2, '0');
          final day = rawDateTime.day.toString().padLeft(2, '0');
          final hour = rawDateTime.hour.toString().padLeft(2, '0');
          final minute = rawDateTime.minute.toString().padLeft(2, '0');
          formattedTime = '$month월 $day일 $hour시 $minute분';
        }

        if (uid.isNotEmpty || name.isNotEmpty) {
          // 화면에서 필요한 값만 Map으로 정리해 리스트 카드에 전달합니다.
          applicantList.add({
            'uid': uid.isEmpty ? "학번 누락" : uid,
            'name': name.isEmpty ? "이름 없음" : name,
            'time': formattedTime,
            'formTitle': formTitle,
            'rawDateTime': rawDateTime,
          });
        }
      }

      // 최근 신청자가 위에 보이도록 신청 시간 기준 내림차순 정렬합니다.
      applicantList.sort(
        (a, b) => (b['rawDateTime'] as DateTime).compareTo(
          a['rawDateTime'] as DateTime,
        ),
      );
      return applicantList;
    } catch (e) {
      debugPrint("데이터 로드 중 예외 발생: $e");
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _tossBg,
      appBar: AppBar(
        backgroundColor: _tossBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '사전 신청 명단',
          style: TextStyle(
            color: _tossBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _tossBlack,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 아래로 당겨 새로고침하면 FutureBuilder가 다시 _loadApplicants를 호출합니다.
          setState(() {});
        },
        color: _tossBlue,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadApplicants(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: _tossBlue,
                  strokeWidth: 3,
                ),
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
                          style: TextStyle(
                            color: _tossGreyText,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            fontSize: 15,
                          ),
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
                        style: TextStyle(
                          color: _tossGreyText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
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

  // 신청자 한 명의 이름, 학번, 행사명, 신청 시간을 카드로 보여줍니다.
  Widget _buildApplicantItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
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
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.badge_rounded,
                    size: 14,
                    color: _tossGreyText,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '학번: ${item['uid']}',
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
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3FF),
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
                    letterSpacing: 0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
