import 'package:drift/drift.dart';

/// Sync queue table for offline data synchronization
class SyncQueue extends Table {
  /// Auto-increment primary key
  IntColumn get id => integer().autoIncrement()();
  
  /// API endpoint to call
  TextColumn get apiEndpoint => text()();
  
  /// Request payload as JSON string
  TextColumn get payloadJson => text()();
  
  /// Status: PENDING, PROCESSING, FAILED, SUCCESS
  TextColumn get status => text()();
  
  /// Retry count
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  
  /// Error message (nullable)
  TextColumn get errorMessage => text().nullable()();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();
  
  /// Last attempt timestamp
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
}
