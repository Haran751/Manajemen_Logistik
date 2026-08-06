class Product {
  final String sku;
  final String name;
  final String brand;
  final String category;
  int stock;
  final String rackLocation;
  final String receiveDate;
  final String countryOfOrigin;
  final String supplier;
  final int minStockThreshold;
  final List<ScanHistoryEntry> scanHistory;

  Product({
    required this.sku,
    required this.name,
    required this.brand,
    required this.category,
    required this.stock,
    required this.rackLocation,
    required this.receiveDate,
    required this.countryOfOrigin,
    this.supplier = 'PT Logistik Utama',
    this.minStockThreshold = 20,
    List<ScanHistoryEntry>? scanHistory,
  }) : scanHistory = scanHistory ?? [];
}

class ScanHistoryEntry {
  final DateTime timestamp;
  final String action; // 'Inbound', 'Outbound', 'Stock Check'

  ScanHistoryEntry({
    required this.timestamp,
    required this.action,
  });
}

class InboundRecord {
  final String id;
  final String sku;
  final String name;
  final String brand;
  final String category;
  final int quantityReceived;
  final String supplier;
  final String receiveDate;
  final String storageLocation;
  final String countryOfOrigin;

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

class PickingItem {
  final Product product;
  final int quantity;
  final String rackLocation;
  bool isPicked;

  PickingItem({
    required this.product,
    required this.quantity,
    required this.rackLocation,
    this.isPicked = false,
  });
}

class OutboundShipment {
  final String shipmentNumber;
  final String receiverName;
  final String destination;
  final String shipmentDate;
  final List<PickingItem> items;
  bool isStockUpdated;
  bool isDispatched;

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

class WeeklyDataPoint {
  final String day; // 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'
  final int inbound;
  final int outbound;

  WeeklyDataPoint({
    required this.day,
    required this.inbound,
    required this.outbound,
  });
}
