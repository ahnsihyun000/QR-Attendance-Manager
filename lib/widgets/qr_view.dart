import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QR 코드를 흰색 배경 위에 안정적으로 표시하는 공통 위젯입니다.
class CommonQrWidget extends StatelessWidget {
  /// QR에 담을 원본 문자열입니다.
  final String data;

  /// 화면에 표시할 QR 코드 크기입니다.
  final double size;

  const CommonQrWidget({super.key, required this.data, this.size = 200.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR 인식률을 높이기 위해 흰색 배경 컨테이너를 사용합니다.
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: QrImageView(data: data, version: QrVersions.auto, size: size),
        ),
        const SizedBox(height: 8),
        const Text(
          "위 코드를 리더기에 보여주세요",
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
