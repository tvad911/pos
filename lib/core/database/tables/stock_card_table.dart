import 'package:drift/drift.dart';
import 'products_table.dart';

/// Stock card table for tracking all inventory transactions
class StockCard extends Table {
  /// Auto-increment primary key
  IntColumn get id => integer().autoIncrement()();
  
  /// Foreign key to Products table
  IntColumn get productId => integer().references(Products, #id)();
  
  /// Warehouse ID
  IntColumn get warehouseId => integer()();
  
  /// Transaction type: SALE, INBOUND, OUTBOUND, TRANSFER, ADJUSTMENT
  TextColumn get transactionType => text()();
  
  /// Quantity change (+/-)
  RealColumn get change => real()();
  
  /// Balance after transaction
  RealColumn get balanceAfter => real()();
  
  /// Reference type: ORDER, VOUCHER
  TextColumn get referenceType => text()();
  
  /// Reference ID (order_id or voucher_id)
  IntColumn get referenceId => integer()();
  
  /// Batch number (nullable)
  TextColumn get batchNumber => text().nullable()();
  
  /// Additional notes
  TextColumn get note => text().nullable()();
  
  /// Transaction timestamp
  DateTimeColumn get createdAt => dateTime()();
}
