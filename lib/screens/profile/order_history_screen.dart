import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/order_status.dart';
import '../../utils/formatters.dart';
import '../../widgets/recommended_products_section.dart';

class OrderHistoryScreen extends StatefulWidget {
  final int initialTab;

  const OrderHistoryScreen({super.key, this.initialTab = 0});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    null,
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.shipping,
    OrderStatus.delivered,
    OrderStatus.cancelled,
  ];

  static const _tabLabels = ['Tất cả', 'Chờ xác nhận', 'Đã xác nhận', 'Đang giao', 'Đã giao', 'Đã huỷ'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabLabels.length,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, _tabLabels.length - 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Huỷ đơn hàng'),
        content: const Text('Bạn có chắc chắn muốn huỷ đơn hàng này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Không')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Huỷ đơn', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final orderRef = FirebaseFirestore.instance.collection('orders').doc(orderId);
      final orderSnap = await orderRef.get();
      final items = (orderSnap.data()?['items'] as List<dynamic>? ?? []);

      final productsRef = FirebaseFirestore.instance.collection('products');
      final batch = FirebaseFirestore.instance.batch();
      for (final raw in items) {
        final item = raw as Map<String, dynamic>;
        final productId = item['productId'] as String?;
        final quantity = (item['quantity'] ?? 0) as int;
        if (productId == null || quantity <= 0) continue;
        batch.update(productsRef.doc(productId), {
          'stock': FieldValue.increment(quantity),
          'soldCount': FieldValue.increment(-quantity),
        });
      }

      batch.update(orderRef, {'status': OrderStatus.cancelled.value});
      await batch.commit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

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
      body: uid == null
          ? const Center(child: Text('Vui lòng đăng nhập để xem đơn hàng.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(

              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('uid', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi tải đơn hàng: ${snapshot.error}'));
                }

                final allDocs = (snapshot.data?.docs ?? []).toList()
                  ..sort((a, b) {
                    final aTime = a.data()['createdAt'];
                    final bTime = b.data()['createdAt'];
                    if (aTime is Timestamp && bTime is Timestamp) {
                      return bTime.compareTo(aTime);
                    }
                    return 0;
                  });

                return TabBarView(
                  controller: _tabController,
                  children: List.generate(_tabs.length, (tabIndex) {
                    final filterStatus = _tabs[tabIndex];
                    final docs = filterStatus == null
                        ? allDocs

                        : allDocs.where((d) => orderStatusFromString(d.data()['status'] as String?) == filterStatus).toList();

                    if (docs.isEmpty) {

                      return ListView(
                        padding: const EdgeInsets.all(15),
                        children: [
                          const SizedBox(height: 24),
                          const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          Center(child: Text('Không có đơn hàng nào', style: AppTextStyles.bodySecondary)),
                          const SizedBox(height: 28),
                          const RecommendedProductsSection(padding: EdgeInsets.zero),
                        ],
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(15),
                      itemCount: docs.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {

                        if (index == docs.length) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: RecommendedProductsSection(padding: EdgeInsets.zero),
                          );
                        }

                        final doc = docs[index];
                        final data = doc.data();
                        final status = orderStatusFromString(data['status'] as String?);
                        final items = (data['items'] as List<dynamic>? ?? []);
                        final totalAmount = (data['totalAmount'] ?? 0) as num;
                        final createdAt = data['createdAt'];
                        final dateLabel = createdAt is Timestamp
                            ? '${createdAt.toDate().day.toString().padLeft(2, '0')}/${createdAt.toDate().month.toString().padLeft(2, '0')}/${createdAt.toDate().year}'
                            : 'Vừa đặt';

                        final productSummary = items
                            .map((raw) => (raw as Map<String, dynamic>)['productName'] ?? '')
                            .where((s) => (s as String).isNotEmpty)
                            .join(', ');
                        final itemCount = items.fold<int>(0, (sum, raw) => sum + ((raw as Map<String, dynamic>)['quantity'] as int? ?? 1));

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
                                  Text(
                                    'Đơn #${doc.id.substring(0, doc.id.length > 8 ? 8 : doc.id.length)}',
                                    style: AppTextStyles.heading3,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: status.color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(status.icon, size: 13, color: status.color),
                                        const SizedBox(width: 4),
                                        Text(
                                          status.label,
                                          style: TextStyle(color: status.color, fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(dateLabel, style: AppTextStyles.caption),
                              const Divider(height: 20),
                              Text(
                                productSummary.isEmpty ? 'Đơn hàng' : productSummary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyRegular,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$itemCount sản phẩm', style: AppTextStyles.bodySecondary),
                                  Text(formatVnd(totalAmount), style: AppTextStyles.price),
                                ],
                              ),
                              if (status.canBeCancelledByCustomer) ...[
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton(
                                    onPressed: () => _cancelOrder(context, doc.id),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(color: AppColors.error),
                                    ),
                                    child: const Text('Huỷ đơn'),
                                  ),
                                ),
                              ],
                              if (status == OrderStatus.delivered) ...[
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
                );
              },
            ),
    );
  }
}
