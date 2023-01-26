import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QrCodeView extends StatelessWidget {
  const QrCodeView({
    Key? key,
    required this.size,
    required this.data,
  }) : super(key: key);
  final double size;
  final String data;
  @override
  Widget build(BuildContext context) {
    return PrettyQr(
      image: const AssetImage('assets/icons/app_icon.png'),
      typeNumber: 3,
      size: size,
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.M,
      roundEdges: true,
    );
  }
}
