import 'package:drift/drift.dart';
import 'products_table.dart';

/// Product barcodes table (1-to-many relationship with Products)
class ProductBarcodes extends Table {
  /// Auto-increment primary key
  IntColumn get id => integer().autoIncrement()();
  
  /// Foreign key to Products table
  IntColumn get productId => integer().references(Products, #id, onDelete: KeyAction.cascade)();
  
  /// Barcode value (unique)
  TextColumn get barcode => text().unique()();
  
  /// Barcode type: PRIMARY, CASE, UNIT
  TextColumn get type => text()();
}
