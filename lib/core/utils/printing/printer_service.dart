import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../database/database.dart';

class PrinterService {
  static final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Print an invoice/receipt
  static Future<void> printInvoice({
    required Order order,
    required List<({Product product, OrderItem item})> items,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Thermal printer 80mm
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('POS SYSTEM 2026', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text('ĐC: 123 Đường ABC, Quận XYZ, TP.HCM', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('ĐT: 0123.456.789', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 10),
                    pw.Text('HÓA ĐƠN BÁN HÀNG', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                    pw.Text(order.orderNumber, style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Ngày: ${_dateFormat.format(order.createdAt)}', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Sản phẩm', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                  pw.SizedBox(width: 5),
                  pw.Text('SL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.SizedBox(width: 10),
                  pw.Text('Thành tiền', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ],
              ),
              pw.Divider(),
              ...items.map((e) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(e.product.name, style: const pw.TextStyle(fontSize: 10)),
                              pw.Text(_currencyFormat.format(e.item.unitPrice), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                            ],
                          ),
                        ),
                        pw.Text(e.item.quantity.toString(), style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(width: 10),
                        pw.Container(
                          width: 60,
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(_currencyFormat.format(e.item.total), style: const pw.TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  )),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tổng cộng:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text(_currencyFormat.format(order.totalAmount), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ],
              ),
              if (order.discount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Giảm giá:', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('-${_currencyFormat.format(order.discount)}', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('THANH TOÁN:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(_currencyFormat.format(order.finalAmount), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text('PTTT: ${order.paymentMethod}', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text('Cảm ơn Quý khách. Hẹn gặp lại!', style: const pw.TextStyle(fontSize: 10)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  /// Print an inventory voucher (Inbound/Outbound)
  static Future<void> printInventoryVoucher({
    required InventoryVoucher voucher,
    required List<({Product product, VoucherDetail detail})> items,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final title = voucher.type == 'INBOUND' ? 'PHIẾU NHẬP KHO' : (voucher.type == 'OUTBOUND' ? 'PHIẾU XUẤT KHO' : 'PHIẾU KIỂM KHO');
          
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('POS SYSTEM 2026', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                      pw.Text('Hệ thống quản lý bán hàng chuyên nghiệp', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.blue900)),
                      pw.Text('Số: ${voucher.voucherNumber}', style: const pw.TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Ngày lập: ${_dateFormat.format(voucher.voucherDate)}', style: const pw.TextStyle(fontSize: 11)),
                        pw.Text('Kho: Kho mặc định', style: const pw.TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Trạng thái: ${voucher.status}', style: const pw.TextStyle(fontSize: 11)),
                        if (voucher.note != null) pw.Text('Ghi chú: ${voucher.note}', style: const pw.TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Table
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headers: ['STT', 'Mã SKU', 'Tên sản phẩm', 'ĐVT', 'Số lượng', 'Đơn giá', 'Thành tiền'],
                data: items.asMap().entries.map((entry) {
                  final i = entry.key + 1;
                  final item = entry.value;
                  final unitPrice = item.detail.unitPrice ?? 0.0;
                  final total = unitPrice * item.detail.quantity;
                  
                  return [
                    i.toString(),
                    item.product.sku,
                    item.product.name,
                    'Cái', // Default unit
                    item.detail.quantity.toString(),
                    _currencyFormat.format(unitPrice),
                    _currencyFormat.format(total),
                  ];
                }).toList(),
              ),
              
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Tổng cộng: ${_currencyFormat.format(items.fold(0.0, (sum, e) => sum + (e.detail.unitPrice ?? 0) * e.detail.quantity))}', 
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 40),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Người lập phiếu', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 40),
                      pw.Text('(Ký, họ tên)'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Người nhận hàng', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 40),
                      pw.Text('(Ký, họ tên)'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Thủ kho', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 40),
                      pw.Text('(Ký, họ tên)'),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
