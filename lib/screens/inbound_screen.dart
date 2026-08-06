import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wms_model.dart';
import '../providers/wms_provider.dart';
import '../widgets/barcode_painter.dart';
import 'scanner_screen.dart'; // Add this import

class InboundScreen extends StatefulWidget {
  const InboundScreen({super.key});

  @override
  State<InboundScreen> createState() => _InboundScreenState();
}

class _InboundScreenState extends State<InboundScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scanAnimationController;

  // Form Controllers
  final _skuController = TextEditingController(text: 'BRG-00128');
  final _nameController = TextEditingController(text: 'Wireless Scanner Zebra');
  final _brandController = TextEditingController(text: 'Zebra');
  final _categoryController = TextEditingController(text: 'Elektronik');
  final _qtyController = TextEditingController(text: '25');
  final _supplierController = TextEditingController(text: 'PT Logistik Utama');
  final _dateController = TextEditingController(text: '2024-10-28');
  final _locationController = TextEditingController(text: 'Rack A-03');
  final _originController = TextEditingController(text: 'Indonesia');

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _skuController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _qtyController.dispose();
    _supplierController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _originController.dispose();
    super.dispose();
  }

  Future<void> _openRealScanner() async {
    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );

    if (scannedCode != null) {
      setState(() {
        _skuController.text = scannedCode;
        _nameController.text = 'Scanned Product';
        _brandController.text = 'Unknown Brand';
        _categoryController.text = 'General';
        _locationController.text = 'Unassigned';
        _originController.text = 'Unknown';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Barcode Terdeteksi: $scannedCode'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Penerimaan Barang',
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
              // Scanner Camera Viewfinder Section
              GestureDetector(
                onTap: _openRealScanner,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Simulated Camera Viewfinder Background Image/Graphic
                      Opacity(
                        opacity: 0.25,
                        child: Icon(Icons.photo_camera_outlined, size: 100, color: Colors.white.withValues(alpha: 0.5)),
                      ),

                      // Scanning Frame Corners
                      Container(
                        width: 220,
                        height: 110,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            // Animated Laser Line
                            AnimatedBuilder(
                              animation: _scanAnimationController,
                              builder: (context, child) {
                                return Positioned(
                                  top: _scanAnimationController.value * 90 + 5,
                                  left: 10,
                                  right: 10,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B00),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF6B00).withValues(alpha: 0.8),
                                          blurRadius: 6,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Center Target Icon Button
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B00),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 26),
                      ),

                      // Overlay Instruction Text
                      Positioned(
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Tap kamera untuk simulasi Scan Barcode',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Form Add Product Container
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
                      'Add Product',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // SKU Field
                    _buildFormField(
                      label: 'SKU',
                      controller: _skuController,
                      onChanged: (val) => setState(() {}),
                    ),
                    const SizedBox(height: 10),

                    // Row 1: Product Name & Brand
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            label: 'Product Name',
                            controller: _nameController,
                            onChanged: (val) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFormField(
                            label: 'Brand',
                            controller: _brandController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Row 2: Category & Quantity Received
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            label: 'Category',
                            controller: _categoryController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFormField(
                            label: 'Quantity Received',
                            controller: _qtyController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Row 3: Supplier & Receive Date
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            label: 'Supplier',
                            controller: _supplierController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFormField(
                            label: 'Receive Date',
                            controller: _dateController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Row 4: Storage Location & Country of Origin
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            label: 'Storage Location',
                            controller: _locationController,
                            onChanged: (val) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFormField(
                            label: 'Country of Origin',
                            controller: _originController,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Barcode Label Preview Card (As in Mockup 3)
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
                  children: [
                    const Text(
                      'Barcode Label Preview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Barcode Render Box
                    BarcodeWidget(
                      code: _skuController.text.isNotEmpty ? _skuController.text : 'BRG-00000',
                      width: 250,
                      height: 70,
                    ),
                    const SizedBox(height: 12),

                    // Details Summary Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SKU: ${_skuController.text}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          'Product: ${_nameController.text}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rack: ${_locationController.text}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFFF6B00)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Button: Save & Print Barcode
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: _saveAndPrintBarcode,
                        icon: const Icon(Icons.print_outlined, color: Colors.white),
                        label: const Text(
                          'Print Barcode',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
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
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
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

  void _saveAndPrintBarcode() {
    final provider = Provider.of<WmsProvider>(context, listen: false);
    final qty = int.tryParse(_qtyController.text) ?? 1;

    final record = InboundRecord(
      id: 'IN-${DateTime.now().millisecondsSinceEpoch}',
      sku: _skuController.text,
      name: _nameController.text,
      brand: _brandController.text,
      category: _categoryController.text,
      quantityReceived: qty,
      supplier: _supplierController.text,
      receiveDate: _dateController.text,
      storageLocation: _locationController.text,
      countryOfOrigin: _originController.text,
    );

    provider.addProductInbound(record);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Penerimaan ${_nameController.text} ($qty unit) berhasil disimpan & mencetak label barcode!'),
        backgroundColor: const Color(0xFFFF6B00),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
