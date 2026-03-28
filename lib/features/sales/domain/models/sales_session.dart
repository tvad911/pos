import 'package:equatable/equatable.dart';
import 'cart_item.dart';

class SalesSession extends Equatable {
  final String id;
  final String title;
  final List<CartItem> cartItems;
  final String? customerName;
  final String? staffName;
  final String? couponCode;
  final double discountAmount;
  final DateTime createdAt;

  const SalesSession({
    required this.id,
    required this.title,
    this.cartItems = const [],
    this.customerName,
    this.staffName,
    this.couponCode,
    this.discountAmount = 0,
    required this.createdAt,
  });

  double get subtotal => cartItems.fold(0, (sum, item) => sum + item.total);
  double get total => subtotal - discountAmount;

  SalesSession copyWith({
    String? id,
    String? title,
    List<CartItem>? cartItems,
    String? customerName,
    String? staffName,
    String? couponCode,
    double? discountAmount,
  }) {
    return SalesSession(
      id: id ?? this.id,
      title: title ?? this.title,
      cartItems: cartItems ?? this.cartItems,
      customerName: customerName ?? this.customerName,
      staffName: staffName ?? this.staffName,
      couponCode: couponCode ?? this.couponCode,
      discountAmount: discountAmount ?? this.discountAmount,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, cartItems, customerName, staffName, couponCode, discountAmount, createdAt];
}
