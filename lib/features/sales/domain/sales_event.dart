import 'package:equatable/equatable.dart';
import '../../../core/database/database.dart';
import 'models/cart_item.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesData extends SalesEvent {
  const LoadSalesData();
}

class SelectCategory extends SalesEvent {
  final int? categoryId; // null = All
  const SelectCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchProducts extends SalesEvent {
  final String query;
  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class AddToCart extends SalesEvent {
  final Product product;
  const AddToCart(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateCartItemQuantity extends SalesEvent {
  final CartItem item;
  final double quantity;
  const UpdateCartItemQuantity(this.item, this.quantity);

  @override
  List<Object?> get props => [item, quantity];
}

class RemoveFromCart extends SalesEvent {
  final CartItem item;
  const RemoveFromCart(this.item);

  @override
  List<Object?> get props => [item];
}

class ClearCart extends SalesEvent {}

class AddSession extends SalesEvent {
  const AddSession();
}

class CloseSession extends SalesEvent {
  final int index;
  const CloseSession(this.index);

  @override
  List<Object?> get props => [index];
}

class SwitchSession extends SalesEvent {
  final int index;
  const SwitchSession(this.index);

  @override
  List<Object?> get props => [index];
}

class UpdateSessionInfo extends SalesEvent {
  final String? customerName;
  final String? staffName;
  final String? couponCode;
  final double? discountAmount;

  const UpdateSessionInfo({
    this.customerName,
    this.staffName,
    this.couponCode,
    this.discountAmount,
  });

  @override
  List<Object?> get props => [customerName, staffName, couponCode, discountAmount];
}

class CheckoutRequested extends SalesEvent {
  final String paymentMethod;
  const CheckoutRequested(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}
