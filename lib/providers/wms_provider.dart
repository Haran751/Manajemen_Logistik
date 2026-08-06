import 'package:flutter/material.dart';
import '../models/wms_model.dart';

class WmsProvider extends ChangeNotifier {
  final List<Product> _products = [
    Product(
      sku: 'BRG-00123',
      name: 'Wireless Scanner Zebra',
      brand: 'Zebra',
      category: 'Elektronik',
      stock: 45,
      rackLocation: 'Rack A-03',
      receiveDate: '2024-10-28',
      countryOfOrigin: 'Indonesia',
      supplier: 'PT Elektronik Jaya',
      minStockThreshold: 20,
      scanHistory: [
        ScanHistoryEntry(timestamp: DateTime(2023, 1, 22, 0, 37), action: 'Scan Check'),
        ScanHistoryEntry(timestamp: DateTime(2024, 10, 28, 9, 30), action: 'Inbound +45'),
      ],
    ),
    Product(
      sku: 'BRG-00124',
      name: 'Laptop Dell Inspiron',
      brand: 'Dell',
      category: 'Elektronik',
      stock: 28,
      rackLocation: 'Rack B-02',
      receiveDate: '2024-10-25',
      countryOfOrigin: 'USA',
      supplier: 'PT Dell Indonesia',
      minStockThreshold: 20,
      scanHistory: [
        ScanHistoryEntry(timestamp: DateTime(2024, 10, 25, 14, 15), action: 'Inbound +33'),
      ],
    ),
    Product(
      sku: 'BRG-00125',
      name: 'Mouse Logitech MX Master',
      brand: 'Logitech',
      category: 'Aksesoris',
      stock: 15,
      rackLocation: 'Rak C-01',
      receiveDate: '2024-10-20',
      countryOfOrigin: 'China',
      supplier: 'PT Aksesoris Komputer',
      minStockThreshold: 25, // Under threshold -> Low stock alert!
      scanHistory: [
        ScanHistoryEntry(timestamp: DateTime(2024, 10, 20, 11, 00), action: 'Inbound +50'),
        ScanHistoryEntry(timestamp: DateTime(2024, 10, 27, 16, 20), action: 'Outbound -35'),
      ],
    ),
    Product(
      sku: 'BRG-00126',
      name: 'Thermal Printer Zebra ZD420',
      brand: 'Zebra',
      category: 'Elektronik',
      stock: 12,
      rackLocation: 'Rack A-05',
      receiveDate: '2024-10-18',
      countryOfOrigin: 'Indonesia',
      supplier: 'PT Zebra Solutions',
      minStockThreshold: 15, // Under threshold
      scanHistory: [
        ScanHistoryEntry(timestamp: DateTime(2024, 10, 18, 10, 30), action: 'Inbound +20'),
      ],
    ),
    Product(
      sku: 'BRG-00127',
      name: 'Keychron K2 Mechanical Keyboard',
      brand: 'Keychron',
      category: 'Aksesoris',
      stock: 65,
      rackLocation: 'Rack C-04',
      receiveDate: '2024-10-15',
      countryOfOrigin: 'Vietnam',
      supplier: 'PT Keychron Indo',
      minStockThreshold: 20,
      scanHistory: [
        ScanHistoryEntry(timestamp: DateTime(2024, 10, 15, 8, 45), action: 'Inbound +80'),
      ],
    ),
  ];

  int _inboundToday = 185;
  int _outboundToday = 132;

  final List<WeeklyDataPoint> _weeklyMovement = [
    WeeklyDataPoint(day: 'Sen', inbound: 65, outbound: 38),
    WeeklyDataPoint(day: 'Sel', inbound: 85, outbound: 45),
    WeeklyDataPoint(day: 'Rab', inbound: 85, outbound: 60),
    WeeklyDataPoint(day: 'Kam', inbound: 70, outbound: 50),
    WeeklyDataPoint(day: 'Jum', inbound: 98, outbound: 35),
    WeeklyDataPoint(day: 'Sab', inbound: 75, outbound: 38),
    WeeklyDataPoint(day: 'Min', inbound: 90, outbound: 45),
  ];

  late OutboundShipment _activeShipment;

  WmsProvider() {
    _initActiveShipment();
  }

  void _initActiveShipment() {
    _activeShipment = OutboundShipment(
      shipmentNumber: 'SJ-20241028-001',
      receiverName: 'PT Berdikari Jaya',
      destination: 'Surabaya',
      shipmentDate: '2024-10-28',
      items: [
        PickingItem(
          product: _products.firstWhere((p) => p.sku == 'BRG-00124'),
          quantity: 5,
          rackLocation: 'Rack B-02',
          isPicked: true,
        ),
        PickingItem(
          product: _products.firstWhere((p) => p.sku == 'BRG-00125'),
          quantity: 10,
          rackLocation: 'Rak C-01',
          isPicked: true,
        ),
      ],
      isStockUpdated: true,
    );
  }

  // Getters
  List<Product> get products => List.unmodifiable(_products);
  int get inboundToday => _inboundToday;
  int get outboundToday => _outboundToday;
  List<WeeklyDataPoint> get weeklyMovement => List.unmodifiable(_weeklyMovement);
  OutboundShipment get activeShipment => _activeShipment;

  int get totalStock => _products.fold(0, (sum, item) => sum + item.stock);

  List<Product> get lowStockProducts =>
      _products.where((p) => p.stock <= p.minStockThreshold).toList();

  // Search & Filter
  String _searchQuery = '';
  String _selectedCategory = 'All';

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesQuery = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.brand.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  // Operations
  void addProductInbound(InboundRecord record) {
    final existingIndex = _products.indexWhere((p) => p.sku == record.sku);
    if (existingIndex >= 0) {
      _products[existingIndex].stock += record.quantityReceived;
      _products[existingIndex].scanHistory.insert(
        0,
        ScanHistoryEntry(
          timestamp: DateTime.now(),
          action: 'Inbound +${record.quantityReceived}',
        ),
      );
    } else {
      _products.insert(
        0,
        Product(
          sku: record.sku,
          name: record.name,
          brand: record.brand,
          category: record.category,
          stock: record.quantityReceived,
          rackLocation: record.storageLocation,
          receiveDate: record.receiveDate,
          countryOfOrigin: record.countryOfOrigin,
          supplier: record.supplier,
          scanHistory: [
            ScanHistoryEntry(
              timestamp: DateTime.now(),
              action: 'Inbound +${record.quantityReceived}',
            ),
          ],
        ),
      );
    }

    _inboundToday += record.quantityReceived;
    notifyListeners();
  }

  void updateProductStock(Product product, int newStock) {
    product.stock = newStock;
    notifyListeners();
  }

  void toggleItemPicked(int index) {
    if (index >= 0 && index < _activeShipment.items.length) {
      _activeShipment.items[index].isPicked = !_activeShipment.items[index].isPicked;
      notifyListeners();
    }
  }

  void markAllItemsPicked() {
    for (var item in _activeShipment.items) {
      item.isPicked = true;
    }
    notifyListeners();
  }

  bool updateStockFromOutbound() {
    if (_activeShipment.isStockUpdated) return false;

    for (var item in _activeShipment.items) {
      if (item.isPicked) {
        final prod = item.product;
        prod.stock = (prod.stock - item.quantity).clamp(0, 999999);
        prod.scanHistory.insert(
          0,
          ScanHistoryEntry(
            timestamp: DateTime.now(),
            action: 'Outbound -${item.quantity}',
          ),
        );
        _outboundToday += item.quantity;
      }
    }

    _activeShipment.isStockUpdated = true;
    notifyListeners();
    return true;
  }

  void createNewShipment({
    required String receiverName,
    required String destination,
    required String shipmentDate,
    required List<PickingItem> items,
  }) {
    final newId = 'SJ-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${(_products.length + 1).toString().padLeft(3, '0')}';
    _activeShipment = OutboundShipment(
      shipmentNumber: newId,
      receiverName: receiverName,
      destination: destination,
      shipmentDate: shipmentDate,
      items: items,
      isStockUpdated: false,
    );
    notifyListeners();
  }
}
