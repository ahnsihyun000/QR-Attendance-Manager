import 'package:flutter/material.dart';

class PreRegistrationScreen extends StatelessWidget {
  const PreRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("사전 신청 명단")),
      body: const Center(child: Text("여기에 유림이가 준 Firestore 명단이 뜰 예정!")),
    );
  }
}
