import 'package:drift/drift.dart';
import 'products_table.dart';

/// Inventory stock table for tracking product quantities
class InventoryStock extends Table {
  /// Auto-increment primary key
  IntColumn get id => integer().autoIncrement()();
  
  /// Foreign key to Products table
  IntColumn get productId => integer().references(Products, #id)();
  
  /// Warehouse ID (default: 1 for single warehouse)
  IntColumn get warehouseId => integer().withDefault(const Constant(1))();
  
  /// Quantity on hand
  RealColumn get quantityOnHand => real().withDefault(const Constant(0))();
  
  /// Moving Average Cost (MAC) price
  RealColumn get macPrice => real().withDefault(const Constant(0))();
  
  /// Last update timestamp
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {productId, warehouseId}
  ];
}
