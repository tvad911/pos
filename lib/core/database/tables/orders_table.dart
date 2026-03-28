import 'package:drift/drift.dart';

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderNumber => text().unique()();
  RealColumn get totalAmount => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get finalAmount => real()();
  TextColumn get paymentMethod => text()(); // CASH, CARD, QR
  TextColumn get status => text().withDefault(const Constant('COMPLETED'))(); // PENDING, COMPLETED, CANCELLED
  TextColumn get customerName => text().nullable()();
  TextColumn get staffName => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
