import 'package:flutter/material.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/sales_session.dart';

class CartSection extends StatefulWidget {
  final SalesSession session;
  final Function(CartItem, double) onUpdateQuantity;
  final Function(CartItem) onRemove;
  final VoidCallback onClear;
  final VoidCallback onCheckout;
  final Function(String?, String?, String?, double?) onUpdateInfo;

  const CartSection({
    super.key,
    required this.session,
    required this.onUpdateQuantity,
    required this.onRemove,
    required this.onClear,
    required this.onCheckout,
    required this.onUpdateInfo,
  });

  @override
  State<CartSection> createState() => _CartSectionState();
}

class _CartSectionState extends State<CartSection> {
  final _customerController = TextEditingController();
  final _staffController = TextEditingController();
  final _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customerController.text = widget.session.customerName ?? '';
    _staffController.text = widget.session.staffName ?? '';
    _couponController.text = widget.session.couponCode ?? '';
  }

  @override
  void didUpdateWidget(CartSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.id != widget.session.id) {
       _customerController.text = widget.session.customerName ?? '';
       _staffController.text = widget.session.staffName ?? '';
       _couponController.text = widget.session.couponCode ?? '';
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _staffController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header (Info Inputs)
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.blue.shade50,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customerController,
                      decoration: const InputDecoration(
                        labelText: 'Khách hàng',
                        isDense: true,
                        prefixIcon: Icon(Icons.person, size: 20),
                      ),
                      onChanged: (val) => widget.onUpdateInfo(val, null, null, null),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _staffController,
                      decoration: const InputDecoration(
                        labelText: 'Nhân viên',
                        isDense: true,
                        prefixIcon: Icon(Icons.badge, size: 20),
                      ),
                      onChanged: (val) => widget.onUpdateInfo(null, val, null, null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      decoration: const InputDecoration(
                        labelText: 'Mã giảm giá / Coupon',
                        isDense: true,
                        prefixIcon: Icon(Icons.confirmation_num, size: 20),
                      ),
                      onChanged: (val) => widget.onUpdateInfo(null, null, val, null),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClear,
                    icon: const Icon(Icons.delete_sweep, color: Colors.orange),
                    tooltip: 'Xóa đơn',
                  ),
                ],
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: widget.session.cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Đơn hàng trống'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: widget.session.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.session.cartItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(item.product.name),
                        subtitle: Text('${item.price.toStringAsFixed(0)} đ x ${item.quantity.toInt()}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => widget.onUpdateQuantity(item, item.quantity - 1),
                              icon: const Icon(Icons.remove_circle_outline),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => widget.onUpdateQuantity(item, item.quantity + 1),
                              icon: const Icon(Icons.add_circle_outline),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.total.toStringAsFixed(0),
                              style: const TextStyle(fontWeight: FontWeight.bold),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tạm tính:', style: TextStyle(fontSize: 14)),
                  Text('${widget.session.subtotal.toStringAsFixed(0)} đ'),
                ],
              ),
              if (widget.session.discountAmount > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Giảm giá:', style: TextStyle(fontSize: 14, color: Colors.red)),
                    Text('-${widget.session.discountAmount.toStringAsFixed(0)} đ', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TỔNG CỘNG:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    '${widget.session.total.toStringAsFixed(0)} đ',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.session.cartItems.isEmpty ? null : widget.onCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'THANH TOÁN',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
