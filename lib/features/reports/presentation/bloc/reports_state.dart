import '../../domain/models/inventory_report_item.dart';
import '../../domain/models/revenue_report_item.dart';

enum ReportsStatus { initial, loading, success, failure }

class ReportsState {
  final ReportsStatus status;
  final List<InventoryReportItem> inventoryItems;
  final List<RevenueReportItem> revenueItems;
  final double totalInventoryValue;
  final double totalRevenue;
  final String? errorMessage;
  final DateTime? revenueStartDate;
  final DateTime? revenueEndDate;

  const ReportsState({
    this.status = ReportsStatus.initial,
    this.inventoryItems = const [],
    this.revenueItems = const [],
    this.totalInventoryValue = 0.0,
    this.totalRevenue = 0.0,
    this.errorMessage,
    this.revenueStartDate,
    this.revenueEndDate,
  });

  ReportsState copyWith({
    ReportsStatus? status,
    List<InventoryReportItem>? inventoryItems,
    List<RevenueReportItem>? revenueItems,
    double? totalInventoryValue,
    double? totalRevenue,
    String? errorMessage,
    DateTime? revenueStartDate,
    DateTime? revenueEndDate,
  }) {
    return ReportsState(
      status: status ?? this.status,
      inventoryItems: inventoryItems ?? this.inventoryItems,
      revenueItems: revenueItems ?? this.revenueItems,
      totalInventoryValue: totalInventoryValue ?? this.totalInventoryValue,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      errorMessage: errorMessage,
      revenueStartDate: revenueStartDate ?? this.revenueStartDate,
      revenueEndDate: revenueEndDate ?? this.revenueEndDate,
    );
  }
}
