import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/store.dart';
import 'seller_product_management_screen.dart';
import 'seller_order_management_screen.dart';
import 'edit_store_screen.dart';

class SellerDashboardScreen extends StatelessWidget {
  final Store store;
  const SellerDashboardScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kênh người bán'),
        actions: [

          IconButton(
            tooltip: 'Sửa thông tin cửa hàng',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EditStoreScreen(store: store)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [

                  ClipOval(
                    child: Container(
                      width: 56,
                      height: 56,
                      color: Colors.white,
                      child: store.logoUrl.isNotEmpty
                          ? Image.network(
                              store.logoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _AvatarFallback(name: store.name),
                            )
                          : _AvatarFallback(name: store.name),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Text('✓ Đã duyệt', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Tổng quan', style: AppTextStyles.heading3),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('products').where('storeId', isEqualTo: store.id).snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                final totalStock = docs.fold<int>(0, (sum, d) => sum + ((d.data()['stock'] ?? 0) as int));
                final totalSold = docs.fold<int>(0, (sum, d) => sum + ((d.data()['soldCount'] ?? 0) as int));

                return Row(
                  children: [
                    Expanded(child: _StatCard(icon: Icons.inventory_2_outlined, label: 'Sản phẩm', value: '${docs.length}', color: AppColors.primary)),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(icon: Icons.local_shipping_outlined, label: 'Đã bán', value: '$totalSold', color: AppColors.success)),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(icon: Icons.warehouse_outlined, label: 'Tồn kho', value: '$totalStock', color: const Color(0xFF7B61FF))),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary)),
                title: const Text('Quản lý sản phẩm'),
                subtitle: const Text('Thêm, sửa, xoá sản phẩm của cửa hàng bạn'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SellerProductManagementScreen(store: store)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.accent.withOpacity(0.15), child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF8A6D00))),
                title: const Text('Quản lý đơn hàng'),
                subtitle: const Text('Xem và cập nhật trạng thái đơn hàng chứa sản phẩm của bạn'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SellerOrderManagementScreen(store: store)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}
