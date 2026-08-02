import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/order_status.dart';
import '../../models/store.dart';
import '../../utils/formatters.dart';

class SellerOrderManagementScreen extends StatelessWidget {
  final Store store;
  const SellerOrderManagementScreen({super.key, required this.store});

  bool _orderContainsMyProducts(Map<String, dynamic> orderData) {
    final items = (orderData['items'] as List<dynamic>? ?? []);
    return items.any((raw) => (raw as Map<String, dynamic>)['storeId'] == store.id);
  }

  Future<void> _updateStatus(String docId, OrderStatus newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(docId).update({'status': newStatus.value});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Đơn hàng của ${store.name}')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }

          final docs = (snapshot.data?.docs ?? []).where((d) => _orderContainsMyProducts(d.data())).toList();

          if (docs.isEmpty) {
            return Center(
              child: Text('Chưa có đơn hàng nào chứa sản phẩm của cửa hàng bạn.', style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
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
              final allItems = (data['items'] as List<dynamic>? ?? []);

              final myItems = allItems.where((raw) => (raw as Map<String, dynamic>)['storeId'] == store.id).toList();
              final myItemsTotal = myItems.fold<int>(0, (sum, raw) {
                final item = raw as Map<String, dynamic>;
                return sum + ((item['price'] ?? 0) as int) * ((item['quantity'] ?? 1) as int);
              });

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('Mã đơn: ${doc.id.substring(0, doc.id.length > 8 ? 8 : doc.id.length)}', style: AppTextStyles.heading3)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: status.color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                            child: Text(status.label, style: TextStyle(color: status.color, fontWeight: FontWeight.w600, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Khách hàng: ${data['customerName'] ?? '—'}', style: AppTextStyles.bodyRegular),
                      Text('Địa chỉ: ${data['customerAddress'] ?? '—'}', style: AppTextStyles.bodyRegular),
                      const SizedBox(height: 6),
                      Text('Sản phẩm của bạn trong đơn này:', style: AppTextStyles.caption),
                      ...myItems.map((raw) {
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
                          Text('Phần của bạn: ${formatVnd(myItemsTotal)}', style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
                          DropdownButton<OrderStatus>(
                            value: status,
                            underline: const SizedBox(),
                            items: OrderStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
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
        },
      ),
    );
  }
}
