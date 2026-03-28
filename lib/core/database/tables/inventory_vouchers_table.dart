import 'package:drift/drift.dart';
import 'products_table.dart';

/// Inventory vouchers table for inbound/outbound/transfer operations
class InventoryVouchers extends Table {
  /// Auto-increment primary key
  IntColumn get id => integer().autoIncrement()();
  
  /// Voucher number (unique identifier)
  TextColumn get voucherNumber => text().unique()();
  
  /// Voucher type: INBOUND, OUTBOUND, TRANSFER, ADJUSTMENT
  TextColumn get type => text()();
  
  /// Source warehouse ID
  IntColumn get warehouseId => integer()();
  
  /// Target warehouse ID (for TRANSFER type)
  IntColumn get targetWarehouseId => integer().nullable()();
  
  /// Status: DRAFT, CONFIRMED, SYNCED
  TextColumn get status => text()();
  
  /// Additional notes
  TextColumn get note => text().nullable()();
  
  /// Voucher date
  DateTimeColumn get voucherDate => dateTime()();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();
  
  /// Server ID from Botble (for sync)
  IntColumn get serverId => integer().nullable()();
}

/// Voucher details table (line items)
class VoucherDetails extends Table {
  /// Auto-increment primary key
  IntColumn get id => integer().autoIncrement()();
  
  /// Foreign key to InventoryVouchers table
  IntColumn get voucherId => integer().references(InventoryVouchers, #id, onDelete: KeyAction.cascade)();
  
  /// Foreign key to Products table
  IntColumn get productId => integer().references(Products, #id)();
  
  /// Quantity
  RealColumn get quantity => real()();
  
  /// Unit price (for INBOUND type)
  RealColumn get unitPrice => real().nullable()();
  
  /// Batch number (nullable)
  TextColumn get batchNumber => text().nullable()();
  
  /// Expiry date (nullable)
  DateTimeColumn get expiryDate => dateTime().nullable()();
}
