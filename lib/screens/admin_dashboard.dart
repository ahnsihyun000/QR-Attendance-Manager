import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // 계획서 내 명시된 패키지
//import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("관리자 대시보드")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("실시간 참여율 통계", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            // fl_chart를 이용한 그래프 예시
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 15, color: Colors.blue)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 28, color: Colors.blue)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 10, color: Colors.blue)]),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: Center(child: Text("행사별 상세 데이터 및 Gemini 분석 결과가 표시됩니다.")),
            ),
          ],
        ),
      ),
    );
  }
}