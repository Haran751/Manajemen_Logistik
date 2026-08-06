import 'package:flutter/material.dart';

class BarcodeWidget extends StatelessWidget {
  final String code;
  final double width;
  final double height;
  final bool showText;
  final Color color;

  const BarcodeWidget({
    super.key,
    required this.code,
    this.width = 220,
    this.height = 65,
    this.showText = true,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _BarcodePainter(code: code, color: color),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 4),
          Text(
            'SKU: $code',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
              fontFamily: 'monospace',
              color: Colors.black87,
            ),
          ),
        ],
      ],
    );
  }
}

class _BarcodePainter extends CustomPainter {
  final String code;
  final Color color;

  _BarcodePainter({required this.code, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Pseudo-random deterministic patterns derived from code string
    final seed = code.hashCode;
    final bitPattern = _generateBitPattern(code, seed);

    final totalBits = bitPattern.length;
    final bitWidth = size.width / totalBits;

    for (int i = 0; i < totalBits; i++) {
      if (bitPattern[i] == '1') {
        final x = i * bitWidth;
        // Make guard bars slightly longer
        final isGuard = i < 3 || (i > totalBits ~/ 2 - 2 && i < totalBits ~/ 2 + 2) || i > totalBits - 4;
        final barHeight = isGuard ? size.height : size.height * 0.88;
        canvas.drawRect(
          Rect.fromLTWH(x, 0, bitWidth * 0.9, barHeight),
          paint,
        );
      }
    }
  }

  List<String> _generateBitPattern(String input, int seed) {
    // Generate code 128 / EAN style visual pattern
    final List<String> bits = [];
    bits.addAll(['1', '0', '1']); // Start guard

    for (int i = 0; i < input.length; i++) {
      int charCode = input.codeUnitAt(i);
      String val = charCode.toRadixString(2).padLeft(7, '0');
      for (var c in val.split('')) {
        bits.add(c);
      }
    }

    // Add middle and end guards
    bits.addAll(['0', '1', '0', '1', '0']);
    bits.addAll(['1', '0', '1']);

    return bits;
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) {
    return oldDelegate.code != code || oldDelegate.color != color;
  }
}
