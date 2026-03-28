import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../domain/inventory_bloc.dart';
import '../domain/inventory_event.dart';

import '../data/inventory_repository.dart';

/// Inbound voucher screen for receiving goods
class InboundVoucherScreen extends StatefulWidget {
  const InboundVoucherScreen({super.key});

  @override
  State<InboundVoucherScreen> createState() => _InboundVoucherScreenState();
}

class _InboundVoucherScreenState extends State<InboundVoucherScreen> {
  final _noteController = TextEditingController();
  final List<VoucherLineItem> _items = [];
  bool _showScanner = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleBarcodeDetected(String barcode) async {
    setState(() {
      _showScanner = false;
    });
    
    // Search product by barcode
    final repository = RepositoryProvider.of<InventoryRepository>(context);
    final product = await repository.searchByBarcode(barcode);
    
    if (product != null) {
      _addProduct(product.id, product.name, product.price);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy sản phẩm với mã vạch này'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _addProduct(int productId, String productName, double defaultPrice) {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        productName: productName,
        defaultPrice: defaultPrice,
        onAdd: (quantity, unitPrice) {
          setState(() {
            _items.add(VoucherLineItem(
              productId: productId,
              productName: productName,
              quantity: quantity,
              unitPrice: unitPrice,
            ));
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _handleSubmit() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất 1 sản phẩm'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final voucherItems = _items.map((item) => VoucherItem(
      productId: item.productId,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
    )).toList();
    
    context.read<InventoryBloc>().add(
          CreateInboundVoucherRequested(
            items: voucherItems,
            note: _noteController.text.trim(),
          ),
        );
    
    // Clear form
    setState(() {
      _items.clear();
      _noteController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) {
      return _buildScanner();
    }
    
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Icon(Icons.arrow_downward, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Phiếu nhập kho',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showScanner = true;
                  });
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Quét mã'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Items list
        Expanded(
          child: _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có sản phẩm nào',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Quét mã vạch để thêm sản phẩm',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item.productName),
                        subtitle: Text(
                          'SL: ${item.quantity} | Đơn giá: ${item.unitPrice.toStringAsFixed(0)} đ',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(item.quantity * item.unitPrice).toStringAsFixed(0)} đ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeItem(index),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        
        // Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                  hintText: 'Nhập ghi chú cho phiếu nhập...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng tiền',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${_items.fold<double>(0, (sum, item) => sum + (item.quantity * item.unitPrice)).toStringAsFixed(0)} đ',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Tạo phiếu nhập',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final barcode = barcodes.first.rawValue;
              if (barcode != null) {
                _handleBarcodeDetected(barcode);
              }
            }
          },
        ),
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            onPressed: () {
              setState(() {
                _showScanner = false;
              });
            },
            icon: const Icon(Icons.close, color: Colors.white, size: 32),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
            ),
          ),
        ),
        const Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Đưa mã vạch vào khung hình',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Add item dialog
class _AddItemDialog extends StatefulWidget {
  final String productName;
  final double defaultPrice;
  final Function(double quantity, double unitPrice) onAdd;
  
  const _AddItemDialog({
    required this.productName,
    required this.defaultPrice,
    required this.onAdd,
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _quantityController = TextEditingController(text: '1');
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.defaultPrice.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm sản phẩm'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.productName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'Số lượng',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(
              labelText: 'Đơn giá nhập',
              suffixText: 'đ',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            final quantity = double.tryParse(_quantityController.text) ?? 1;
            final price = double.tryParse(_priceController.text) ?? widget.defaultPrice;
            
            widget.onAdd(quantity, price);
            Navigator.pop(context);
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}

/// Voucher line item model
class VoucherLineItem {
  final int productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  
  const VoucherLineItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });
}
