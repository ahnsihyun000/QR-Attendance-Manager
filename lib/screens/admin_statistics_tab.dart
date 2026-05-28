import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatisticsTab extends StatefulWidget {
  const AdminStatisticsTab({super.key});

  @override
  State<AdminStatisticsTab> createState() => _AdminStatisticsTabState();
}

class _AdminStatisticsTabState extends State<AdminStatisticsTab> {
  // 첫 로드 후 사전 신청 명단에 있는 행사명 중 하나를 선택 상태로 둡니다.
  String? _selectedEventName;

  // 화면 전체에서 반복해서 쓰는 색상값입니다.
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
      appBar: AppBar(
        backgroundColor: _tossBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _tossBlack,
            size: 20,
          ),
        ),
        title: const Text(
          "출석 통계",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _tossBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 먼저 사전 신청 명단을 읽어 행사 목록과 전체 신청자 수를 계산합니다.
        stream: FirebaseFirestore.instance
            .collection('pre-investigation list')
            .snapshots(),
        builder: (context, preInvestigationSnapshot) {
          if (preInvestigationSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _tossBlue),
            );
          }

          final preDocs = preInvestigationSnapshot.data?.docs ?? [];
          Set<String> eventNameSet = {};

          // department 필드를 행사명처럼 사용해 통계에서 선택 가능한 목록을 만듭니다.
          for (var doc in preDocs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['department'] != null) {
              eventNameSet.add(data['department'].toString().trim());
            }
          }

          List<String> eventNames = eventNameSet.toList()..sort();
          if (eventNames.isEmpty) eventNames.add('등록된 행사 없음');

          // 선택된 행사가 아직 없거나 삭제된 경우 첫 번째 행사로 자동 선택합니다.
          if (_selectedEventName == null ||
              !eventNames.contains(_selectedEventName)) {
            _selectedEventName = eventNames.first;
          }

          return StreamBuilder<QuerySnapshot>(
            // 실제 출석 기록은 attendance 컬렉션에서 실시간으로 읽습니다.
            stream: FirebaseFirestore.instance
                .collection('attendance')
                .snapshots(),
            builder: (context, attendanceSnapshot) {
              if (attendanceSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _tossBlue),
                );
              }

              final attendanceDocs = attendanceSnapshot.data?.docs ?? [];

              int attendedCount = 0;
              int missingCount = 0;

              // 선택된 행사 신청자와 출석 컬렉션의 학번을 비교해 출석률을 계산합니다.
              for (var preDoc in preDocs) {
                final preData = preDoc.data() as Map<String, dynamic>;
                final String targetEventName = (preData['department'] ?? '')
                    .toString()
                    .trim();

                if (targetEventName == _selectedEventName) {
                  final String preStudentId = (preData['studentId'] ?? '')
                      .toString()
                      .trim();

                  bool hasAttended = false;

                  // attendance 문서 중 같은 학번이 하나라도 있으면 출석한 것으로 인정합니다.
                  for (var attDoc in attendanceDocs) {
                    final attData = attDoc.data() as Map<String, dynamic>;
                    final String attStudentId = (attData['studentId'] ?? '')
                        .toString()
                        .trim();

                    if (preStudentId.isNotEmpty &&
                        preStudentId == attStudentId) {
                      hasAttended = true;
                      break;
                    }
                  }

                  if (hasAttended) {
                    attendedCount++;
                  } else {
                    // 사전 신청자는 있지만 출석 기록이 없으면 미출석 인원으로 계산합니다.
                    missingCount++;
                  }
                }
              }

              // 전체 대상자가 0명일 때 0으로 나누는 오류가 나지 않도록 별도 처리합니다.
              int total = attendedCount + missingCount;
              double attendPercent = total == 0
                  ? 0
                  : (attendedCount / total) * 100;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventSelector(eventNames),

                      const SizedBox(height: 30),

                      Container(
                        height: 240,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Stack(
                          children: [
                            // 출석 인원과 미출석 인원을 원형 차트로 시각화합니다.
                            PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 70,
                                sections: [
                                  PieChartSectionData(
                                    color: _tossBlue,
                                    value:
                                        (attendedCount == 0 &&
                                            missingCount == 0)
                                        ? 1
                                        : attendedCount.toDouble(),
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
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: _tossBlue,
                                    ),
                                  ),
                                  const Text(
                                    '출석률',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _tossGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

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

  // 선택된 행사명을 보여주고, 탭하면 행사 선택 바텀 시트를 엽니다.
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _tossBlack,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _tossGrey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // 행사 목록을 하단 시트로 보여주고 선택값을 상태에 저장합니다.
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _tossBlack,
                  ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: _tossDivider, width: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected ? _tossBlue : _tossBlack,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_rounded,
                            color: _tossBlue,
                            size: 22,
                          ),
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
