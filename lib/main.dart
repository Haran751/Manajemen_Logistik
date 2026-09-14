import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wms_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/master_barang_screen.dart';
import 'screens/inbound_screen.dart';
import 'screens/outbound_screen.dart';
import 'screens/profile_screen.dart';

// Fungsi utama aplikasi yang dijalankan pertama kali
void main() {
  runApp(const WmsApp()); // Menjalankan widget WmsApp sebagai root aplikasi
}

// Custom scroll behavior untuk memberikan efek bounce pada scroll
class SmoothScrollBehavior extends ScrollBehavior {
  const SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Menggunakan BouncingScrollPhysics untuk efek memantul di ujung scroll (khas iOS)
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

// Widget utama (Root) aplikasi
class WmsApp extends StatelessWidget {
  const WmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider digunakan untuk manajemen state menggunakan provider
    return ChangeNotifierProvider(
      create: (_) => WmsProvider(), // Menginisialisasi WmsProvider
      child: MaterialApp(
        title: 'WMS Gudang Utama',
        debugShowCheckedModeBanner: false, // Menghilangkan banner debug
        scrollBehavior: const SmoothScrollBehavior(), // Menerapkan custom scroll behavior
        theme: ThemeData(
          useMaterial3: true, // Menggunakan Material 3 design system
          fontFamily: 'Roboto', // Mengatur font default
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B00), // Warna utama oranye
            primary: const Color(0xFFFF6B00),
            surface: const Color(0xFFF8FAFC), // Warna latar belakang permukaan
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Warna latar belakang scaffold
        ),
        home: const MainNavigationScreen(), // Menentukan layar awal navigasi utama
      ),
    );
  }
}

// Layar navigasi utama yang memiliki bottom navigation bar
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0; // Index tab yang sedang aktif
  late PageController _pageController; // Controller untuk mengatur PageView

  @override
  void initState() {
    super.initState();
    // Menginisialisasi PageController dengan halaman awal sesuai _currentIndex
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    // Selalu dispose controller untuk mencegah memory leak
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi yang dipanggil ketika salah satu tab pada bottom navigation ditekan
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Memperbarui index aktif
    });
    // Melakukan animasi transisi halaman ke index yang dipilih
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Daftar layar (screen) yang sesuai dengan tiap tab
    final List<Widget> screens = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const MasterBarangScreen(),
      const InboundScreen(),
      const OutboundScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // Menggunakan PageView agar pengguna bisa menggeser halaman (swipe) antar tab
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          // Memperbarui index saat halaman digeser secara manual
          setState(() {
            _currentIndex = index;
          });
        },
        physics: const BouncingScrollPhysics(), // Efek memantul saat menggeser
        children: screens,
      ),
      // Bottom navigation bar kustom
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), // Efek bayangan halus
              blurRadius: 10,
              offset: const Offset(0, -2), // Posisi bayangan sedikit ke atas
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex, // Menandai tab yang sedang aktif
          onTap: _onTabTapped, // Aksi ketika tab ditekan
          type: BottomNavigationBarType.fixed, // Tipe fixed agar semua label tampil
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFFF6B00), // Warna saat tab dipilih
          unselectedItemColor: const Color(0xFF94A3B8), // Warna saat tab tidak dipilih
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          // Definisi setiap item pada bottom navigation
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.move_to_inbox_rounded),
              label: 'Inbound',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.outbox_rounded),
              label: 'Outbound',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
