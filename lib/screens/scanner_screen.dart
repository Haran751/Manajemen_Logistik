import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Layar scanner barcode aktual menggunakan kamera perangkat
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  // Controller untuk mengelola library MobileScanner (Kamera)
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.all], // Mendukung semua format barcode & QR
  );

  // Status (flag) untuk memastikan scan hanya membaca sekali
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    // Menambahkan observer untuk memantau status aplikasi (misal: masuk background)
    WidgetsBinding.instance.addObserver(this);
  }

  // Fungsi yang dipanggil saat status aplikasi berubah (resume, pause, dll)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        // Jangan lakukan apapun jika aplikasi di-pause atau di-hide
        return;
      case AppLifecycleState.resumed:
        // Aktifkan kembali kamera saat aplikasi dilanjutkan (resume)
        controller.start();
        break;
      case AppLifecycleState.inactive:
        // Matikan kamera saat aplikasi inaktif (menghindari boros baterai)
        controller.stop();
        break;
    }
  }

  @override
  void dispose() {
    // Hapus observer dan matikan controller kamera saat layar ditutup
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  // Fungsi callback ketika barcode berhasil dideteksi oleh kamera
  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return; // Mencegah multi-scan dalam sekali baca
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first.rawValue; // Mengambil data string (nilai) dari barcode
      if (barcode != null) {
        setState(() {
          _isScanned = true; // Tandai sudah ter-scan
        });
        // Kembali ke layar sebelumnya dengan membawa hasil barcode
        Navigator.pop(context, barcode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam ala aplikasi kamera
      appBar: AppBar(
        title: const Text('Scan Barcode', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Tombol untuk menyalakan/mematikan lampu kilat (senter/flashlight)
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.flash_on),
            iconSize: 32.0,
            onPressed: () => controller.toggleTorch(),
          ),
          // Tombol untuk mengganti kamera (depan/belakang)
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.flip_camera_ios),
            iconSize: 32.0,
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Widget kamera pemindai barcode
          MobileScanner(
            controller: controller,
            onDetect: _onDetect, // Terpicu jika barcode tertangkap kamera
            errorBuilder: (context, error, child) {
              // Jika terjadi error pada kamera (misal izin ditolak)
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Kamera Error: ${error.errorDetails?.message ?? error.errorCode}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          // Kotak frame penunjuk sasaran (Overlay) di tengah layar
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFF6B00), width: 3), // Garis border warna oranye
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Teks panduan di bawah kotak target
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Arahkan kamera ke Barcode/QR Code',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
