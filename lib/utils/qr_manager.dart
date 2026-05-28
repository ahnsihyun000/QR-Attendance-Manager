import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 학생용 QR 생성과 관리자용 QR 검증을 처리하는 유틸 클래스입니다.
///
/// QR 데이터는 단순 문자열만 담으면 쉽게 복사되거나 조작될 수 있으므로,
/// 원본 데이터(payload)에 HMAC 해시를 붙여 위변조 여부를 확인합니다.
class DynamicQRManager {
  // 사용자 앱에서 QR을 만들 때와 관리자 앱에서 QR을 검증할 때 같은 키를 사용합니다.
  static const String _secretKey = "CHECK_Y_SECRET_KEY_2026";

  // 현재 시간을 30초 단위로 나눈 값입니다.
  // 같은 30초 안에서는 같은 시간창 값이 나오고, 다음 30초가 되면 값이 바뀝니다.
  static int get _currentTimeWindow =>
      DateTime.now().millisecondsSinceEpoch ~/ 30000;

  /// 사용자 학번과 이름으로 30초짜리 동적 QR 데이터를 생성합니다.
  static String generate(String studentId, String name) {
    int timeWindow = _currentTimeWindow;

    // QR 안에 실제로 담길 기본 데이터입니다.
    // 관리자 쪽에서는 이 값을 다시 분리해 학번, 이름, 생성 시간을 확인합니다.
    String payload = "$studentId:$name:$timeWindow";

    // payload를 비밀 키로 서명해 QR 데이터가 중간에 바뀌었는지 검증할 수 있게 합니다.
    var key = utf8.encode(_secretKey);
    var bytes = utf8.encode(payload);
    var hmac = Hmac(sha256, key);
    var digest = hmac.convert(bytes);

    // "|" 앞은 원본 데이터, 뒤는 원본 데이터를 기반으로 만든 해시입니다.
    return "$payload|$digest";
  }

  /// 스캔된 QR의 해시와 시간을 검증하고 학생 정보를 반환합니다.
  static Map<String, dynamic> verify(String scannedData) {
    try {
      // QR 데이터는 "원본데이터|해시값" 구조여야 합니다.
      var parts = scannedData.split('|');
      if (parts.length != 2) {
        return {"success": false, "message": "유효하지 않은 QR 형식"};
      }

      String payload = parts[0];
      String receivedHash = parts[1];

      // 스캔된 payload로 해시를 다시 계산해서 QR 안의 해시와 비교합니다.
      // 두 값이 다르면 학번, 이름, 시간 중 하나가 조작된 QR로 판단합니다.
      var key = utf8.encode(_secretKey);
      var hmac = Hmac(sha256, key);
      var expectedHash = hmac.convert(utf8.encode(payload)).toString();

      if (receivedHash != expectedHash) {
        return {"success": false, "message": "위조된 QR 코드"};
      }

      // payload에서 학번, 이름, QR 생성 시간창을 다시 꺼냅니다.
      var dataParts = payload.split(':');
      int qrTime = int.parse(dataParts[2]);
      int nowTime = _currentTimeWindow;

      // 현재 시간창 또는 바로 이전 시간창까지만 허용합니다.
      // 카메라 인식 지연을 고려하면서도 오래된 QR 재사용은 막기 위한 처리입니다.
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
