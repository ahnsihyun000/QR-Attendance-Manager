import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// [CommonQrWidget]은 우리 프로젝트의 공통 QR 생성 위젯입니다.
/// 팀원 여러분, UI에서 QR 코드가 필요하면 이 위젯을 불러서 사용하세요!
class CommonQrWidget extends StatelessWidget {
  /// QR에 담고 싶은 텍스트나 데이터를 입력받습니다.
  final String data;
  
  /// QR 코드의 크기를 정합니다. (기본값 200)
  final double size;

  const CommonQrWidget({
    super.key,
    required this.data,
    this.size = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // 필요한 만큼만 공간 차지
      children: [
        // QR 인식률을 높이기 위해 흰색 배경 컨테이너를 사용합니다.
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300), // 살짝 테두리 추가
          ),
          child: QrImageView(
            data: data,
            version: QrVersions.auto,
            size: size,
          ),
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