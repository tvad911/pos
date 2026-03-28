class InventoryReportItem {
  final int id;
  final String sku;
  final String productName;
  final String categoryName;
  final double quantity;
  final double unitPrice; // Cost price (MAC)
  final double totalValue;

  InventoryReportItem({
    required this.id,
    required this.sku,
    required this.productName,
    required this.categoryName,
    required this.quantity,
    required this.unitPrice,
    required this.totalValue,
  });
}
