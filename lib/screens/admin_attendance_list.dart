import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 시간 포맷을 위해 추가

class AdminAttendanceList extends StatelessWidget {
  const AdminAttendanceList({super.key});

  // 스타일 상수
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossBg = Color(0xFFF2F4F6);
  static const _tossGreyText = Color(0xFF8B95A1);
  static const _tossBlack = Color(0xFF191F28);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _tossBg,
      body: StreamBuilder<QuerySnapshot>(
        // 'createdAt' 기준으로 내림차순 정렬 (최신순)
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("데이터를 불러오는 중 오류가 발생했습니다."));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _tossBlue));
          }

          final docs = snapshot.data?.docs ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(), // 부드러운 스크롤 효과
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

  // 앱바 영역
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

  // 출석 데이터가 없을 때
  Widget _buildEmptyState() {
    return const SliverFillRemaining(
      child: Center(
        child: Text(
          "아직 출석한 인원이 없어요.",
          style: TextStyle(color: _tossGreyText, fontSize: 16),
        ),
      ),
    );
  }

  // 출석 리스트 영역
  Widget _buildAttendanceList(List<QueryDocumentSnapshot> docs) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            
            // 데이터 필드 안전하게 추출 (QR 카메라 코드와 일치시킴)
            final String name = data['name'] ?? '이름 없음';
            final String uid = data['uid'] ?? '-';
            final Timestamp? createdAt = data['createdAt'] as Timestamp?;
            
            // 시간 포맷 (예: 오후 2:30)
            final String timeStr = createdAt != null 
                ? DateFormat('a h:mm', 'ko_KR').format(createdAt.toDate())
                : '';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // 프로필 아이콘
                  _buildProfileIcon(),
                  const SizedBox(width: 16),
                  // 정보 텍스트
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
                  // 출석 시간 정보
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "출석 완료",
                        style: TextStyle(
                          fontSize: 12,
                          color: _tossBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeStr,
                        style: const TextStyle(fontSize: 12, color: _tossGreyText),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          childCount: docs.length,
        ),
      ),
    );
  }

  Widget _buildProfileIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F3FF),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person_rounded, color: _tossBlue, size: 28),
    );
  }
}