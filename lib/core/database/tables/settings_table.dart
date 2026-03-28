import 'package:drift/drift.dart';

/// Settings table for storing app configuration and feature flags
class Settings extends Table {
  /// Setting key (primary key)
  TextColumn get key => text()();
  
  /// Setting value (stored as JSON string for complex objects)
  TextColumn get value => text()();
  
  /// Last update timestamp
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {key};
}
