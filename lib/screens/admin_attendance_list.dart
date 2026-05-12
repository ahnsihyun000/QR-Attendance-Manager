import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAttendanceList extends StatelessWidget {
  const AdminAttendanceList({super.key});

  // 스타일 상수 정의 (한 곳에서 관리)
  static const Color _tossBlue = Color(0xFF3182F6);
  static const Color _tossBg = Color(0xFFF2F4F6);
  static const Color _tossGreyText = Color(0xFF8B95A1);
  static const Color _tossBlack = Color(0xFF191F28);
  static const Color _tossIconBg = Color(0xFFE8F3FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _tossBg,
      body: StreamBuilder<QuerySnapshot>(
        // 최신 출석자가 가장 위로 오도록 정렬
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildCenterMessage("데이터를 불러오는 중 오류가 발생했습니다.");
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _tossBlue));
          }

          final docs = snapshot.data?.docs ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              if (docs.isEmpty)
                _buildEmptyState()
              else
                _buildAttendanceList(docs),
            ],
          );
        },
      ),
    );
  }

  // --- 위젯 구성 요소 ---

  // 상단 앱바
  Widget _buildAppBar() {
    return const SliverAppBar(
      backgroundColor: _tossBg,
      floating: true,
      elevation: 0,
      centerTitle: false,
      expandedHeight: 60,
      title: Text(
        "실시간 출석 현황",
        style: TextStyle(
          color: _tossBlack,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }

  // 출석 데이터가 비어있을 때
  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: _buildCenterMessage("아직 출석한 인원이 없어요."),
    );
  }

  // 출석 리스트 본문
  Widget _buildAttendanceList(List<QueryDocumentSnapshot> docs) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildAttendanceCard(data);
          },
          childCount: docs.length,
        ),
      ),
    );
  }

  // 개별 출석 카드 아이템
  Widget _buildAttendanceCard(Map<String, dynamic> data) {
    final String name = data['name']?.toString() ?? '이름 없음';
    final String uid = data['uid']?.toString() ?? '-';
    final Timestamp? createdAt = data['createdAt'] as Timestamp?;
    
    // 한국어 설정 및 시간 포맷팅
    final String timeStr = createdAt != null 
        ? DateFormat('a h:mm', 'ko_KR').format(createdAt.toDate())
        : '시간 정보 없음';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18), // 패딩을 조금 더 넓힘
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // 더 부드러운 라운딩
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProfileIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _tossBlack,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "학번: $uid",
                  style: const TextStyle(fontSize: 13, color: _tossGreyText),
                ),
              ],
            ),
          ),
          _buildStatusInfo(timeStr),
        ],
      ),
    );
  }

  // 우측 상태 및 시간 표시
  Widget _buildStatusInfo(String timeStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "출석 완료",
          style: TextStyle(
            fontSize: 12,
            color: _tossBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          timeStr,
          style: const TextStyle(fontSize: 12, color: _tossGreyText),
        ),
      ],
    );
  }

  // 프로필 아이콘 위젯
  Widget _buildProfileIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: _tossIconBg,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person_rounded, color: _tossBlue, size: 26),
    );
  }

  // 공통 중앙 메시지 위젯
  Widget _buildCenterMessage(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: _tossGreyText, fontSize: 15),
      ),
    );
  }
}