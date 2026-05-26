import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatisticsTab extends StatefulWidget {
  const AdminStatisticsTab({super.key});

  @override
  State<AdminStatisticsTab> createState() => _AdminStatisticsTabState();
}

class _AdminStatisticsTabState extends State<AdminStatisticsTab> {
  // 처음 선택될 기본값
  String _selectedEventId = 'event01';

  static const Color _tossBlue = Color(0xFF3182F6);
  static const Color _tossRed = Color(0xFFFF6B6B);
  static const Color _tossBg = Color(0xFFF2F4F6);
  static const Color _tossBlack = Color(0xFF191F28);
  static const Color _tossGrey = Color(0xFF8B95A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _tossBg,
      // 키보드 오버플로우 방지
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('attendance').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _tossBlue),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          // 1. 모든 문서에서 중복 없이 행사 ID(eventId) 목록 추출
          Set<String> eventIdSet = {};
          for (var doc in allDocs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['eventId'] != null) {
              eventIdSet.add(data['eventId']);
            }
          }

          // 만약 데이터가 하나도 없다면 기본값 유지
          List<String> eventIds = eventIdSet.toList()..sort();
          if (eventIds.isEmpty) eventIds.add('event01');

          // 현재 선택된 값이 목록에 없다면 첫 번째 항목으로 자동 변경
          if (!eventIds.contains(_selectedEventId)) {
            _selectedEventId = eventIds.first;
          }

          // 2. 선택된 행사 ID에 해당하는 데이터만 필터링
          final filteredDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['eventId'] == _selectedEventId;
          }).toList();

          int attendedCount = 0;
          int missingCount = 0;

          for (var doc in filteredDocs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['status'] == '출석 완료') {
              attendedCount++;
            } else {
              missingCount++;
            }
          }

          int total = attendedCount + missingCount;
          double attendPercent = total == 0 ? 0 : (attendedCount / total) * 100;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "출석 통계",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _tossBlack,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✨ [업그레이드] 드롭다운 선택창
                  _buildEventDropdown(eventIds),

                  const SizedBox(height: 30),

                  // 차트 영역 (기존과 동일)
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
                                value: attendedCount.toDouble(),
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
                      _buildInfoCard(
                        title: "출석 인원",
                        count: attendedCount,
                        color: _tossBlue,
                      ),
                      _buildInfoCard(
                        title: "미출석 인원",
                        count: missingCount,
                        color: _tossRed,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✨ 드롭다운 위젯 빌더
  Widget _buildEventDropdown(List<String> eventIds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEventId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _tossBlue),
          items: eventIds.map((String id) {
            return DropdownMenuItem<String>(
              value: id,
              child: Text(
                id,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _tossBlack,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedEventId = newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required int count,
    required Color color,
  }) {
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
