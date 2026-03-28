import 'package:equatable/equatable.dart';

/// Inventory events
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  
  @override
  List<Object?> get props => [];
}

/// Load products event
class LoadProductsRequested extends InventoryEvent {
  final String? searchQuery;
  
  const LoadProductsRequested({this.searchQuery});
  
  @override
  List<Object?> get props => [searchQuery];
}

/// Create product event
class CreateProductRequested extends InventoryEvent {
  final String sku;
  final String name;
  final double price;
  final String type;
  final List<String> barcodes;
  
  const CreateProductRequested({
    required this.sku,
    required this.name,
    required this.price,
    required this.type,
    required this.barcodes,
  });
  
  @override
  List<Object?> get props => [sku, name, price, type, barcodes];
}

/// Load stock event
class LoadStockRequested extends InventoryEvent {}

/// Create inbound voucher event
class CreateInboundVoucherRequested extends InventoryEvent {
  final List<VoucherItem> items;
  final String note;
  
  const CreateInboundVoucherRequested({
    required this.items,
    required this.note,
  });
  
  @override
  List<Object?> get props => [items, note];
}

/// Create outbound voucher event
class CreateOutboundVoucherRequested extends InventoryEvent {
  final List<VoucherItem> items;
  final String note;
  
  const CreateOutboundVoucherRequested({
    required this.items,
    required this.note,
  });
  
  @override
  List<Object?> get props => [items, note];
}

/// Voucher item model
class VoucherItem {
  final int productId;
  final double quantity;
  final double? unitPrice;
  final String? batchNumber;
  final DateTime? expiryDate;
  
  const VoucherItem({
    required this.productId,
    required this.quantity,
    this.unitPrice,
    this.batchNumber,
    this.expiryDate,
  });
}
