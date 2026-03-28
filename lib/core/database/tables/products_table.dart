import 'package:drift/drift.dart';
import 'categories_table.dart';

/// Products table for storing product information
class Products extends Table {
  /// Auto-increment primary key
  IntColumn get id => integer().autoIncrement()();
  
  /// Stock Keeping Unit (unique identifier)
  TextColumn get sku => text().unique()();
  
  /// Product name
  TextColumn get name => text()();
  
  /// Selling price
  RealColumn get price => real()();
  
  /// Tax rate (e.g., 0.1 for 10%)
  RealColumn get taxRate => real().withDefault(const Constant(0.1))();
  
  /// Product type: STANDARD, SERVICE, COMPOSITE
  TextColumn get type => text()();
  
  /// Category ID
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  
  /// Additional attributes stored as JSON (Size, Color, IMEI, etc.)
  TextColumn get attributesJson => text().nullable()();
  
  /// Active status
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  /// Server ID from Botble CMS (for sync)
  IntColumn get serverId => integer().nullable()();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();
  
  /// Last update timestamp
  DateTimeColumn get updatedAt => dateTime()();
}
