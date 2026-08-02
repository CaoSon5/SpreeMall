import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/order_status.dart';
import '../../utils/formatters.dart';

class AdminOrderManagementScreen extends StatefulWidget {
  const AdminOrderManagementScreen({super.key});

  @override
  State<AdminOrderManagementScreen> createState() => _AdminOrderManagementScreenState();
}

class _AdminOrderManagementScreenState extends State<AdminOrderManagementScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [null, OrderStatus.pending, OrderStatus.confirmed, OrderStatus.shipping, OrderStatus.delivered, OrderStatus.cancelled];
  static const _tabLabels = ['Tất cả', 'Chờ xác nhận', 'Đã xác nhận', 'Đang giao', 'Đã giao', 'Đã huỷ'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String docId, OrderStatus newStatus) async {
    final orderRef = FirebaseFirestore.instance.collection('orders').doc(docId);

    if (newStatus == OrderStatus.cancelled) {
      final orderSnap = await orderRef.get();
      final currentStatus = orderStatusFromString(orderSnap.data()?['status'] as String?);

      if (currentStatus != OrderStatus.cancelled) {
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
        batch.update(orderRef, {'status': newStatus.value});
        await batch.commit();
        return;
      }
    }

    await orderRef.update({'status': newStatus.value});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Quản lý đơn hàng', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _tabLabels.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }

          final allDocs = snapshot.data?.docs ?? [];

          return TabBarView(
            controller: _tabController,
            children: List.generate(_tabs.length, (tabIndex) {
              final filterStatus = _tabs[tabIndex];
              final docs = filterStatus == null
                  ? allDocs
                  : allDocs.where((d) => orderStatusFromString(d.data()['status'] as String?) == filterStatus).toList();

              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    'Không có đơn hàng nào ở mục này.',
                    style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textSecondary),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();

                  final status = orderStatusFromString(data['status'] as String?);
                  final items = (data['items'] as List<dynamic>? ?? []);
                  final totalAmount = (data['totalAmount'] ?? 0) as num;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Mã đơn: ${doc.id.substring(0, doc.id.length > 8 ? 8 : doc.id.length)}',
                                  style: AppTextStyles.heading3,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: status.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status.label,
                                  style: TextStyle(
                                    color: status.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Khách hàng: ${data['customerName'] ?? '—'}', style: AppTextStyles.bodyRegular),
                          Text('SĐT: ${data['customerPhone'] ?? '—'}', style: AppTextStyles.bodyRegular),
                          Text('Địa chỉ: ${data['customerAddress'] ?? '—'}', style: AppTextStyles.bodyRegular),
                          const SizedBox(height: 6),
                          ...items.map((raw) {
                            final item = raw as Map<String, dynamic>;
                            final size = item['size'];
                            return Text(
                              '• ${item['productName'] ?? ''} x${item['quantity'] ?? 1}${size != null ? ' (Size: $size)' : ''}',
                              style: AppTextStyles.bodyRegular.copyWith(fontSize: 12, color: AppColors.textSecondary),
                            );
                          }),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tổng: ${formatVnd(totalAmount)}',
                                style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                              ),
                              DropdownButton<OrderStatus>(
                                value: status,
                                underline: const SizedBox(),
                                items: OrderStatus.values
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                                    .toList(),
                                onChanged: (newStatus) {
                                  if (newStatus != null) _updateStatus(doc.id, newStatus);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
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
