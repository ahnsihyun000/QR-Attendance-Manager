import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminStatisticsTab extends StatelessWidget {
  const AdminStatisticsTab({super.key});

  static const Color _tossBlue = Color(0xFF3182F6);
  static const Color _tossRed = Color(0xFFFF6B6B);
  static const Color _tossBg = Color(0xFFF2F4F6);
  static const Color _tossBlack = Color(0xFF191F28);
  static const Color _tossGrey = Color(0xFF8B95A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _tossBg,
      body: StreamBuilder<QuerySnapshot>(
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

          return StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance
                .ref('attendance')
                .onValue,
            builder: (context, preSnapshot) {
              if (preSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _tossBlue),
                );
              }

              final attendanceDocs =
                  attendanceSnapshot.data?.docs ?? [];

              final dataSnapshot = preSnapshot.data?.snapshot;

              final registeredStudents = <String>{};

              for (var child in dataSnapshot?.children ?? []) {
                final value = child.value as Map?;

                if (value != null && value['studentId'] != null) {
                  registeredStudents.add(
                    value['studentId'].toString(),
                  );
                }
              }

              final attendedStudents = <String>{};

              for (var doc in attendanceDocs) {
                final data = doc.data() as Map<String, dynamic>;

                final studentId = data['uid']?.toString();

                if (studentId != null &&
                    registeredStudents.contains(studentId)) {
                  attendedStudents.add(studentId);
                }
              }

              final attendedCount = attendedStudents.length;

              final totalCount = registeredStudents.length;

              

              final absentCount =
                  (totalCount - attendedCount).clamp(0, totalCount);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      '출석 통계',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _tossBlack,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 260,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 60,
                                sections: [
                                  PieChartSectionData(
                                    color: _tossBlue,
                                    value: attendedCount.toDouble(),
                                    title: totalCount == 0
                                        ? '0%'
                                        : '${((attendedCount / totalCount) * 100).toStringAsFixed(1)}%',
                                    radius: 90,
                                    titleStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: _tossRed,
                                    value: absentCount.toDouble(),
                                    title: totalCount == 0
                                        ? '0%'
                                        : '${((absentCount / totalCount) * 100).toStringAsFixed(1)}%',
                                    radius: 90,
                                    titleStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildInfoCard(
                                title: '참석',
                                count: attendedCount,
                                color: _tossBlue,
                              ),
                              _buildInfoCard(
                                title: '불참석',
                                count: absentCount,
                                color: _tossRed,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '전체 신청 인원',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _tossGrey,
                                  ),
                                ),
                                Text(
                                  '$totalCount명',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _tossBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: _tossGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count명',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _tossBlack,
            ),
          ),
        ],
      ),
    );
  }
}
