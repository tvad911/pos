import 'package:flutter_bloc/flutter_bloc.dart';
import 'sales_event.dart';
import 'sales_state.dart';
import '../data/sales_repository.dart';
import 'models/cart_item.dart';
import 'models/sales_session.dart';
import '../../../core/utils/printing/printer_service.dart';
import '../../../core/database/database.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SalesRepository _repository;

  SalesBloc(this._repository) : super(SalesInitial()) {
    on<LoadSalesData>(_onLoadSalesData);
    on<SelectCategory>(_onSelectCategory);
    on<SearchProducts>(_onSearchProducts);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    on<AddSession>(_onAddSession);
    on<SwitchSession>(_onSwitchSession);
    on<CloseSession>(_onCloseSession);
    on<UpdateSessionInfo>(_onUpdateSessionInfo);
    on<CheckoutRequested>(_onCheckoutRequested);
  }

  Future<void> _onLoadSalesData(LoadSalesData event, Emitter<SalesState> emit) async {
    emit(SalesLoading());
    try {
      final categories = await _repository.getCategories();
      final products = await _repository.getProducts();
      final historyOrders = await _repository.getOrders();
      
      final initialSession = SalesSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Đơn 1',
        createdAt: DateTime.now(),
      );

      emit(SalesLoaded(
        categories: categories,
        products: products,
        sessions: [initialSession],
        activeSessionIndex: 0,
        historyOrders: historyOrders,
      ));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  Future<void> _onSelectCategory(SelectCategory event, Emitter<SalesState> emit) async {
    if (state is SalesLoaded) {
      final currentState = state as SalesLoaded;
      try {
        final products = await _repository.getProducts(
          categoryId: event.categoryId,
          query: currentState.searchQuery,
        );
        emit(currentState.copyWithCategory(event.categoryId).copyWith(products: products));
      } catch (e) {
        emit(SalesError(e.toString()));
      }
    }
  }

  Future<void> _onSearchProducts(SearchProducts event, Emitter<SalesState> emit) async {
    if (state is SalesLoaded) {
      final currentState = state as SalesLoaded;
      try {
        final products = await _repository.getProducts(
          categoryId: currentState.selectedCategoryId,
          query: event.query,
        );
        emit(currentState.copyWith(searchQuery: event.query, products: products));
      } catch (e) {
        emit(SalesError(e.toString()));
      }
    }
  }

  void _onAddToCart(AddToCart event, Emitter<SalesState> emit) {
    if (state is SalesLoaded) {
      final currentState = state as SalesLoaded;
      final activeSession = currentState.activeSession;
      final List<CartItem> currentCart = List.from(activeSession.cartItems);
      
      final index = currentCart.indexWhere((item) => item.product.id == event.product.id);
      
      if (index >= 0) {
        currentCart[index] = currentCart[index].copyWith(quantity: currentCart[index].quantity + 1);
      } else {
        currentCart.add(CartItem(product: event.product, price: event.product.price));
      }
      
      final updatedSession = activeSession.copyWith(cartItems: currentCart);
      final updatedSessions = List<SalesSession>.from(currentState.sessions);
      updatedSessions[currentState.activeSessionIndex] = updatedSession;

      emit(currentState.copyWith(sessions: updatedSessions));
    }
  }

  void _onUpdateCartItemQuantity(UpdateCartItemQuantity event, Emitter<SalesState> emit) {
    if (state is SalesLoaded) {
      final currentState = state as SalesLoaded;
      final activeSession = currentState.activeSession;
      final List<CartItem> currentCart = List.from(activeSession.cartItems);
      
      final index = currentCart.indexWhere((item) => item.product.id == event.item.product.id);
      if (index >= 0) {
        if (event.quantity <= 0) {
          currentCart.removeAt(index);
        } else {
          currentCart[index] = event.item.copyWith(quantity: event.quantity);
        }
        
        final updatedSession = activeSession.copyWith(cartItems: currentCart);
        final updatedSessions = List<SalesSession>.from(currentState.sessions);
        updatedSessions[currentState.activeSessionIndex] = updatedSession;

        emit(currentState.copyWith(sessions: updatedSessions));
      }
    }
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<SalesState> emit) {
    if (state is SalesLoaded) {
      final currentState = state as SalesLoaded;
      final activeSession = currentState.activeSession;
      final List<CartItem> currentCart = List.from(activeSession.cartItems);
      
      currentCart.removeWhere((item) => item.product.id == event.item.product.id);
      
      final updatedSession = activeSession.copyWith(cartItems: currentCart);
      final updatedSessions = List<SalesSession>.from(currentState.sessions);
      updatedSessions[currentState.activeSessionIndex] = updatedSession;

      emit(currentState.copyWith(sessions: updatedSessions));
    }
  }
  
  void _onClearCart(ClearCart event, Emitter<SalesState> emit) {
    if (state is SalesLoaded) {
      final currentState = state as SalesLoaded;
      final updatedSession = currentState.activeSession.copyWith(cartItems: []);
      final updatedSessions = List<SalesSession>.from(currentState.sessions);
      updatedSessions[currentState.activeSessionIndex] = updatedSession;

      emit(currentState.copyWith(sessions: updatedSessions));
    }
  }

  void _onAddSession(AddSession event, Emitter<SalesState> emit) {
    if (state is SalesLoaded) {
      final currentState = state as SalesLoaded;
      final newIndex = currentState.sessions.length + 1;
      final newSession = SalesSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Đơn $newIndex',
        createdAt: DateTime.now(),
      );
      
      emit(currentState.copyWith(
        sessions: [...currentState.sessions, newSession],
        activeSessionIndex: currentState.sessions.length,
      ));
    }
  }

  void _onSwitchSession(SwitchSession event, Emitter<SalesState> emit) {
    if (state is SalesLoaded) {
      final currentState = state as SalesLoaded;
      if (event.index >= 0 && event.index < currentState.sessions.length) {
        emit(currentState.copyWith(activeSessionIndex: event.index));
      }
    }
  }

  void _onCloseSession(CloseSession event, Emitter<SalesState> emit) {
    if (state is SalesLoaded) {
      final currentState = state as SalesLoaded;
      if (currentState.sessions.length <= 1) return; // Keep at least one

      final updatedSessions = List<SalesSession>.from(currentState.sessions);
      updatedSessions.removeAt(event.index);
      
      int nextIndex = currentState.activeSessionIndex;
      if (nextIndex >= updatedSessions.length) {
        nextIndex = updatedSessions.length - 1;
      }

      emit(currentState.copyWith(
        sessions: updatedSessions,
        activeSessionIndex: nextIndex,
      ));
    }
  }

  void _onUpdateSessionInfo(UpdateSessionInfo event, Emitter<SalesState> emit) {
    if (state is SalesLoaded) {
      final currentState = state as SalesLoaded;
      final updatedSession = currentState.activeSession.copyWith(
        customerName: event.customerName ?? currentState.activeSession.customerName,
        staffName: event.staffName ?? currentState.activeSession.staffName,
        couponCode: event.couponCode ?? currentState.activeSession.couponCode,
        discountAmount: event.discountAmount ?? currentState.activeSession.discountAmount,
      );
      
      final updatedSessions = List<SalesSession>.from(currentState.sessions);
      updatedSessions[currentState.activeSessionIndex] = updatedSession;

      emit(currentState.copyWith(sessions: updatedSessions));
    }
  }

  Future<void> _onCheckoutRequested(CheckoutRequested event, Emitter<SalesState> emit) async {
    if (state is SalesLoaded) {
      final currentState = state as SalesLoaded;
      final activeSession = currentState.activeSession;
      if (activeSession.cartItems.isEmpty) return;

      try {
        final orderItems = activeSession.cartItems.map((item) => OrderDetails(
          productId: item.product.id,
          quantity: item.quantity,
          unitPrice: item.price,
          total: item.total,
        )).toList();

        final order = await _repository.createOrder(
          totalAmount: activeSession.subtotal,
          discount: activeSession.discountAmount,
          finalAmount: activeSession.total,
          paymentMethod: event.paymentMethod,
          items: orderItems,
          customerName: activeSession.customerName, // Use what we have
          staffName: activeSession.staffName,
        );

        // Print Invoice
        final printItems = activeSession.cartItems.map((cartItem) {
          return (
            product: cartItem.product,
            item: OrderItem(
              id: 0, 
              orderId: order.id,
              productId: cartItem.product.id,
              quantity: cartItem.quantity,
              unitPrice: cartItem.price,
              discount: 0,
              total: cartItem.total,
            ),
          );
        }).toList();

        try {
          await PrinterService.printInvoice(
            order: order,
            items: printItems,
          );
        } catch (e) {
          // Printer error is ignored for now to not block the flow
          // In a real app we might want to show a non-blocking notification
        }

        // Add to history and clear current session
        final updatedSession = activeSession.copyWith(
          cartItems: [],
          customerName: null,
          staffName: null,
          couponCode: null,
          discountAmount: 0,
        );
        
        final updatedSessions = List<SalesSession>.from(currentState.sessions);
        updatedSessions[currentState.activeSessionIndex] = updatedSession;
        
        final updatedHistory = [order, ...currentState.historyOrders];

        emit(currentState.copyWith(
          sessions: updatedSessions,
          historyOrders: updatedHistory,
        ));
      } catch (e) {
        emit(SalesError(e.toString()));
      }
    }
  }
}
