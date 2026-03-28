import 'package:flutter/material.dart';
import '../../domain/models/inventory_report_item.dart';
import 'package:intl/intl.dart';

class InventoryReportTable extends StatelessWidget {
  final List<InventoryReportItem> items;

  const InventoryReportTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Mã SKU')),
            DataColumn(label: Text('Tên sản phẩm')),
            DataColumn(label: Text('Danh mục')),
            DataColumn(label: Text('Số lượng')),
            DataColumn(label: Text('Giá vốn')),
            DataColumn(label: Text('Tổng giá trị')),
          ],
          rows: items.map((item) {
            return DataRow(cells: [
              DataCell(Text(item.sku)),
              DataCell(Text(item.productName)),
              DataCell(Text(item.categoryName)),
              DataCell(Text(item.quantity.toString())),
              DataCell(Text(currencyFormat.format(item.unitPrice))),
              DataCell(Text(currencyFormat.format(item.totalValue))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
