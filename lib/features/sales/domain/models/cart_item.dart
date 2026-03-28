import 'package:equatable/equatable.dart';
import '../../../../core/database/database.dart';

class CartItem extends Equatable {
  final Product product;
  final double quantity;
  final double price; // Store price at time of add (in case price changes or override)
  final String? note;

  const CartItem({
    required this.product,
    this.quantity = 1,
    required this.price,
    this.note,
  });

  CartItem copyWith({
    Product? product,
    double? quantity,
    double? price,
    String? note,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      note: note ?? this.note,
    );
  }

  double get total => quantity * price;

  @override
  List<Object?> get props => [product, quantity, price, note];
}
