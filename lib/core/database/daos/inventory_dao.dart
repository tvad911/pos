import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/products_table.dart';
import '../tables/inventory_stock_table.dart';
import '../tables/inventory_batches_table.dart';
import '../tables/stock_card_table.dart';

part 'inventory_dao.g.dart';

/// Data Access Object for inventory operations
@DriftAccessor(tables: [
  Products,
  InventoryStock,
  InventoryBatches,
  StockCard,
])
class InventoryDao extends DatabaseAccessor<AppDatabase> with _$InventoryDaoMixin {
  InventoryDao(super.db);

  /// Get product stock for a specific warehouse
  Future<InventoryStockData?> getProductStock(int productId, int warehouseId) {
    return (select(inventoryStock)
          ..where((tbl) => 
              tbl.productId.equals(productId) & 
              tbl.warehouseId.equals(warehouseId)))
        .getSingleOrNull();
  }

  /// Get all batches for a product, ordered by FEFO (First Expiry, First Out)
  Future<List<InventoryBatche>> getBatchesByProduct(
    int productId,
    int warehouseId,
  ) {
    return (select(inventoryBatches)
          ..where((tbl) => 
              tbl.productId.equals(productId) & 
              tbl.warehouseId.equals(warehouseId) &
              tbl.quantity.isBiggerThanValue(0))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.expiryDate, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Update stock and create stock card entry
  Future<void> updateStock({
    required int productId,
    required int warehouseId,
    required double change,
    required String transactionType,
    required String referenceType,
    required int referenceId,
    String? batchNumber,
    String? note,
  }) async {
    await transaction(() async {
      // Get current stock
      final currentStock = await getProductStock(productId, warehouseId);
      final currentQty = currentStock?.quantityOnHand ?? 0;
      final newQty = currentQty + change;

      if (currentStock == null) {
        // Create new stock record
        await into(inventoryStock).insert(
          InventoryStockCompanion.insert(
            productId: productId,
            updatedAt: DateTime.now(),
            warehouseId: Value(warehouseId),
            quantityOnHand: Value(newQty),
          ),
        );
      } else {
        // Update existing stock
        await (update(inventoryStock)
              ..where((tbl) => tbl.id.equals(currentStock.id)))
            .write(
          InventoryStockCompanion(
            quantityOnHand: Value(newQty),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      // Create stock card entry
      await into(stockCard).insert(
        StockCardCompanion.insert(
          productId: productId,
          warehouseId: warehouseId,
          transactionType: transactionType,
          change: change,
          balanceAfter: newQty,
          referenceType: referenceType,
          referenceId: referenceId,
          createdAt: DateTime.now(),
          batchNumber: Value(batchNumber),
          note: Value(note),
        ),
      );
    });
  }

  /// Deduct stock using FEFO algorithm (for batch tracking)
  Future<void> deductStockFEFO({
    required int productId,
    required int warehouseId,
    required double quantityNeeded,
    required String referenceType,
    required int referenceId,
  }) async {
    await transaction(() async {
      // Get batches ordered by expiry date
      final batches = await getBatchesByProduct(productId, warehouseId);
      
      double remainingQty = quantityNeeded;
      
      for (final batch in batches) {
        if (remainingQty <= 0) break;
        
        final deductQty = remainingQty > batch.quantity ? batch.quantity : remainingQty;
        
        // Update batch quantity
        await (update(inventoryBatches)
              ..where((tbl) => tbl.id.equals(batch.id)))
            .write(
          InventoryBatchesCompanion(
            quantity: Value(batch.quantity - deductQty),
          ),
        );
        
        // Update stock and create stock card
        await updateStock(
          productId: productId,
          warehouseId: warehouseId,
          change: -deductQty,
          transactionType: 'OUTBOUND',
          referenceType: referenceType,
          referenceId: referenceId,
          batchNumber: batch.batchNumber,
        );
        
        remainingQty -= deductQty;
      }
      
      if (remainingQty > 0) {
        throw Exception('Insufficient stock. Missing: $remainingQty');
      }
    });
  }

  /// Calculate and update Moving Average Cost (MAC)
  Future<void> updateMAC({
    required int productId,
    required int warehouseId,
    required double inboundQuantity,
    required double inboundPrice,
  }) async {
    final currentStock = await getProductStock(productId, warehouseId);
    
    if (currentStock == null) return;
    
    final currentQty = currentStock.quantityOnHand;
    final currentMAC = currentStock.macPrice;
    
    // MAC = (currentStock * currentMAC + inboundQuantity * inboundPrice) / (currentStock + inboundQuantity)
    final newMAC = currentQty > 0
        ? ((currentQty * currentMAC) + (inboundQuantity * inboundPrice)) / (currentQty + inboundQuantity)
        : inboundPrice;
    
    await (update(inventoryStock)
          ..where((tbl) => tbl.id.equals(currentStock.id)))
        .write(
      InventoryStockCompanion(
        macPrice: Value(newMAC),
      ),
    );
  }

  /// Get stock card history for a product
  Stream<List<StockCardData>> watchStockCard(int productId, int warehouseId) {
    return (select(stockCard)
          ..where((tbl) => 
              tbl.productId.equals(productId) & 
              tbl.warehouseId.equals(warehouseId))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }
}
