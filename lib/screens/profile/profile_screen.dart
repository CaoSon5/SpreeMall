import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/role_controller.dart';
import '../../controllers/store_controller.dart';
import '../../models/user_role.dart';
import '../../models/store.dart';
import '../../widgets/recommended_products_section.dart';
import '../admin/admin_dashboard_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ProfileHeader(),
          const SizedBox(height: 12),
          const _OrderStatusSection(),
          const SizedBox(height: 12),
          const _UtilitiesSection(),
          const SizedBox(height: 12),
          const _MenuSection(),
          const SizedBox(height: 20),
          const RecommendedProductsSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: AnimatedBuilder(
                animation: UserProfileController.instance,
                builder: (context, _) {
                  final profile = UserProfileController.instance;

                  final String displayLetter = profile.name.trim().isNotEmpty
                      ? profile.name.trim()[0].toUpperCase()
                      : '?';

                  final String displayName = profile.name.isNotEmpty
                      ? profile.name
                      : 'Người dùng SpreeMall';

                  final String displayEmail = profile.email.isNotEmpty
                      ? profile.email
                      : 'chưa cập nhật email';

                  return Column(
                    children: [
                      Row(
                        children: [

                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            ),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 38,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    displayLetter,
                                    style: AppTextStyles.heading1.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.edit, size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: AppTextStyles.heading1.copyWith(color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayEmail,
                                  style: AppTextStyles.bodyRegular.copyWith(color: Colors.white70),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),

                                StreamBuilder<Store?>(
                                  stream: StoreController.instance.watchMyStore(),
                                  builder: (context, storeSnapshot) {
                                    final myStore = storeSnapshot.data;
                                    final isApprovedSeller = myStore != null && myStore.status == StoreStatus.approved;

                                    return Obx(() {
                                      final role = RoleController.instance.role.value;
                                      final String label;
                                      final IconData icon;

                                      if (role.isAdmin) {
                                        label = 'Quản trị viên';
                                        icon = Icons.admin_panel_settings;
                                      } else if (isApprovedSeller) {
                                        label = 'Người bán';
                                        icon = Icons.storefront;
                                      } else {
                                        label = 'Khách hàng';
                                        icon = Icons.person_outline;
                                      }

                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(icon, size: 14, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(
                                              label,
                                              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                  },
                                ),

                                StreamBuilder<Store?>(
                                  stream: StoreController.instance.watchMyStore(),
                                  builder: (context, snapshot) {
                                    final myStore = snapshot.data;
                                    if (myStore == null || myStore.status != StoreStatus.approved) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (_) => SellerDashboardScreen(store: myStore)),
                                          );
                                        },
                                        icon: const Icon(Icons.storefront, size: 15, color: Colors.white),
                                        label: const Text('Vào kênh người bán', style: TextStyle(fontSize: 12.5)),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(color: Colors.white70),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                Obx(() {
                                  if (!RoleController.instance.role.value.isAdmin) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                                        );
                                      },
                                      icon: const Icon(Icons.admin_panel_settings, size: 15, color: Colors.white),
                                      label: const Text('Vào khu quản trị', style: TextStyle(fontSize: 12.5)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(color: Colors.white70),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [

                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseAuth.instance.currentUser == null
                                  ? null
                                  : FirebaseFirestore.instance
                                      .collection('orders')
                                      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                                      .snapshots(),
                              builder: (context, snapshot) {
                                final count = snapshot.data?.docs.length ?? 0;
                                return _StatItem(label: 'Đơn hàng', value: '$count');
                              },
                            ),
                            const _StatDivider(),
                            const _StatItem(label: 'Voucher', value: '2'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: Colors.white24);
  }
}

class _UtilitiesSection extends StatelessWidget {
  const _UtilitiesSection();

  static const _utilities = [
    {'icon': Icons.account_balance_wallet_outlined, 'label': 'Ví\nSpreeMall', 'color': Color(0xFF2196F3)},
    {'icon': Icons.stars_outlined, 'label': 'SpreeMall\nXu', 'color': Color(0xFFFFA726)},
    {'icon': Icons.confirmation_number_outlined, 'label': 'Kho\nVoucher', 'color': AppColors.primary},
    {'icon': Icons.local_shipping_outlined, 'label': 'Miễn phí\nvận chuyển', 'color': AppColors.success},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('Tiện ích của tôi', style: AppTextStyles.heading3),
          ),
          const SizedBox(height: 12),
          Row(
            children: _utilities.map((u) {
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng đang được phát triển')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (u['color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(u['icon'] as IconData, color: u['color'] as Color, size: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          u['label'] as String,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusSection extends StatelessWidget {
  const _OrderStatusSection();

  static const List<Map<String, dynamic>> _statuses = [
    {'icon': Icons.receipt_long_outlined, 'label': 'Chờ xác nhận', 'tab': 0},
    {'icon': Icons.local_shipping_outlined, 'label': 'Đang giao', 'tab': 1},
    {'icon': Icons.inventory_2_outlined, 'label': 'Hoàn thành', 'tab': 2},
    {'icon': Icons.cancel_outlined, 'label': 'Đã huỷ', 'tab': 3},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Đơn hàng của tôi', style: AppTextStyles.heading3),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const OrderHistoryScreen(initialTab: 0),
                      ),
                    );
                  },
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _statuses.map((status) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderHistoryScreen(initialTab: status['tab'] as int),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    children: [
                      Icon(status['icon'] as IconData, color: AppColors.primary, size: 26),
                      const SizedBox(height: 6),
                      Text(
                        status['label'] as String,
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
