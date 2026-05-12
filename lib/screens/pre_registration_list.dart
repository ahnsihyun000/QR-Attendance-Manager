//정유림

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PreRegistrationScreen extends StatefulWidget {
  const PreRegistrationScreen({super.key});

  @override
  State<PreRegistrationScreen> createState() =>
      _PreRegistrationScreenState();
}

class _PreRegistrationScreenState
    extends State<PreRegistrationScreen> {

  final DatabaseReference realtimeDb =
      FirebaseDatabase.instance.ref("attendance");

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> loadApplicants() async {

    // Realtime Database 신청자 목록
    final realtimeSnapshot = await realtimeDb.get();

    Map<dynamic, dynamic> realtimeData = {};

    if (realtimeSnapshot.value != null) {
      realtimeData =
          realtimeSnapshot.value as Map<dynamic, dynamic>;
    }

    // Firestore attendance 컬렉션
    final attendanceSnapshot =
        await firestore.collection('attendance').get();

    // 참석한 uid 저장
    Set<String> attendedUids = {};

    for (var doc in attendanceSnapshot.docs) {

      final data = doc.data();

      final uid =
    "${data['uid']}".trim();
    
      if (uid.isNotEmpty) {
        attendedUids.add(uid);
      }
    }

    List<Map<String, dynamic>> result = [];

    realtimeData.forEach((key, value) {

      if (value is Map) {

       final uid =
    "${value['studentId']}".trim();

final name =
    "${value['userName']}".trim();

print("신청자 uid: $uid");
print("출석 uid 목록: $attendedUids");

final isAttend =
    attendedUids.contains(uid);

        result.add({
          'uid': uid,
          'name': name,
          'status': isAttend ? '참석' : '불참석',
        });
      }
    });

    return result;
  }

  Color getStatusColor(String status) {

    if (status == '참석') {
      return Colors.green;
    }

    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('사전 신청 명단'),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: loadApplicants(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {

            return Center(
              child: Text(
                '오류: ${snapshot.error}',
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {

            return const Center(
              child: Text('신청자 없음'),
            );
          }

          return ListView.builder(
            itemCount: data.length,

            itemBuilder: (context, index) {

              final item = data[index];

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(

                  leading: CircleAvatar(
                    backgroundColor:
                        getStatusColor(
                          item['status'],
                        ),

                    child: Icon(
                      item['status'] == '참석'
                          ? Icons.check
                          : Icons.close,
                      color: Colors.white,
                    ),
                  ),

                  title: Text(item['name']),

                  subtitle: Text(
                    '학번: ${item['uid']}',
                  ),

                  trailing: Text(
                    item['status'],
                    style: TextStyle(
                      color: getStatusColor(
                        item['status'],
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
