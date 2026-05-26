import 'dart:convert';
import 'package:crypto/crypto.dart';

class DynamicQRManager {
  // 🔐 비밀 키 (관리자와 사용자 앱이 동일해야 합니다)
  static const String _secretKey = "CHECK_Y_SECRET_KEY_2026";

  // 🕒 30초 단위 타임스탬프 생성
  static int get _currentTimeWindow => DateTime.now().millisecondsSinceEpoch ~/ 30000;

  /// 1️⃣ QR 데이터 생성 (사용자용)
  static String generate(String studentId, String name) {
    int timeWindow = _currentTimeWindow;
    // 포맷: 학번:이름:시간
    String payload = "$studentId:$name:$timeWindow";
    
    var key = utf8.encode(_secretKey);
    var bytes = utf8.encode(payload);
    var hmac = Hmac(sha256, key);
    var digest = hmac.convert(bytes);

    return "$payload|$digest";
  }

  /// 2️⃣ QR 데이터 검증 (관리자용)
  static Map<String, dynamic> verify(String scannedData) {
    try {
      var parts = scannedData.split('|');
      if (parts.length != 2) return {"success": false, "message": "유효하지 않은 QR 형식"};

      String payload = parts[0];
      String receivedHash = parts[1];

      // 해시 검증
      var key = utf8.encode(_secretKey);
      var hmac = Hmac(sha256, key);
      var expectedHash = hmac.convert(utf8.encode(payload)).toString();

      if (receivedHash != expectedHash) {
        return {"success": false, "message": "위조된 QR 코드"};
      }

      // 시간 검증 (현재 혹은 30초 전까지 허용)
      var dataParts = payload.split(':');
      int qrTime = int.parse(dataParts[2]);
      int nowTime = _currentTimeWindow;

      if (nowTime == qrTime || nowTime == qrTime + 1) {
        return {
          "success": true, 
          "studentId": dataParts[0], 
          "userName": dataParts[1]
        };
      } else {
        return {"success": false, "message": "시간이 만료되었습니다"};
      }
    } catch (e) {
      return {"success": false, "message": "데이터 해석 오류"};
    }
  }
}