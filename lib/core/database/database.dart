import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// Import all table definitions
import 'tables/settings_table.dart';
import 'tables/products_table.dart';
import 'tables/categories_table.dart';
import 'tables/product_barcodes_table.dart';
import 'tables/inventory_stock_table.dart';
import 'tables/inventory_batches_table.dart';
import 'tables/stock_card_table.dart';
import 'tables/inventory_vouchers_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/orders_table.dart';
import 'tables/order_items_table.dart';

// Import DAOs
import 'daos/inventory_dao.dart';

part 'database.g.dart';

/// Main database class for POS application
@DriftDatabase(
  tables: [
    Settings,
    Categories,
    Products,
    ProductBarcodes,
    InventoryStock,
    InventoryBatches,
    StockCard,
    InventoryVouchers,
    VoucherDetails,
    SyncQueue,
    Orders,
    OrderItems,
  ],
  daos: [
    InventoryDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        // Insert default settings
        await into(settings).insert(
          SettingsCompanion.insert(
            key: 'feature_flags',
            value: '{"is_fnb_enabled": false, "is_batch_tracking_enabled": false, "is_multi_warehouse": false}',
            updatedAt: DateTime.now(),
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migration from v1 to v2: Add Categories table and categoryId to Products
          await m.createTable(categories);
          await m.addColumn(products, products.categoryId);
          
          await into(categories).insert(CategoriesCompanion.insert(name: 'Đồ uống', createdAt: DateTime.now(), updatedAt: DateTime.now()));
          await into(categories).insert(CategoriesCompanion.insert(name: 'Đồ ăn', createdAt: DateTime.now(), updatedAt: DateTime.now()));
          await into(categories).insert(CategoriesCompanion.insert(name: 'Khác', createdAt: DateTime.now(), updatedAt: DateTime.now()));
        }
        
        if (from < 3) {
          await m.createTable(orders);
          await m.createTable(orderItems);
        }

        if (from < 4) {
          await m.addColumn(orders, orders.customerName);
          await m.addColumn(orders, orders.staffName);
        }
      },
    );
  }
}

/// Open database connection
QueryExecutor _openConnection() {
  return driftDatabase(name: 'pos_database');
}
