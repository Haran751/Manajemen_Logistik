import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wms_provider.dart';
import '../widgets/inventory_chart.dart';

// Layar utama (Dashboard) yang menampilkan ringkasan informasi gudang
class DashboardScreen extends StatelessWidget {
  // Callback function opsional untuk navigasi ke tab lain melalui bottom navigation
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    // Consumer digunakan untuk mendengarkan perubahan data dari WmsProvider
    return Consumer<WmsProvider>(
      builder: (context, provider, child) {
        // Mengambil daftar barang yang stoknya menipis (di bawah batas minimum)
        final lowStockItems = provider.lowStockProducts;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC), // Warna latar abu-abu terang
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==== Header Dashboard (Nama Gudang & Profil) ====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Warehouse name',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Gudang Utama Jakarta',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Ikon profil pengguna
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFFE2E8F0),
                            child: Icon(Icons.person, color: Color(0xFF475569)),
                          ),
                          const SizedBox(width: 10),
                          // Ikon Notifikasi dengan badge (angka jumlah stok rendah)
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Icon(
                                  Icons.notifications_none_outlined,
                                  color: Color(0xFF334155),
                                  size: 22,
                                ),
                              ),
                              // Badge merah di sudut atas yang menampilkan jumlah alert
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6B00),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${lowStockItems.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ==== 4 Kartu Ringkasan Metrik (2x2 Grid) ====
                  // Baris pertama metrik: Total Stock & Barang Masuk
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          icon: Icons.inventory_2_outlined,
                          iconColor: const Color(0xFFFF6B00),
                          label: 'Total Stock',
                          value: '${provider.totalStock}', // Mengambil total dari provider
                          subtitle: '',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          icon: Icons.output_outlined,
                          iconColor: const Color(0xFFFF6B00),
                          label: 'Barang Masuk\nHari Ini',
                          value: '${provider.inboundToday}', // Mengambil jumlah inbound hari ini
                          subtitle: 'Units',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Baris kedua metrik: Barang Keluar & Low Stock Alert
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          icon: Icons.shortcut_outlined,
                          iconColor: const Color(0xFFFF6B00),
                          label: 'Barang Keluar\nHari Ini',
                          value: '${provider.outboundToday}', // Mengambil jumlah outbound hari ini
                          subtitle: 'Units',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          icon: Icons.warning_amber_rounded,
                          iconColor: const Color(0xFFFF3B30),
                          label: 'Low Stock\nAlert',
                          value: '${lowStockItems.length}', // Menampilkan jumlah barang yang perlu direstock
                          subtitle: 'Items',
                          isAlert: true, // Menandai sebagai peringatan dengan warna merah
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ==== Grafik Pergerakan Barang Mingguan (Inbound vs Outbound) ====
                  WeeklyMovementChart(data: provider.weeklyMovement),
                  const SizedBox(height: 20),

                  // ==== Bagian Peringatan Stok Menipis ====
                  Container(
                    width: double.infinity,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Stok Menipis',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFFEDD5)),
                              ),
                              child: const Text(
                                'Notification',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC2410C),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Jika tidak ada barang yang stoknya menipis
                        if (lowStockItems.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Semua stok barang mencukupi.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          // Jika ada barang dengan stok menipis, tampilkan daftarnya
                          Column(
                            children: lowStockItems.map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAFAFA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFF1F5F9)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Color(0xFFFF6B00),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Product: ${item.name}', // Nama barang
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                        // Label jumlah stok saat ini berwarna merah
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFE4E6),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Stok: ${item.stock} Unit',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFE11D48),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Lokasi: ${item.rackLocation} | Rekomendasi: Restock 50 Unit', // Info lokasi rak
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Tombol untuk merestock barang (mengarahkan ke tab Inbound)
                                    SizedBox(
                                      width: double.infinity,
                                      height: 32,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          if (onNavigateTab != null) {
                                            onNavigateTab!(2); // Mengarahkan navigasi ke tab Inbound (Index 2)
                                          }
                                        },
                                        icon: const Icon(Icons.add, size: 16, color: Color(0xFFFF6B00)),
                                        label: const Text(
                                          'Restock Sekarang (Inbound)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFF6B00),
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFFFF6B00)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Fungsi utilitas untuk membangun widget kartu ringkasan/metrik
  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
    bool isAlert = false, // Jika true, batas kartu akan berwarna merah (untuk peringatan)
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isAlert ? Border.all(color: const Color(0xFFFECACA), width: 1.5) : null,
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
          Row(
            children: [
              // Latar belakang ikon yang sedikit transparan sesuai warna ikon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              // Judul kartu metrik
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nilai (Value) yang besar beserta subtitlenya (misalnya unit)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isAlert ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
