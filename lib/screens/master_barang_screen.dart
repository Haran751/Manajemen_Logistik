import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wms_model.dart';
import '../providers/wms_provider.dart';
import '../widgets/barcode_painter.dart';
import 'scanner_screen.dart';

// Layar Master Barang yang menampilkan seluruh inventaris gudang
class MasterBarangScreen extends StatefulWidget {
  const MasterBarangScreen({super.key});

  @override
  State<MasterBarangScreen> createState() => _MasterBarangScreenState();
}

class _MasterBarangScreenState extends State<MasterBarangScreen> {
  // Controller untuk field pencarian
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    // Mematikan controller saat layar dihancurkan untuk mencegah memory leak
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menghubungkan ke WmsProvider untuk mendapatkan data state
    final provider = Provider.of<WmsProvider>(context);
    // Mengambil daftar produk yang sudah difilter (berdasarkan pencarian dan kategori)
    final products = provider.filteredProducts;
    // Daftar kategori yang tersedia
    final categories = ['All', 'Elektronik', 'Aksesoris'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Latar belakang abu-abu terang
      appBar: AppBar(
        title: const Text(
          'Master Barang / Inventory',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          // Tombol tambah barang baru
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Color(0xFFFF6B00)),
            onPressed: () => _showAddEditProductModal(context), // Tampilkan form modal
            tooltip: 'Tambah Barang Baru',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ==== Bagian Header: Pencarian & Filter Kategori ====
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  // Baris 1: Kolom input pencarian, tombol scanner, dan tombol filter
                  Row(
                    children: [
                      // Input teks untuk pencarian barang
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => provider.setSearchQuery(val), // Update filter di provider
                            decoration: const InputDecoration(
                              hintText: 'Search product...',
                              hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Tombol Scan Barcode (Membuka kamera)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B00).withValues(alpha: 0.1), // Oranye transparan
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: Color(0xFFFF6B00), size: 22),
                          onPressed: () async {
                            // Menavigasi ke ScannerScreen dan menunggu hasil
                            final scannedCode = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ScannerScreen()),
                            );

                            // Jika ada kode yang didapat dari scanner
                            if (scannedCode != null) {
                              _searchController.text = scannedCode;
                              provider.setSearchQuery(scannedCode); // Langsung lakukan filter
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Pencarian: $scannedCode'),
                                    backgroundColor: const Color(0xFF10B981), // Hijau
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tombol "Filter" statis
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.tune, size: 18, color: Color(0xFF475569)),
                            SizedBox(width: 4),
                            Text('Filter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ==== Filter Kategori (Chips) ====
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final cat = categories[idx];
                        final isSelected = provider.selectedCategory == cat; // Cek apakah kategori terpilih
                        
                        return GestureDetector(
                          onTap: () => provider.setSelectedCategory(cat), // Update kategori
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ==== Daftar Produk (List Produk) ====
            Expanded(
              child: products.isEmpty
                  // Jika daftar kosong atau tidak ditemukan barang
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 12),
                          Text(
                            'Tidak ada produk ditemukan',
                            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  // Jika ada barang, render ListView
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductCard(context, product); // Fungsi membuat kartu per produk
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi utilitas untuk merender satu kartu produk
  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Ikon, Informasi utama, menu opsi
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kotak untuk ikon barcode produk
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  size: 36,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(width: 12),

              // Detail produk
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SKU: ${product.sku}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Brand\n${product.brand}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 24),
                        Text(
                          'Category\n${product.category}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tombol opsi (3 titik vertikal) untuk detail & edit
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showAddEditProductModal(context, product: product);
                  } else if (value == 'detail') {
                    _showProductDetailModal(context, product);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'detail', child: Text('Lihat Detail')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit Produk')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)), // Garis pemisah
          const SizedBox(height: 10),

          // Baris 2: Stok dan Lokasi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stock', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                  Text(
                    '${product.stock} Unit',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B00),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Location', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                  Text(
                    product.rackLocation,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Baris 3: Tombol Aksi "View Detail" dan "Edit Product"
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: OutlinedButton(
                    onPressed: () => _showProductDetailModal(context, product),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'View Detail',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: OutlinedButton(
                    onPressed: () => _showAddEditProductModal(context, product: product),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Edit Product',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan form modal secara full layar (Bottom Sheet) untuk melihat detail barang
  void _showProductDetailModal(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Memungkinkan modal lebih tinggi
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // Sudut membulat di atas
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indikator drag / garis abu kecil di bagian atas modal
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Judul Modal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Product Detail Page',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context), // Tombol tutup modal
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Grid detail data produk
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailGridCell('SKU', product.sku),
                          _buildDetailGridCell('Category', product.category),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailGridCell('Brand', product.brand),
                          _buildDetailGridCell('Quantity', '${product.stock} Unit', valueColor: const Color(0xFFFF6B00)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailGridCell('Location', product.rackLocation),
                          _buildDetailGridCell('Receive Date', product.receiveDate),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailGridCell('Country of Origin', product.countryOfOrigin),
                          _buildDetailGridCell('Supplier', product.supplier),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Pratinjau Label Barcode
                Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Barcode Label',
                          style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        BarcodeWidget(code: product.sku, width: 240, height: 70), // Render barcode berdasarkan SKU
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Riwayat Pemindaian (Scan History)
                const Text(
                  'Scan History',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                if (product.scanHistory.isEmpty)
                  const Text('Belum ada riwayat scan', style: TextStyle(color: Colors.grey, fontSize: 12))
                else
                  Column(
                    // Menampilkan list data scan history yang ada di dalam model
                    children: product.scanHistory.map((hist) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.history, size: 16, color: Color(0xFFFF6B00)),
                            const SizedBox(width: 8),
                            Text(
                              hist.action,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(hist.timestamp),
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fungsi pembantu untuk membuat grid pada detail modal
  Widget _buildDetailGridCell(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // Formatting tanggal ke string untuk ditampilkan di layar
  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // Fungsi untuk menampilkan pop-up/dialog "Tambah Baru" atau "Edit" Produk
  void _showAddEditProductModal(BuildContext context, {Product? product}) {
    final isEdit = product != null;
    
    // Inisialisasi controller data form. Jika mode edit, isi dengan data barang lama.
    final skuCtrl = TextEditingController(text: isEdit ? product.sku : 'BRG-00${DateTime.now().millisecond}');
    final nameCtrl = TextEditingController(text: isEdit ? product.name : '');
    final brandCtrl = TextEditingController(text: isEdit ? product.brand : '');
    final categoryCtrl = TextEditingController(text: isEdit ? product.category : 'Elektronik');
    final stockCtrl = TextEditingController(text: isEdit ? product.stock.toString() : '10');
    final locationCtrl = TextEditingController(text: isEdit ? product.rackLocation : 'Rack A-01');
    final originCtrl = TextEditingController(text: isEdit ? product.countryOfOrigin : 'Indonesia');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU / Kode Barang')),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Produk')),
                TextField(controller: brandCtrl, decoration: const InputDecoration(labelText: 'Brand')),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Kategori')),
                TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah / Stok')),
                TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Lokasi Rack')),
                TextField(controller: originCtrl, decoration: const InputDecoration(labelText: 'Country of Origin')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Batal
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) return; // Validasi wajib diisi
                final provider = Provider.of<WmsProvider>(context, listen: false);
                
                if (isEdit) {
                  // Mode Edit: Update stok yang ada
                  final newStock = int.tryParse(stockCtrl.text) ?? product.stock;
                  provider.updateProductStock(product, newStock);
                } else {
                  // Mode Tambah Baru: Panggil provider untuk menambahkan data InboundRecord
                  provider.addProductInbound(
                    InboundRecord(
                      id: 'IN-${DateTime.now().millisecondsSinceEpoch}',
                      sku: skuCtrl.text,
                      name: nameCtrl.text,
                      brand: brandCtrl.text,
                      category: categoryCtrl.text,
                      quantityReceived: int.tryParse(stockCtrl.text) ?? 1,
                      supplier: 'PT Logistik Utama',
                      receiveDate: '2024-10-28',
                      storageLocation: locationCtrl.text,
                      countryOfOrigin: originCtrl.text,
                    ),
                  );
                }
                Navigator.pop(context); // Tutup dialog
                // Tampilkan pesan sukses
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Produk berhasil diperbarui!' : 'Produk berhasil ditambahkan!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
              child: Text(isEdit ? 'Simpan' : 'Tambah', style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
