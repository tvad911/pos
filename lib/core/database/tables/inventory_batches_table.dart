import 'package:drift/drift.dart';
import 'products_table.dart';

/// Inventory batches table for batch/lot tracking
class InventoryBatches extends Table {
  /// Auto-increment primary key
  IntColumn get id => integer().autoIncrement()();
  
  /// Foreign key to Products table
  IntColumn get productId => integer().references(Products, #id)();
  
  /// Warehouse ID
  IntColumn get warehouseId => integer()();
  
  /// Batch/Lot number
  TextColumn get batchNumber => text()();
  
  /// Expiry date (nullable for non-perishable items)
  DateTimeColumn get expiryDate => dateTime().nullable()();
  
  /// Quantity in this batch
  RealColumn get quantity => real()();
  
  /// Cost price for this batch
  RealColumn get costPrice => real()();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {productId, warehouseId, batchNumber}
  ];
}
