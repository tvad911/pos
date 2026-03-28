import 'package:drift/drift.dart';
import '../../../core/database/database.dart';

class SalesRepository {
  final AppDatabase _database;

  SalesRepository(this._database);
  
  Future<List<Category>> getCategories() async {
    return await _database.select(_database.categories).get();
  }

  Future<List<Product>> getProducts({int? categoryId, String? query}) async {
    var statement = _database.select(_database.products);
    
    if (categoryId != null) {
      statement.where((tbl) => tbl.categoryId.equals(categoryId));
    }

    if (query != null && query.isNotEmpty) {
      statement.where((tbl) => tbl.name.contains(query) | tbl.sku.contains(query));
    }
    
    // Default active only
    statement.where((tbl) => tbl.isActive.equals(true));

    return await statement.get();
  }

  Future<List<Order>> getOrders() async {
    return await (_database.select(_database.orders)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  Future<Order> createOrder({
    required double totalAmount,
    required double discount,
    required double finalAmount,
    required String paymentMethod,
    required List<OrderDetails> items,
    String? customerName,
    String? staffName,
  }) async {
    return await _database.transaction(() async {
      final now = DateTime.now();
      final orderNumber = 'ORD-${now.millisecondsSinceEpoch}';

      // 1. Create Order
      final companion = OrdersCompanion.insert(
        orderNumber: orderNumber,
        totalAmount: totalAmount,
        discount: Value(discount),
        finalAmount: finalAmount,
        paymentMethod: paymentMethod,
        customerName: Value(customerName),
        staffName: Value(staffName),
        createdAt: now,
      );
      
      final orderId = await _database.into(_database.orders).insert(companion);
      final order = await (_database.select(_database.orders)..where((tbl) => tbl.id.equals(orderId))).getSingle();

      // 2. Process Items
      for (var item in items) {
        // Insert order item
        await _database.into(_database.orderItems).insert(
              OrderItemsCompanion.insert(
                orderId: orderId,
                productId: item.productId,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                total: item.total,
              ),
            );

        // Update inventory stock (subtract)
        final stock = await (_database.select(_database.inventoryStock)
              ..where((tbl) => tbl.productId.equals(item.productId)))
            .getSingleOrNull();

        if (stock != null) {
          final newQty = stock.quantityOnHand - item.quantity;
          await (_database.update(_database.inventoryStock)
                ..where((tbl) => tbl.productId.equals(item.productId)))
              .write(InventoryStockCompanion(
            quantityOnHand: Value(newQty),
            updatedAt: Value(now),
          ));

          // Log to stock card
          await _database.into(_database.stockCard).insert(
                StockCardCompanion.insert(
                  productId: item.productId,
                  warehouseId: 1, // Default warehouse
                  transactionType: 'SALE',
                  change: -item.quantity,
                  balanceAfter: newQty,
                  referenceType: 'ORDER',
                  referenceId: orderId,
                  createdAt: now,
                ),
              );
        }
      }
      return order;
    });
  }
}

class OrderDetails {
  final int productId;
  final double quantity;
  final double unitPrice;
  final double total;

  OrderDetails({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}
