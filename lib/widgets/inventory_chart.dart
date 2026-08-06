import 'package:flutter/material.dart';
import '../models/wms_model.dart';

class WeeklyMovementChart extends StatelessWidget {
  final List<WeeklyDataPoint> data;

  const WeeklyMovementChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Arus Barang Mingguan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            children: [
              _buildLegendItem(const Color(0xFFFF6B00), 'Barang Masuk'),
              const SizedBox(width: 20),
              _buildLegendItem(const Color(0xFF1E293B), 'Barang Keluar'),
            ],
          ),
          const SizedBox(height: 16),

          // Chart Body
          SizedBox(
            height: 160,
            child: Row(
              children: [
                // Y-Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('100', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('80', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('60', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('40', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('20', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('0', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 8),

                // Chart Bars Area
                Expanded(
                  child: CustomPaint(
                    painter: _BarChartPainter(data: data),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<WeeklyDataPoint> data;

  _BarChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    final orangePaint = Paint()
      ..color = const Color(0xFFFF6B00)
      ..style = PaintingStyle.fill;

    final navyPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    // Draw horizontal grid lines
    const int lines = 5;
    for (int i = 0; i <= lines; i++) {
      final y = size.height * (i / lines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (data.isEmpty) return;

    final double groupWidth = size.width / data.length;
    const double barWidth = 9.0;
    const double barSpacing = 3.0;

    for (int i = 0; i < data.length; i++) {
      final dp = data[i];
      final double groupCenterX = (i * groupWidth) + (groupWidth / 2);

      // Inbound Bar (Orange)
      final double inboundHeight = (dp.inbound / 100.0).clamp(0.0, 1.0) * size.height;
      final double inboundX = groupCenterX - barWidth - (barSpacing / 2);
      final double inboundY = size.height - inboundHeight;

      final RRect inboundRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(inboundX, inboundY, barWidth, inboundHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(inboundRect, orangePaint);

      // Outbound Bar (Navy)
      final double outboundHeight = (dp.outbound / 100.0).clamp(0.0, 1.0) * size.height;
      final double outboundX = groupCenterX + (barSpacing / 2);
      final double outboundY = size.height - outboundHeight;

      final RRect outboundRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(outboundX, outboundY, barWidth, outboundHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(outboundRect, navyPaint);

      // X-Axis Day Text
      final textPainter = TextPainter(
        text: TextSpan(
          text: dp.day,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(groupCenterX - (textPainter.width / 2), size.height + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
