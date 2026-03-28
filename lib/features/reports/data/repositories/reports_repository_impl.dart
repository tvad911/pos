import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../domain/models/inventory_report_item.dart';
import '../../domain/models/revenue_report_item.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final AppDatabase _database;

  ReportsRepositoryImpl(this._database);

  @override
  Future<List<InventoryReportItem>> getInventoryReport() async {
    final query = _database.select(_database.products).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.id.equalsExp(_database.products.categoryId),
      ),
      leftOuterJoin(
        _database.inventoryStock,
        _database.inventoryStock.productId.equalsExp(_database.products.id),
      ),
    ]);

    final result = await query.get();

    return result.map((row) {
      final product = row.readTable(_database.products);
      final category = row.readTableOrNull(_database.categories);
      final stock = row.readTableOrNull(_database.inventoryStock);

      final quantity = stock?.quantityOnHand ?? 0.0;
      final macPrice = stock?.macPrice ?? 0.0; 

      return InventoryReportItem(
        id: product.id,
        sku: product.sku,
        productName: product.name,
        categoryName: category?.name ?? 'Uncategorized',
        quantity: quantity,
        unitPrice: macPrice,
        totalValue: quantity * macPrice,
      );
    }).toList();
  }

  @override
  Future<List<RevenueReportItem>> getRevenueReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final query = _database.select(_database.orders)
      ..where((tbl) => tbl.createdAt.isBetweenValues(startDate, endDate))
      ..where((tbl) => tbl.status.equals('COMPLETED'))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt)]);

    final orders = await query.get();

    // Group by date (day)
    final Map<DateTime, List<Order>> grouped = {};
    for (var order in orders) {
      final date = DateTime(order.createdAt.year, order.createdAt.month, order.createdAt.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(order);
    }

    return grouped.entries.map((entry) {
      final date = entry.key;
      final dailyOrders = entry.value;
      final dailyRevenue = dailyOrders.fold<double>(0.0, (sum, order) => sum + order.finalAmount);
      
      return RevenueReportItem(
        date: date,
        revenue: dailyRevenue,
        orderCount: dailyOrders.length,
      );
    }).toList();
  }

  @override
  Future<double> getTotalInventoryValue() async {
    final report = await getInventoryReport();
    return report.fold<double>(0.0, (sum, item) => sum + item.totalValue);
  }

  @override
  Future<double> getTotalRevenue({required DateTime startDate, required DateTime endDate}) async {
    final report = await getRevenueReport(startDate: startDate, endDate: endDate);
    return report.fold<double>(0.0, (acc, item) => acc + item.revenue);
  }
}
