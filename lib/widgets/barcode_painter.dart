import 'package:flutter/material.dart';

// Widget khusus untuk merender (menggambar) gambar barcode berdasarkan teks (SKU)
class BarcodeWidget extends StatelessWidget {
  final String code; // Teks atau kode SKU yang akan dijadikan barcode
  final double width; // Lebar gambar barcode
  final double height; // Tinggi gambar barcode
  final bool showText; // Apakah teks kode ingin ditampilkan di bawah barcode?
  final Color color; // Warna garis barcode

  const BarcodeWidget({
    super.key,
    required this.code,
    this.width = 220,
    this.height = 65,
    this.showText = true, // Default menampilkan teks
    this.color = Colors.black, // Default warna hitam
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Wadah untuk kanvas kustom tempat barcode digambar
        SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _BarcodePainter(code: code, color: color), // Memanggil class pelukis kustom
          ),
        ),
        // Menampilkan teks SKU jika showText bernilai true
        if (showText) ...[
          const SizedBox(height: 4),
          Text(
            'SKU: $code',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
              fontFamily: 'monospace', // Menggunakan font bergaya mesin tik
              color: Colors.black87,
            ),
          ),
        ],
      ],
    );
  }
}

// Class pelukis (Painter) khusus yang bertugas menggambar garis-garis barcode
class _BarcodePainter extends CustomPainter {
  final String code;
  final Color color;

  _BarcodePainter({required this.code, required this.color});

  // Fungsi paint yang dipanggil setiap kali layar butuh menggambar ulang barcode
  @override
  void paint(Canvas canvas, Size size) {
    // Siapkan 'kuas' (paint) dengan warna yang ditentukan
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill; // Menggunakan gaya isian penuh (fill)

    // Menghasilkan pola garis berdasarkan teks (bersifat deterministik/pasti)
    final seed = code.hashCode; // Angka unik dari teks
    final bitPattern = _generateBitPattern(code, seed); // Mengubah teks jadi urutan "1" dan "0"

    final totalBits = bitPattern.length; // Total garis/spasi
    final bitWidth = size.width / totalBits; // Ketebalan satu garis/spasi

    // Proses menggambar garis satu-per-satu dari kiri ke kanan
    for (int i = 0; i < totalBits; i++) {
      if (bitPattern[i] == '1') { // Jika bit 1, gambar garis (jika 0, biarkan kosong sebagai spasi)
        final x = i * bitWidth; // Posisi x untuk garis ini

        // Menentukan garis penjaga (guard bars - garis di pinggir dan tengah yang biasanya lebih panjang)
        final isGuard = i < 3 || (i > totalBits ~/ 2 - 2 && i < totalBits ~/ 2 + 2) || i > totalBits - 4;
        
        // Garis guard sedikit lebih panjang sampai bawah (100%), yang lain hanya 88% tingginya
        final barHeight = isGuard ? size.height : size.height * 0.88;
        
        // Menggambar persegi panjang sebagai garis barcode
        canvas.drawRect(
          Rect.fromLTWH(x, 0, bitWidth * 0.9, barHeight), // bitWidth * 0.9 agar ada jarak ekstra tipis
          paint,
        );
      }
    }
  }

  // Fungsi algoritma pengubah string teks menjadi array '0' dan '1' (visual barcode semu)
  List<String> _generateBitPattern(String input, int seed) {
    final List<String> bits = [];
    bits.addAll(['1', '0', '1']); // Pola garis penjaga (Guard) Awal

    // Loop setiap huruf dari input teks
    for (int i = 0; i < input.length; i++) {
      int charCode = input.codeUnitAt(i); // Mengambil nilai ASCII
      // Mengubah nilai ASCII ke format biner (misal 'A' jadi '1000001')
      String val = charCode.toRadixString(2).padLeft(7, '0');
      // Memasukkan setiap bit (1 atau 0) ke dalam array
      for (var c in val.split('')) {
        bits.add(c);
      }
    }

    // Menambahkan pola garis penjaga (Guard) Tengah
    bits.addAll(['0', '1', '0', '1', '0']);
    // Menambahkan pola garis penjaga (Guard) Akhir
    bits.addAll(['1', '0', '1']);

    return bits;
  }

  // Fungsi yang menentukan apakah kanvas perlu digambar ulang
  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) {
    // Akan gambar ulang hanya jika kode teks atau warnanya berubah
    return oldDelegate.code != code || oldDelegate.color != color;
  }
}
