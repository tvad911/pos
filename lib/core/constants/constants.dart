/// API endpoints for Botble CMS integration
class ApiEndpoints {
  static const String baseUrl = 'http://localhost:8000'; // TODO: Move to config
  
  // Authentication
  static const String login = '/api/pos/auth/login';
  static const String logout = '/api/pos/auth/logout';
  
  // Initial sync
  static const String init = '/api/pos/init';
  
  // Products
  static const String products = '/api/pos/products';
  static const String productSearch = '/api/pos/products/search';
  
  // Inventory
  static const String inventorySync = '/api/pos/inventory';
  
  // Orders
  static const String ordersSync = '/api/pos/orders';
  
  // Customers
  static const String customerSearch = '/api/pos/customer/search';
}

/// Transaction types
class TransactionTypes {
  static const String sale = 'SALE';
  static const String inbound = 'INBOUND';
  static const String outbound = 'OUTBOUND';
  static const String transfer = 'TRANSFER';
  static const String adjustment = 'ADJUSTMENT';
}

/// Voucher types
class VoucherTypes {
  static const String inbound = 'INBOUND';
  static const String outbound = 'OUTBOUND';
  static const String transfer = 'TRANSFER';
  static const String adjustment = 'ADJUSTMENT';
}

/// Voucher status
class VoucherStatus {
  static const String draft = 'DRAFT';
  static const String confirmed = 'CONFIRMED';
  static const String synced = 'SYNCED';
}

/// Product types
class ProductTypes {
  static const String standard = 'STANDARD';
  static const String service = 'SERVICE';
  static const String composite = 'COMPOSITE';
}

/// Sync queue status
class SyncStatus {
  static const String pending = 'PENDING';
  static const String processing = 'PROCESSING';
  static const String failed = 'FAILED';
  static const String success = 'SUCCESS';
}
