import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/sales_bloc.dart';
import '../domain/sales_event.dart';
import '../domain/sales_state.dart';
import '../data/sales_repository.dart';
import 'widgets/category_list.dart';
import 'widgets/product_grid.dart';
import 'widgets/cart_section.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject SalesBloc
    return BlocProvider(
      create: (context) => SalesBloc(
        SalesRepository(RepositoryProvider.of(context)),
      )..add(const LoadSalesData()),
      child: const SalesScreenContent(),
    );
  }
}

class SalesScreenContent extends StatefulWidget {
  const SalesScreenContent({super.key});

  @override
  State<SalesScreenContent> createState() => _SalesScreenContentState();
}

class _SalesScreenContentState extends State<SalesScreenContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, state) {
        if (state is SalesLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state is SalesLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Hệ thống POS 2026'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'BÁN HÀNG', icon: Icon(Icons.shopping_cart)),
                  Tab(text: 'LỊCH SỬ', icon: Icon(Icons.history)),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildSalesLayout(context, state),
                _buildHistoryLayout(context, state),
              ],
            ),
          );
        }

        if (state is SalesError) {
          return Scaffold(body: Center(child: Text('Lỗi: ${state.message}')));
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildSalesLayout(BuildContext context, SalesLoaded state) {
    return Column(
      children: [
        // Session Tabs
        Container(
          height: 50,
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.sessions.length,
                  itemBuilder: (context, index) {
                    final session = state.sessions[index];
                    final isActive = state.activeSessionIndex == index;
                    return InkWell(
                      onTap: () => context.read<SalesBloc>().add(SwitchSession(index)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: isActive ? Colors.blue : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              session.title,
                              style: TextStyle(
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                color: isActive ? Colors.blue : Colors.black87,
                              ),
                            ),
                            if (state.sessions.length > 1) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () => context.read<SalesBloc>().add(CloseSession(index)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                onPressed: () => context.read<SalesBloc>().add(const AddSession()),
                tooltip: 'Thêm khách hàng mới',
              ),
            ],
          ),
        ),
        
        Expanded(
          child: Row(
            children: [
              // Left: Products
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm SKU, tên hoặc mã vạch...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          context.read<SalesBloc>().add(SearchProducts(value));
                        },
                      ),
                    ),

                    // Categories
                    CategoryList(
                      categories: state.categories,
                      selectedCategoryId: state.selectedCategoryId,
                      onSelect: (id) {
                        context.read<SalesBloc>().add(SelectCategory(id));
                      },
                    ),

                    // Product Grid
                    Expanded(
                      child: ProductGrid(
                        products: state.products,
                        onProductTap: (product) {
                          context.read<SalesBloc>().add(AddToCart(product));
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const VerticalDivider(width: 1),

              // Right: Cart
              Expanded(
                flex: 2,
                child: CartSection(
                  session: state.activeSession,
                  onUpdateQuantity: (item, qty) {
                    context.read<SalesBloc>().add(UpdateCartItemQuantity(item, qty));
                  },
                  onRemove: (item) {
                     context.read<SalesBloc>().add(RemoveFromCart(item));
                  },
                  onClear: () {
                    context.read<SalesBloc>().add(ClearCart());
                  },
                  onUpdateInfo: (customer, staff, coupon, discount) {
                    context.read<SalesBloc>().add(UpdateSessionInfo(
                      customerName: customer,
                      staffName: staff,
                      couponCode: coupon,
                      discountAmount: discount,
                    ));
                  },
                  onCheckout: () {
                    _showCheckoutDialog(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryLayout(BuildContext context, SalesLoaded state) {
    if (state.historyOrders.isEmpty) {
      return const Center(child: Text('Chưa có đơn hàng nào hoàn thành.'));
    }

    return ListView.builder(
      itemCount: state.historyOrders.length,
      itemBuilder: (context, index) {
        final order = state.historyOrders[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
          title: Text('Đơn #${order.id} - ${order.totalAmount.toStringAsFixed(0)} đ'),
          subtitle: Text('Ngày: ${order.createdAt} - KH: ${order.customerName ?? "Khách lẻ"}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Show order details
          },
        );
      },
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thanh toán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Tiền mặt'),
              onTap: () {
                context.read<SalesBloc>().add(const CheckoutRequested('CASH'));
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Chuyển khoản / QR'),
              onTap: () {
                context.read<SalesBloc>().add(const CheckoutRequested('QR'));
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }
}
