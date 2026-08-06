import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wms_provider.dart';

class OutboundScreen extends StatefulWidget {
  const OutboundScreen({super.key});

  @override
  State<OutboundScreen> createState() => _OutboundScreenState();
}

class _OutboundScreenState extends State<OutboundScreen> {
  late TextEditingController _receiverCtrl;
  late TextEditingController _destCtrl;
  late TextEditingController _dateCtrl;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WmsProvider>(context, listen: false);
    final ship = provider.activeShipment;
    _receiverCtrl = TextEditingController(text: ship.receiverName);
    _destCtrl = TextEditingController(text: ship.destination);
    _dateCtrl = TextEditingController(text: ship.shipmentDate);
  }

  @override
  void dispose() {
    _receiverCtrl.dispose();
    _destCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WmsProvider>(
      builder: (context, provider, child) {
        final shipment = provider.activeShipment;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text(
              'Pengeluaran Barang',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Create Shipment Form Card
                  Container(
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
                          'Create Shipment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInputField('Customer/Receiver', _receiverCtrl),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _buildInputField('Destination', _destCtrl)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildInputField('Shipment Date', _dateCtrl)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Picking List Card
                  Container(
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
                          'Picking List',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // List of items to pick
                        Column(
                          children: List.generate(shipment.items.length, (index) {
                            final item = shipment.items[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: item.isPicked ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: item.isPicked ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: CheckboxListTile(
                                value: item.isPicked,
                                activeColor: const Color(0xFFFF6B00),
                                onChanged: (val) {
                                  provider.toggleItemPicked(index);
                                },
                                title: Text(
                                  item.product.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: item.isPicked ? const Color(0xFF15803D) : const Color(0xFF0F172A),
                                  ),
                                ),
                                subtitle: Text(
                                  'Quantity: ${item.quantity} | Rack: ${item.rackLocation}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                                controlAffinity: ListTileControlAffinity.leading,
                                dense: true,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),

                        // Mark Picked Item Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              provider.markAllItemsPicked();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Semua barang berhasil ditandai sebagai Picked!'),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE2E8F0),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Mark Picked Item',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Auto Stock Update Toggle Indicator
                        Row(
                          children: [
                            Icon(
                              shipment.isStockUpdated ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: shipment.isStockUpdated ? const Color(0xFF10B981) : const Color(0xFFFF6B00),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                shipment.isStockUpdated
                                    ? 'Update Stock Automatically (Ter-update)'
                                    : 'Update Stock Automatically',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: shipment.isStockUpdated ? const Color(0xFF15803D) : const Color(0xFF334155),
                                ),
                              ),
                            ),
                            if (!shipment.isStockUpdated)
                              TextButton(
                                onPressed: () {
                                  final success = provider.updateStockFromOutbound();
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Stok di Master Barang otomatis ter-potong!'),
                                        backgroundColor: Color(0xFFFF6B00),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Update Now', style: TextStyle(fontSize: 11, color: Color(0xFFFF6B00))),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Surat Jalan Document Preview Card (As in Mockup 4)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
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
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'Surat Jalan',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Shipment Number: ${shipment.shipmentNumber}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Receiver Details Box
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Receiver', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                              Text(
                                _receiverCtrl.text,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              Text(
                                'Tujuan: ${_destCtrl.text}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Item List Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          color: const Color(0xFFF1F5F9),
                          child: Row(
                            children: const [
                              Expanded(flex: 3, child: Text('Item List', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text('Quantity', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                              Expanded(flex: 1, child: Text('Rack', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                            ],
                          ),
                        ),

                        // Item List Table Rows
                        Column(
                          children: shipment.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item.product.name,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      item.rackLocation,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons: Download PDF, Share, Print
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton.icon(
                                  onPressed: () => _handleSuratJalanAction('Download PDF'),
                                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: Colors.white),
                                  label: const Text(
                                    'Download PDF',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6B00),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 40,
                                child: OutlinedButton(
                                  onPressed: () => _handleSuratJalanAction('Share Document'),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E293B),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text(
                                    'Share',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 40,
                                child: OutlinedButton(
                                  onPressed: () => _handleSuratJalanAction('Print Surat Jalan'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text(
                                    'Print',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSuratJalanAction(String actionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proses $actionName dilakukan untuk Surat Jalan ${_receiverCtrl.text}!'),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
