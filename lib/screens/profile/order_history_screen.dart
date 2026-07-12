import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../utils/formatters.dart';

class _MockOrder {
  final String code;
  final String date;
  final String productSummary;
  final int itemCount;
  final int total;
  final int statusTab; // 0: chờ xác nhận, 1: đang giao, 2: hoàn thành, 3: đã huỷ

  const _MockOrder({
    required this.code,
    required this.date,
    required this.productSummary,
    required this.itemCount,
    required this.total,
    required this.statusTab,
  });
}

const _mockOrders = [
  _MockOrder(
    code: 'DH00123',
    date: '02/07/2026',
    productSummary: 'Điện thoại thông minh X1',
    itemCount: 1,
    total: 4990000,
    statusTab: 0,
  ),
  _MockOrder(
    code: 'DH00119',
    date: '28/06/2026',
    productSummary: 'Bàn phím cơ RGB, Ốp lưng điện thoại',
    itemCount: 2,
    total: 729000,
    statusTab: 1,
  ),
  _MockOrder(
    code: 'DH00108',
    date: '15/06/2026',
    productSummary: 'Giày sneaker năng động',
    itemCount: 1,
    total: 590000,
    statusTab: 2,
  ),
  _MockOrder(
    code: 'DH00099',
    date: '02/06/2026',
    productSummary: 'Nồi chiên không dầu',
    itemCount: 1,
    total: 890000,
    statusTab: 2,
  ),
  _MockOrder(
    code: 'DH00087',
    date: '20/05/2026',
    productSummary: 'Túi xách thời trang',
    itemCount: 1,
    total: 450000,
    statusTab: 3,
  ),
];

class OrderHistoryScreen extends StatefulWidget {
  final int initialTab;

  const OrderHistoryScreen({super.key, this.initialTab = 0});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabLabels = ['Chờ xác nhận', 'Đang giao', 'Hoàn thành', 'Đã huỷ'];
  static const _statusColors = [
    AppColors.warning,
    AppColors.primary,
    AppColors.success,
    AppColors.error,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabLabels.length,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _tabLabels.map((e) => Tab(text: e)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_tabLabels.length, (tabIndex) {
          final orders =
              _mockOrders.where((o) => o.statusTab == tabIndex).toList();

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text(
                    'Không có đơn hàng nào',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(15),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Đơn #${order.code}', style: AppTextStyles.heading3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColors[tabIndex].withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _tabLabels[tabIndex],
                            style: TextStyle(
                              color: _statusColors[tabIndex],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(order.date, style: AppTextStyles.caption),
                    const Divider(height: 20),
                    Text(
                      order.productSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyRegular,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${order.itemCount} sản phẩm',
                          style: AppTextStyles.bodySecondary,
                        ),
                        Text(
                          formatVnd(order.total),
                          style: AppTextStyles.price,
                        ),
                      ],
                    ),
                    if (tabIndex == 2) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã thêm lại sản phẩm vào giỏ hàng')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          child: const Text('Mua lại'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
