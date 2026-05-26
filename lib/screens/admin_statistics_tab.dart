import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatisticsTab extends StatefulWidget {
  const AdminStatisticsTab({super.key});

  @override
  State<AdminStatisticsTab> createState() => _AdminStatisticsTabState();
}

class _AdminStatisticsTabState extends State<AdminStatisticsTab> {
  // 🎯 선택된 행사명 (초기값 null, 첫 로드 시 자동 할당)
  String? _selectedEventName;

  // 🎨 토스 스타일 색상 상수
  static const Color _tossBlue = Color(0xFF3182F6);
  static const Color _tossRed = Color(0xFFFF6B6B);
  static const Color _tossBg = Color(0xFFF2F4F6);
  static const Color _tossBlack = Color(0xFF191F28);
  static const Color _tossGrey = Color(0xFF8B95A1);
  static const Color _tossDivider = Color(0xFFF2F4F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _tossBg,
      resizeToAvoidBottomInset: false,
      // 🎯 상단 앱바 구조를 추가하여 깔끔하게 타이틀 크기 18 및 뒤로가기 버튼 구현
      appBar: AppBar(
        backgroundColor: _tossBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded, // 토스 스타일 얇은 화살표
            color: _tossBlack,
            size: 20,
          ),
        ),
        title: const Text(
          "출석 통계",
          style: TextStyle(
            fontSize: 18, // 👈 요청하신 글자 크기 18 반영
            fontWeight: FontWeight.bold,
            color: _tossBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 1️⃣ 사전 신청자 명단(pre-investigation list) 로드하여 행사 종류 추출
        stream: FirebaseFirestore.instance.collection('pre-investigation list').snapshots(),
        builder: (context, preInvestigationSnapshot) {
          if (preInvestigationSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _tossBlue));
          }

          final preDocs = preInvestigationSnapshot.data?.docs ?? [];
          Set<String> eventNameSet = {};
          
          for (var doc in preDocs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['department'] != null) {
              eventNameSet.add(data['department'].toString().trim());
            }
          }

          List<String> eventNames = eventNameSet.toList()..sort();
          if (eventNames.isEmpty) eventNames.add('등록된 행사 없음');

          // 바텀 시트 초기 선택값 설정
          if (_selectedEventName == null || !eventNames.contains(_selectedEventName)) {
            _selectedEventName = eventNames.first;
          }

          // 2️⃣ 실시간 출석 기록 명단(attendance) 로드
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('attendance').snapshots(),
            builder: (context, attendanceSnapshot) {
              if (attendanceSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _tossBlue));
              }

              final attendanceDocs = attendanceSnapshot.data?.docs ?? [];

              // 📊 통계 변수 초기화
              int attendedCount = 0;
              int missingCount = 0;

              // 현재 선택된 행사 이름에 맞는 데이터 매칭 계산 시작
              for (var preDoc in preDocs) {
                final preData = preDoc.data() as Map<String, dynamic>;
                final String targetEventName = (preData['department'] ?? '').toString().trim();

                // 조건 1: 현재 바텀 시트에서 선택한 행사 소속 학생인지 확인
                if (targetEventName == _selectedEventName) {
                  
                  // 사전 신청 정보에서 학번 추출
                  final String preStudentId = (preData['studentId'] ?? '').toString().trim();

                  bool hasAttended = false;

                  // 조건 2: attendance 컬렉션에 이 학번을 가진 문서가 존재하는지 검색
                  for (var attDoc in attendanceDocs) {
                    final attData = attDoc.data() as Map<String, dynamic>;
                    final String attStudentId = (attData['studentId'] ?? '').toString().trim();

                    // status 필드 조건 검사를 빼고, 학번이 일치하는 데이터가 존재만 하면 출석 인정!
                    if (preStudentId.isNotEmpty && preStudentId == attStudentId) {
                      hasAttended = true;
                      break;
                    }
                  }

                  // 결과 카운트 분기 주입
                  if (hasAttended) {
                    attendedCount++;
                  } else {
                    missingCount++;
                  }
                }
              }

              // 출석률 퍼센트 계산
              int total = attendedCount + missingCount;
              double attendPercent = total == 0 ? 0 : (attendedCount / total) * 100;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✨ 깔끔한 토스 스타일 바텀 시트 트리거 버튼
                      _buildEventSelector(eventNames),

                      const SizedBox(height: 30),

                      // 📊 원형 통계 파이 차트
                      Container(
                        height: 240,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 70,
                                sections: [
                                  PieChartSectionData(
                                    color: _tossBlue,
                                    value: (attendedCount == 0 && missingCount == 0) ? 1 : attendedCount.toDouble(),
                                    radius: 25,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    color: _tossRed.withValues(alpha: 0.2),
                                    value: missingCount.toDouble(),
                                    radius: 25,
                                    showTitle: false,
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${attendPercent.toStringAsFixed(1)}%',
                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _tossBlue),
                                  ),
                                  const Text('출석률', style: TextStyle(fontSize: 14, color: _tossGrey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // 🔢 하단 스코어 보드
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoCard("출석 인원", attendedCount, _tossBlue),
                          _buildInfoCard("미출석 인원", missingCount, _tossRed),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✨ 바텀 시트를 여는 카드 형태의 버튼
  Widget _buildEventSelector(List<String> eventNames) {
    return GestureDetector(
      onTap: () => _showTossStyleSheet(eventNames),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedEventName ?? "행사를 선택하세요",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _tossBlack),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: _tossGrey, size: 24),
          ],
        ),
      ),
    );
  }

  // ✨ 하단 토스 스타일 바텀 시트 모달 레이아웃
  void _showTossStyleSheet(List<String> eventNames) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 24, top: 24, bottom: 16),
                child: Text(
                  "행사 선택",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _tossBlack),
                ),
              ),
              ...eventNames.map((String name) {
                final bool isSelected = _selectedEventName == name;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedEventName = name);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: _tossDivider, width: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? _tossBlue : _tossBlack,
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check_rounded, color: _tossBlue, size: 22),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, int count, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 15, color: _tossGrey)),
          const SizedBox(height: 8),
          Text(
            '$count명',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}