import 'package:equatable/equatable.dart';
import '../../../core/database/database.dart';

/// Inventory state
abstract class InventoryState extends Equatable {
  const InventoryState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class InventoryInitial extends InventoryState {}

/// Loading state
class InventoryLoading extends InventoryState {}

/// Products loaded state
class InventoryProductsLoaded extends InventoryState {
  final List<Product> products;
  
  const InventoryProductsLoaded(this.products);
  
  @override
  List<Object?> get props => [products];
}

/// Stock loaded state
class InventoryStockLoaded extends InventoryState {
  final List<StockItem> stockItems;
  
  const InventoryStockLoaded(this.stockItems);
  
  @override
  List<Object?> get props => [stockItems];
}

/// Operation success state
class InventoryOperationSuccess extends InventoryState {
  final String message;
  
  const InventoryOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Error state
class InventoryError extends InventoryState {
  final String message;
  
  const InventoryError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Stock item model for display
class StockItem {
  final Product product;
  final double quantityOnHand;
  final double macPrice;
  
  const StockItem({
    required this.product,
    required this.quantityOnHand,
    required this.macPrice,
  });
}
