import 'package:equatable/equatable.dart';
import '../../../core/database/database.dart';
import 'models/sales_session.dart';

abstract class SalesState extends Equatable {
  const SalesState();
  
  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final List<Category> categories;
  final List<Product> products;
  final List<SalesSession> sessions;
  final int activeSessionIndex;
  final int? selectedCategoryId;
  final String searchQuery;
  final List<Order> historyOrders;

  const SalesLoaded({
    this.categories = const [],
    this.products = const [],
    this.sessions = const [],
    this.activeSessionIndex = 0,
    this.selectedCategoryId,
    this.searchQuery = '',
    this.historyOrders = const [],
  });

  SalesSession get activeSession => sessions[activeSessionIndex];

  SalesLoaded copyWith({
    List<Category>? categories,
    List<Product>? products,
    List<SalesSession>? sessions,
    int? activeSessionIndex,
    int? selectedCategoryId,
    String? searchQuery,
    List<Order>? historyOrders,
  }) {
    return SalesLoaded(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      sessions: sessions ?? this.sessions,
      activeSessionIndex: activeSessionIndex ?? this.activeSessionIndex,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      historyOrders: historyOrders ?? this.historyOrders,
    );
  }

  // Special copyWith for nullable selectedCategoryId
  SalesLoaded copyWithCategory(int? categoryId) {
    return SalesLoaded(
      categories: categories,
      products: products,
      sessions: sessions,
      activeSessionIndex: activeSessionIndex,
      selectedCategoryId: categoryId,
      searchQuery: searchQuery,
      historyOrders: historyOrders,
    );
  }

  @override
  List<Object?> get props => [
    categories, 
    products, 
    sessions, 
    activeSessionIndex, 
    selectedCategoryId, 
    searchQuery, 
    historyOrders
  ];
}

class SalesError extends SalesState {
  final String message;
  const SalesError(this.message);

  @override
  List<Object?> get props => [message];
}
