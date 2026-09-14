// Model untuk merepresentasikan sebuah produk/barang dalam sistem inventory
class Product {
  final String sku; // Stock Keeping Unit (kode unik barang)
  final String name; // Nama barang
  final String brand; // Merek barang
  final String category; // Kategori barang
  int stock; // Jumlah stok saat ini (bisa berubah)
  final String rackLocation; // Lokasi rak penyimpanan di gudang
  final String receiveDate; // Tanggal barang diterima
  final String countryOfOrigin; // Negara asal barang
  final String supplier; // Nama supplier/pemasok
  final int minStockThreshold; // Batas minimal stok untuk peringatan
  final List<ScanHistoryEntry> scanHistory; // Riwayat pemindaian barcode barang

  Product({
    required this.sku,
    required this.name,
    required this.brand,
    required this.category,
    required this.stock,
    required this.rackLocation,
    required this.receiveDate,
    required this.countryOfOrigin,
    this.supplier = 'PT Logistik Utama', // Default supplier jika tidak diisi
    this.minStockThreshold = 20, // Default batas minimal stok
    List<ScanHistoryEntry>? scanHistory,
  }) : scanHistory = scanHistory ?? []; // Menginisialisasi list kosong jika null
}

// Model untuk menyimpan riwayat setiap kali barang discan
class ScanHistoryEntry {
  final DateTime timestamp; // Waktu pemindaian
  final String action; // Aksi yang dilakukan: 'Inbound', 'Outbound', atau 'Stock Check'

  ScanHistoryEntry({
    required this.timestamp,
    required this.action,
  });
}

// Model untuk merekam setiap transaksi masuk (inbound) barang
class InboundRecord {
  final String id; // ID transaksi inbound
  final String sku; // SKU barang yang masuk
  final String name; // Nama barang
  final String brand; // Merek barang
  final String category; // Kategori barang
  final int quantityReceived; // Jumlah barang yang diterima
  final String supplier; // Supplier pengirim barang
  final String receiveDate; // Tanggal penerimaan
  final String storageLocation; // Lokasi rak/penyimpanan
  final String countryOfOrigin; // Negara asal

  InboundRecord({
    required this.id,
    required this.sku,
    required this.name,
    required this.brand,
    required this.category,
    required this.quantityReceived,
    required this.supplier,
    required this.receiveDate,
    required this.storageLocation,
    required this.countryOfOrigin,
  });
}

// Model untuk item yang akan diambil (picking) saat proses outbound
class PickingItem {
  final Product product; // Produk yang diambil
  final int quantity; // Jumlah yang perlu diambil
  final String rackLocation; // Lokasi rak untuk mempermudah pencarian
  bool isPicked; // Status apakah barang sudah diambil (true/false)

  PickingItem({
    required this.product,
    required this.quantity,
    required this.rackLocation,
    this.isPicked = false, // Default belum diambil
  });
}

// Model untuk data pengiriman barang keluar (outbound shipment)
class OutboundShipment {
  final String shipmentNumber; // Nomor pengiriman/surat jalan
  final String receiverName; // Nama penerima/tujuan
  final String destination; // Alamat tujuan
  final String shipmentDate; // Tanggal pengiriman
  final List<PickingItem> items; // Daftar barang yang dikirim
  bool isStockUpdated; // Status apakah stok di inventory sudah dipotong
  bool isDispatched; // Status apakah barang sudah diberangkatkan

  OutboundShipment({
    required this.shipmentNumber,
    required this.receiverName,
    required this.destination,
    required this.shipmentDate,
    required this.items,
    this.isStockUpdated = false,
    this.isDispatched = false,
  });
}

// Model untuk data chart/grafik mingguan (Inbound vs Outbound)
class WeeklyDataPoint {
  final String day; // Hari: 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'
  final int inbound; // Total jumlah inbound pada hari tersebut
  final int outbound; // Total jumlah outbound pada hari tersebut

  WeeklyDataPoint({
    required this.day,
    required this.inbound,
    required this.outbound,
  });
}
