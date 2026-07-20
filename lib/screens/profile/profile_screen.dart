import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../routes/app_routes.dart';
import 'address_screen.dart';
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
          const _MenuSection(),
          const SizedBox(height: 12),
          const _LogoutButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Header gradient với avatar, tên, email và nút chỉnh sửa hồ sơ.
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: AnimatedBuilder(
            animation: UserProfileController.instance,
            builder: (context, _) {
              final profile = UserProfileController.instance;
              
              // Xử lý hiển thị chữ cái đầu của tên (Nếu rỗng thì hiển thị kí tự mặc định)
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
                      Stack(
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
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfileScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white70),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('Chỉnh sửa hồ sơ', style: TextStyle(fontSize: 12.5)),
                            ),
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
                        const _StatItem(label: 'Đơn hàng', value: '4'),
                        const _StatDivider(),
                        AnimatedBuilder(
                          animation: FavoritesController.instance,
                          builder: (context, _) => _StatItem(
                            label: 'Yêu thích',
                            value: '${FavoritesController.instance.count}',
                          ),
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

/// Hàng biểu tượng trạng thái đơn hàng (chờ xác nhận, đang giao, ...)
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

/// Danh sách menu chức năng (thông tin cá nhân, địa chỉ, cài đặt...)
class _MenuSection extends StatelessWidget {
  const _MenuSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.person_outline,
            label: 'Thông tin cá nhân',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          const _MenuDivider(),
          _MenuTile(
            icon: Icons.location_on_outlined,
            label: 'Địa chỉ giao hàng',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddressScreen()),
            ),
          ),
          const _MenuDivider(),
          _MenuTile(
            icon: Icons.credit_card_outlined,
            label: 'Phương thức thanh toán',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang được phát triển')),
            ),
          ),
          const _MenuDivider(),
          _MenuTile(
            icon: Icons.settings_outlined,
            label: 'Cài đặt & hỗ trợ',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(label, style: AppTextStyles.bodyRegular),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}

/// Nút đăng xuất đã xử lý dọn dẹp data cũ tránh lưu bộ nhớ đệm
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Đăng xuất'),
              content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Huỷ'),
                ),
                TextButton(
                  onPressed: () async {
                    // 1. Giải phóng tài khoản trên Firebase Auth (nếu dùng)
                    // await FirebaseAuth.instance.signOut();
                    
                    // 2. Clear sạch dữ liệu trên giao diện thông qua controller
                    UserProfileController.instance.clearProfile();

                    // 3. Điều hướng về màn Login và xoá toàn bộ stack màn hình cũ
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.login,
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Đăng xuất', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: const Text('Đăng xuất', style: TextStyle(color: AppColors.error)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}