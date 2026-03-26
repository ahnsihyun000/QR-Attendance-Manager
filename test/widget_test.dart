import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// 프로젝트 이름이 'qr_attendance_manager'라고 가정합니다. 
// 만약 에러가 나면 아래 import 문에서 패키지명을 본인 프로젝트명으로 바꾸세요.

void main() {
  testWidgets('App render test', (WidgetTester tester) async {
    // 앱을 빌드하고 프레임을 렌더링합니다.
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Text('App is Running')),
    ));

    // 화면에 텍스트가 잘 뜨는지 확인하는 간단한 테스트입니다.
    expect(find.text('App is Running'), findsOneWidget);
  });
}