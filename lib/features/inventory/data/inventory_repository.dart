import 'package:drift/drift.dart';
import '../../../core/database/database.dart';
import '../../../core/constants/constants.dart';

/// Inventory repository for product and stock management
class InventoryRepository {
  final AppDatabase _database;
  
  InventoryRepository({required AppDatabase database}) : _database = database;
  
  /// Get all products
  Future<List<Product>> getProducts({String? searchQuery}) async {
    if (searchQuery == null || searchQuery.isEmpty) {
      return await _database.select(_database.products).get();
    }
    
    // Search by name or SKU
    return await (_database.select(_database.products)
          ..where((tbl) => 
              tbl.name.contains(searchQuery) | 
              tbl.sku.contains(searchQuery)))
        .get();
  }
  
  /// Create product
  Future<int> createProduct({
    required String sku,
    required String name,
    required double price,
    required String type,
    List<String>? barcodes,
  }) async {
    return await _database.transaction(() async {
      // Insert product
      final productId = await _database.into(_database.products).insert(
        ProductsCompanion.insert(
          sku: sku,
          name: name,
          price: price,
          type: type,
          taxRate: const Value(0.1),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      // Insert barcodes if provided
      if (barcodes != null && barcodes.isNotEmpty) {
        for (final barcode in barcodes) {
          await _database.into(_database.productBarcodes).insert(
            ProductBarcodesCompanion.insert(
              productId: productId,
              barcode: barcode,
              type: 'PRIMARY',
            ),
          );
        }
      }
      
      // Initialize stock
      await _database.into(_database.inventoryStock).insert(
        InventoryStockCompanion.insert(
          productId: productId,
          updatedAt: DateTime.now(),
        ),
      );
      
      return productId;
    });
  }
  
  /// Get stock items
  Future<List<Map<String, dynamic>>> getStockItems() async {
    final query = _database.select(_database.inventoryStock).join([
      innerJoin(
        _database.products,
        _database.products.id.equalsExp(_database.inventoryStock.productId),
      ),
    ]);
    
    final results = await query.get();
    
    return results.map((row) {
      final stock = row.readTable(_database.inventoryStock);
      final product = row.readTable(_database.products);
      
      return {
        'product': product,
        'quantityOnHand': stock.quantityOnHand,
        'macPrice': stock.macPrice,
      };
    }).toList();
  }
  
  /// Create inbound voucher
  Future<({InventoryVoucher voucher, List<({Product product, VoucherDetail detail})> items})> createInboundVoucher({
    required List<Map<String, dynamic>> items,
    required String note,
  }) async {
    return await _database.transaction(() async {
      // Generate voucher number
      final voucherNumber = 'PN${DateTime.now().millisecondsSinceEpoch}';
      
      // Create voucher
      final voucherId = await _database.into(_database.inventoryVouchers).insert(
        InventoryVouchersCompanion.insert(
          voucherNumber: voucherNumber,
          type: VoucherTypes.inbound,
          warehouseId: 1,
          status: VoucherStatus.confirmed,
          voucherDate: DateTime.now(),
          createdAt: DateTime.now(),
          note: Value(note),
        ),
      );
      
      // Add items and update stock
      for (final item in items) {
        final productId = item['productId'] as int;
        final quantity = item['quantity'] as double;
        final unitPrice = item['unitPrice'] as double;
        
        // Insert voucher detail
        await _database.into(_database.voucherDetails).insert(
          VoucherDetailsCompanion.insert(
            voucherId: voucherId,
            productId: productId,
            quantity: quantity,
            unitPrice: Value(unitPrice),
          ),
        );
        
        // Update stock using DAO
        await _database.inventoryDao.updateStock(
          productId: productId,
          warehouseId: 1,
          change: quantity,
          transactionType: TransactionTypes.inbound,
          referenceType: 'VOUCHER',
          referenceId: voucherId,
          note: 'Nhập kho: $voucherNumber',
        );
        
        // Update MAC
        await _database.inventoryDao.updateMAC(
          productId: productId,
          warehouseId: 1,
          inboundQuantity: quantity,
          inboundPrice: unitPrice,
        );
      }
      
      final voucher = await (_database.select(_database.inventoryVouchers)..where((tbl) => tbl.id.equals(voucherId))).getSingle();
      final detailRows = await (_database.select(_database.voucherDetails)..where((tbl) => tbl.voucherId.equals(voucherId))).get();
      
      final List<({Product product, VoucherDetail detail})> printedItems = [];
      for (var d in detailRows) {
        final p = await (_database.select(_database.products)..where((tbl) => tbl.id.equals(d.productId))).getSingle();
        printedItems.add((product: p, detail: d));
      }

      return (voucher: voucher, items: printedItems);
    });
  }
  
  /// Create outbound voucher
  Future<({InventoryVoucher voucher, List<({Product product, VoucherDetail detail})> items})> createOutboundVoucher({
    required List<Map<String, dynamic>> items,
    required String note,
  }) async {
    return await _database.transaction(() async {
      // Generate voucher number
      final voucherNumber = 'PX${DateTime.now().millisecondsSinceEpoch}';
      
      // Create voucher
      final voucherId = await _database.into(_database.inventoryVouchers).insert(
        InventoryVouchersCompanion.insert(
          voucherNumber: voucherNumber,
          type: VoucherTypes.outbound,
          warehouseId: 1,
          status: VoucherStatus.confirmed,
          voucherDate: DateTime.now(),
          createdAt: DateTime.now(),
          note: Value(note),
        ),
      );
      
      // Add items and update stock
      for (final item in items) {
        final productId = item['productId'] as int;
        final quantity = item['quantity'] as double;
        
        // Insert voucher detail
        await _database.into(_database.voucherDetails).insert(
          VoucherDetailsCompanion.insert(
            voucherId: voucherId,
            productId: productId,
            quantity: quantity,
          ),
        );
        
        // Update stock using DAO
        await _database.inventoryDao.updateStock(
          productId: productId,
          warehouseId: 1,
          change: -quantity,
          transactionType: TransactionTypes.outbound,
          referenceType: 'VOUCHER',
          referenceId: voucherId,
          note: 'Xuất kho: $voucherNumber',
        );
      }
      
      final voucher = await (_database.select(_database.inventoryVouchers)..where((tbl) => tbl.id.equals(voucherId))).getSingle();
      final detailRows = await (_database.select(_database.voucherDetails)..where((tbl) => tbl.voucherId.equals(voucherId))).get();
      
      final List<({Product product, VoucherDetail detail})> printedItems = [];
      for (var d in detailRows) {
        final p = await (_database.select(_database.products)..where((tbl) => tbl.id.equals(d.productId))).getSingle();
        printedItems.add((product: p, detail: d));
      }

      return (voucher: voucher, items: printedItems);
    });
  }
  
  /// Search product by barcode
  Future<Product?> searchByBarcode(String barcode) async {
    final barcodeRecord = await (_database.select(_database.productBarcodes)
          ..where((tbl) => tbl.barcode.equals(barcode)))
        .getSingleOrNull();
    
    if (barcodeRecord == null) return null;
    
    return await (_database.select(_database.products)
          ..where((tbl) => tbl.id.equals(barcodeRecord.productId)))
        .getSingleOrNull();
  }
}
