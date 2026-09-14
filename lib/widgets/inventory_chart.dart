import 'package:flutter/material.dart';
import '../models/wms_model.dart';

// Widget khusus untuk menampilkan grafik batang pergerakan arus barang (masuk & keluar) per minggu
class WeeklyMovementChart extends StatelessWidget {
  final List<WeeklyDataPoint> data; // List data statistik mingguan

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
            color: Colors.black.withValues(alpha: 0.04), // Bayangan lembut untuk efek kartu (card)
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul grafik
          const Text(
            'Arus Barang Mingguan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),

          // ==== Legenda Grafik (Keterangan Warna) ====
          Row(
            children: [
              _buildLegendItem(const Color(0xFFFF6B00), 'Barang Masuk'), // Oranye untuk Inbound
              const SizedBox(width: 20),
              _buildLegendItem(const Color(0xFF1E293B), 'Barang Keluar'), // Biru tua untuk Outbound
            ],
          ),
          const SizedBox(height: 16),

          // ==== Area Tubuh Grafik (Body) ====
          SizedBox(
            height: 160, // Tinggi grafik statis
            child: Row(
              children: [
                // Label Sumbu Y (Nilai dari 0 - 100)
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

                // Area Kanvas Batang Grafik
                Expanded(
                  child: CustomPaint(
                    painter: _BarChartPainter(data: data), // Memanggil pelukis kustom grafik
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi pembuat ikon dan teks untuk keterangan warna legenda
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

// Pelukis kustom (Custom Painter) khusus untuk menggambar sumbu dan batang grafik
class _BarChartPainter extends CustomPainter {
  final List<WeeklyDataPoint> data;

  _BarChartPainter({required this.data});

  // Logika menggambar dieksekusi di fungsi paint
  @override
  void paint(Canvas canvas, Size size) {
    // Definisi warna dan ketebalan garis (grid horizontanl)
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    // Warna isi untuk batang Inbound (Barang Masuk)
    final orangePaint = Paint()
      ..color = const Color(0xFFFF6B00)
      ..style = PaintingStyle.fill;

    // Warna isi untuk batang Outbound (Barang Keluar)
    final navyPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    // 1. Menggambar Garis Grid Horizontal (5 baris)
    const int lines = 5;
    for (int i = 0; i <= lines; i++) {
      final y = size.height * (i / lines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Jika tidak ada data, hentikan proses menggambar batang
    if (data.isEmpty) return;

    // Mengukur ruang antar batang berdasarkan lebar layar dan jumlah data
    final double groupWidth = size.width / data.length;
    const double barWidth = 9.0; // Lebar per batang grafik
    const double barSpacing = 3.0; // Jarak antara batang masuk dan batang keluar di hari yang sama

    // 2. Menggambar Data Batang dan Label X-Axis
    for (int i = 0; i < data.length; i++) {
      final dp = data[i];
      final double groupCenterX = (i * groupWidth) + (groupWidth / 2); // Titik tengah per hari

      // --- Batang Barang Masuk (Inbound) - Warna Oranye ---
      // Menghitung tinggi relatif (maksimal dianggap 100), memastikan nilainya di antara 0-1
      final double inboundHeight = (dp.inbound / 100.0).clamp(0.0, 1.0) * size.height;
      final double inboundX = groupCenterX - barWidth - (barSpacing / 2);
      final double inboundY = size.height - inboundHeight; // Mulai y dari bawah layar

      // Menggambar persegi berujung bulat
      final RRect inboundRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(inboundX, inboundY, barWidth, inboundHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(inboundRect, orangePaint);

      // --- Batang Barang Keluar (Outbound) - Warna Biru Tua ---
      final double outboundHeight = (dp.outbound / 100.0).clamp(0.0, 1.0) * size.height;
      final double outboundX = groupCenterX + (barSpacing / 2);
      final double outboundY = size.height - outboundHeight;

      final RRect outboundRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(outboundX, outboundY, barWidth, outboundHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(outboundRect, navyPaint);

      // --- Menggambar Teks Sumbu X (Nama Hari) ---
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
        Offset(groupCenterX - (textPainter.width / 2), size.height + 6), // Posisi teks di bawah batang
      );
    }
  }

  // Apakah layar harus digambar ulang jika widget diperbarui?
  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.data != data; // Ya, jika data berubah
  }
}
