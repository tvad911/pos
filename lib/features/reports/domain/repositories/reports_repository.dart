import '../models/inventory_report_item.dart';
import '../models/revenue_report_item.dart';

abstract class ReportsRepository {
  Future<List<InventoryReportItem>> getInventoryReport();
  Future<List<RevenueReportItem>> getRevenueReport({required DateTime startDate, required DateTime endDate});
  Future<double> getTotalInventoryValue();
  Future<double> getTotalRevenue({required DateTime startDate, required DateTime endDate});
}
