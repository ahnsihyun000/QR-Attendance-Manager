import 'dart:convert';
import 'package:crypto/crypto.dart';

class DynamicQRManager {
  // QR 위변조 확인에 쓰는 HMAC 비밀 키입니다.
  static const String _secretKey = "CHECK_Y_SECRET_KEY_2026";

  // 30초 단위 시간창을 만들어 QR 유효 시간을 제한합니다.
  static int get _currentTimeWindow =>
      DateTime.now().millisecondsSinceEpoch ~/ 30000;

  /// 사용자 학번과 이름으로 30초짜리 동적 QR 데이터를 생성합니다.
  static String generate(String studentId, String name) {
    int timeWindow = _currentTimeWindow;
    String payload = "$studentId:$name:$timeWindow";

    var key = utf8.encode(_secretKey);
    var bytes = utf8.encode(payload);
    var hmac = Hmac(sha256, key);
    var digest = hmac.convert(bytes);

    return "$payload|$digest";
  }

  /// 스캔된 QR의 해시와 시간을 검증하고 학생 정보를 반환합니다.
  static Map<String, dynamic> verify(String scannedData) {
    try {
      var parts = scannedData.split('|');
      if (parts.length != 2) {
        return {"success": false, "message": "유효하지 않은 QR 형식"};
      }

      String payload = parts[0];
      String receivedHash = parts[1];

      var key = utf8.encode(_secretKey);
      var hmac = Hmac(sha256, key);
      var expectedHash = hmac.convert(utf8.encode(payload)).toString();

      if (receivedHash != expectedHash) {
        return {"success": false, "message": "위조된 QR 코드"};
      }

      var dataParts = payload.split(':');
      int qrTime = int.parse(dataParts[2]);
      int nowTime = _currentTimeWindow;

      if (nowTime == qrTime || nowTime == qrTime + 1) {
        return {
          "success": true,
          "studentId": dataParts[0],
          "userName": dataParts[1],
        };
      } else {
        return {"success": false, "message": "시간이 만료되었습니다"};
      }
    } catch (e) {
      return {"success": false, "message": "데이터 해석 오류"};
    }
  }
}
