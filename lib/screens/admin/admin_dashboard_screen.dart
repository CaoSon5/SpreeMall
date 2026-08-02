import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/role_controller.dart';
import '../../routes/app_routes.dart';
import 'admin_order_management_screen.dart';
import 'admin_product_management_screen.dart';
import 'admin_user_management_screen.dart';
import 'admin_store_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    RoleController.instance.reset();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Khu vực Quản trị', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Xem giao diện Khách hàng',
            icon: const Icon(Icons.storefront_outlined, color: Colors.white),
            onPressed: () {

              Get.toNamed(AppRoutes.home);
            },
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tổng quan hệ thống', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _CountCard(collection: 'products', label: 'Sản phẩm', icon: Icons.inventory_2_outlined, color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _CountCard(collection: 'orders', label: 'Đơn hàng', icon: Icons.receipt_long_outlined, color: AppColors.accent)),
                const SizedBox(width: 12),
                Expanded(child: _CountCard(collection: 'users', label: 'Người dùng', icon: Icons.people_outline, color: AppColors.success)),
              ],
            ),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('stores').where('status', isEqualTo: 'pending').snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                if (count == 0) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_outlined, color: AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Có $count yêu cầu mở cửa hàng đang chờ duyệt', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600))),
                      TextButton(
                        onPressed: () => Get.to(() => const AdminStoreManagementScreen()),
                        child: const Text('Xem ngay'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text('Quản lý', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            _AdminMenuTile(
              icon: Icons.inventory_2_outlined,
              title: 'Quản lý sản phẩm',
              subtitle: 'Thêm, sửa, xoá sản phẩm đang bán',
              onTap: () => Get.to(() => const AdminProductManagementScreen()),
            ),
            _AdminMenuTile(
              icon: Icons.storefront_outlined,
              title: 'Quản lý cửa hàng',
              subtitle: 'Duyệt/từ chối yêu cầu mở cửa hàng của người bán',
              onTap: () => Get.to(() => const AdminStoreManagementScreen()),
            ),
            _AdminMenuTile(
              icon: Icons.receipt_long_outlined,
              title: 'Quản lý đơn hàng',
              subtitle: 'Theo dõi và cập nhật trạng thái đơn hàng',
              onTap: () => Get.to(() => const AdminOrderManagementScreen()),
            ),
            _AdminMenuTile(
              icon: Icons.people_outline,
              title: 'Quản lý người dùng',
              subtitle: 'Xem danh sách, cấp/thu hồi quyền admin',
              onTap: () => Get.to(() => const AdminUserManagementScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final String collection;
  final String label;
  final IconData icon;
  final Color color;

  const _CountCard({
    required this.collection,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection(collection).snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return Text(
                snapshot.hasData ? '$count' : '—',
                style: AppTextStyles.heading1.copyWith(fontSize: 22),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTextStyles.heading3),
        subtitle: Text(subtitle, style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
