import 'package:flutter_bloc/flutter_bloc.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';
import '../data/inventory_repository.dart';
import '../../../core/utils/printing/printer_service.dart';

/// Inventory BLoC
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _inventoryRepository;
  
  InventoryBloc({required InventoryRepository inventoryRepository})
      : _inventoryRepository = inventoryRepository,
        super(InventoryInitial()) {
    on<LoadProductsRequested>(_onLoadProducts);
    on<CreateProductRequested>(_onCreateProduct);
    on<LoadStockRequested>(_onLoadStock);
    on<CreateInboundVoucherRequested>(_onCreateInboundVoucher);
    on<CreateOutboundVoucherRequested>(_onCreateOutboundVoucher);
  }
  
  /// Load products
  Future<void> _onLoadProducts(
    LoadProductsRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    
    try {
      final products = await _inventoryRepository.getProducts(
        searchQuery: event.searchQuery,
      );
      
      emit(InventoryProductsLoaded(products));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Create product
  Future<void> _onCreateProduct(
    CreateProductRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    
    try {
      await _inventoryRepository.createProduct(
        sku: event.sku,
        name: event.name,
        price: event.price,
        type: event.type,
        barcodes: event.barcodes,
      );
      
      emit(const InventoryOperationSuccess('Tạo sản phẩm thành công'));
      
      // Reload products
      final products = await _inventoryRepository.getProducts();
      emit(InventoryProductsLoaded(products));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Load stock
  Future<void> _onLoadStock(
    LoadStockRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    
    try {
      final stockData = await _inventoryRepository.getStockItems();
      
      final stockItems = stockData.map((item) => StockItem(
        product: item['product'],
        quantityOnHand: item['quantityOnHand'],
        macPrice: item['macPrice'],
      )).toList();
      
      emit(InventoryStockLoaded(stockItems));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Create inbound voucher
  Future<void> _onCreateInboundVoucher(
    CreateInboundVoucherRequested event,
    Emitter<InventoryState> emit,
  ) async {
    final currentState = state;
    emit(InventoryLoading());
    
    try {
      final items = event.items.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice ?? 0.0,
      }).toList();
      
      final result = await _inventoryRepository.createInboundVoucher(
        items: items,
        note: event.note,
      );
      
      // Print Voucher
      try {
        await PrinterService.printInventoryVoucher(
          voucher: result.voucher,
          items: result.items,
        );
      } catch (e) {
        // Ignore printer error for now to not block success flow
        // In the future, we can add a warning message to the state
        // ignore: avoid_print
        print('Printer error: $e');
      }
      
      emit(const InventoryOperationSuccess('Tạo phiếu nhập kho thành công'));
      
      // Return to previous state or reload
      if (currentState is InventoryStockLoaded) {
        add(LoadStockRequested());
      }
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
  
  /// Create outbound voucher
  Future<void> _onCreateOutboundVoucher(
    CreateOutboundVoucherRequested event,
    Emitter<InventoryState> emit,
  ) async {
    final currentState = state;
    emit(InventoryLoading());
    
    try {
      final items = event.items.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
      }).toList();
      
      final result = await _inventoryRepository.createOutboundVoucher(
        items: items,
        note: event.note,
      );
      
      // Print Voucher
      try {
        await PrinterService.printInventoryVoucher(
          voucher: result.voucher,
          items: result.items,
        );
      } catch (e) {
        // Ignore printer error
        // ignore: avoid_print
        print('Printer error: $e');
      }
      
      emit(const InventoryOperationSuccess('Tạo phiếu xuất kho thành công'));
      
      // Return to previous state or reload
      if (currentState is InventoryStockLoaded) {
        add(LoadStockRequested());
      }
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
}
