import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminUserApprovalScreen extends StatefulWidget {
  const AdminUserApprovalScreen({super.key});

  @override
  State<AdminUserApprovalScreen> createState() => _AdminUserApprovalScreenState();
}

class _AdminUserApprovalScreenState extends State<AdminUserApprovalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // 현재 활성화된 한글 필터 상태 바 기본값
  String _selectedStatus = "비승인";

  static const _tossBlue = Color(0xFF3182F6);
  static const _tossBlack = Color(0xFF191F28);
  static const _tossGrey = Color(0xFF8B95A1);
  static const _tossBg = Color(0xFFF2F4F6);

  // 🎯 회원 승인 상태 업데이트 (구형 필드 삭제 및 신형 문자열 필드 강제 주입)
  Future<void> _updateStatus(String docId, String userName, String targetStatus) async {
    try {
      // update가 아닌 set(SetOptions(merge: true))을 사용하여 필드가 없어도 새로 생성하고,
      // 예전 boolean 필드(isApproved)가 있다면 완전히 지워버려 데이터 충돌을 막습니다.
      await _firestore.collection('users').doc(docId).set({
        'status': targetStatus,
        'isApproved': FieldValue.delete(), // 🔥 구버전 필드가 남아있다면 삭제하여 충돌 방지
      }, SetOptions(merge: true));

      if (!mounted) return;
      String message = targetStatus == "승인" 
          ? "$userName님의 회원가입을 승인했습니다." 
          : "$userName님의 가입 승인을 취소했습니다.";
      
      _showResultSnackBar(context, message, isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      _showResultSnackBar(context, "처리 중 오류 발생: ${e.toString()}", isSuccess: false);
    }
  }

  void _showResultSnackBar(BuildContext context, String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle_rounded : Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          ],
        ),
        backgroundColor: isSuccess ? const Color(0xFF00AD5C) : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _tossBg,
      appBar: AppBar(
        backgroundColor: _tossBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _tossBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("가입자 승인 관리", style: TextStyle(color: _tossBlack, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("오류: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: _tossBlue));
                }

                final allDocs = snapshot.data?.docs ?? [];

                // 🎯 실시간 동적 필터링 바 (과거 데이터 파편화 완벽 대응)
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  
                  // 1. 만약 구형 boolean 필드가 남아있다면, 즉시 한글 상태로 가상 치환하여 분류
                  if (data.containsKey('isApproved') && !data.containsKey('status')) {
                    final bool legacyApproved = data['isApproved'] ?? false;
                    return (legacyApproved ? "승인" : "비승인") == _selectedStatus;
                  }

                  // 2. 신형 문자열 필드가 있다면 해당 값으로 분류 (필드 자체가 아예 없으면 "비승인"으로 자동 간주)
                  final String userStatus = data['status'] ?? "비승인"; 
                  return userStatus == _selectedStatus;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(_selectedStatus == "승인" ? Icons.person_search_rounded : Icons.person_outline_rounded, size: 36, color: _tossGrey),
                        ),
                        const SizedBox(height: 16),
                        Text("$_selectedStatus된 회원이 없습니다.", style: const TextStyle(color: _tossGrey, fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final userDoc = filteredDocs[index];
                    final userData = userDoc.data() as Map<String, dynamic>;

                    final String studentId = userData['studentId'] ?? '학번 없음';
                    final String userName = userData['name'] ?? '이름 없음';

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _selectedStatus == "승인" ? const Color(0xFFE5F7ED) : const Color(0xFFE8F3FF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person, color: _selectedStatus == "승인" ? const Color(0xFF00AD5C) : _tossBlue, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _tossBlack)),
                                const SizedBox(height: 4),
                                Text("학번: $studentId", style: const TextStyle(fontSize: 13, color: _tossGrey)),
                              ],
                            ),
                          ),
                          _selectedStatus == "승인"
                              ? OutlinedButton(
                                  onPressed: () => _updateStatus(userDoc.id, userName, "비승인"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(color: Color(0xFFFFEAEA)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: const Text("취소", style: TextStyle(fontWeight: FontWeight.bold)),
                                )
                              : ElevatedButton(
                                  onPressed: () => _updateStatus(userDoc.id, userName, "승인"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _tossBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: const Text("승인", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          _buildTabButton(title: "비승인 명단", isActive: _selectedStatus == "비승인", onTap: () => setState(() => _selectedStatus = "비승인")),
          const SizedBox(width: 12),
          _buildTabButton(title: "승인 명단", isActive: _selectedStatus == "승인", onTap: () => setState(() => _selectedStatus = "승인")),
        ],
      ),
    );
  }

  Widget _buildTabButton({required String title, required bool isActive, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))] : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(color: isActive ? _tossBlue : _tossGrey, fontSize: 15, fontWeight: isActive ? FontWeight.bold : FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}