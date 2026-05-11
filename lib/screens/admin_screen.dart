import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("관리자 - 학생 명단 확인"),
        backgroundColor: Colors.redAccent, // 관리자 화면임을 알 수 있게 색상 변경
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 'users' 컬렉션의 데이터를 실시간으로 감시합니다.
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("가입된 학생이 없습니다."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var userData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              bool isAdmin = userData['role'] == 'admin';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAdmin ? Colors.red : Colors.blue,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    "${userData['name']} (${userData['studentId']})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${userData['department']} | ${isAdmin ? '관리자' : '학생'}"),
                  trailing: isAdmin 
                      ? const Icon(Icons.star, color: Colors.amber) 
                      : const Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}