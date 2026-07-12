import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotification = true;
  bool _promoNotification = true;
  bool _orderNotification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Cài đặt & hỗ trợ')),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _SectionCard(
            title: 'Thông báo',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text('Thông báo đẩy'),
                subtitle: const Text('Nhận thông báo chung từ ứng dụng'),
                value: _pushNotification,
                onChanged: (value) => setState(() => _pushNotification = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text('Khuyến mãi & ưu đãi'),
                subtitle: const Text('Nhận tin về voucher, flash sale'),
                value: _promoNotification,
                onChanged: (value) => setState(() => _promoNotification = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text('Cập nhật đơn hàng'),
                subtitle: const Text('Trạng thái vận chuyển, giao hàng'),
                value: _orderNotification,
                onChanged: (value) => setState(() => _orderNotification = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Chung',
            children: [
              _SimpleTile(
                icon: Icons.language_outlined,
                title: 'Ngôn ngữ',
                trailingText: 'Tiếng Việt',
                onTap: () {},
              ),
              _SimpleTile(
                icon: Icons.dark_mode_outlined,
                title: 'Giao diện tối',
                trailingText: 'Sắp ra mắt',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tính năng đang được phát triển')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Hỗ trợ',
            children: [
              _SimpleTile(
                icon: Icons.help_outline,
                title: 'Trung tâm hỗ trợ',
                onTap: () {},
              ),
              _SimpleTile(
                icon: Icons.description_outlined,
                title: 'Điều khoản sử dụng',
                onTap: () {},
              ),
              _SimpleTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Chính sách bảo mật',
                onTap: () {},
              ),
              _SimpleTile(
                icon: Icons.info_outline,
                title: 'Về SpereeMall',
                trailingText: 'v1.0.0',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Khác',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
                title: const Text('Xoá tài khoản', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Xoá tài khoản'),
                      content: const Text(
                        'Hành động này sẽ xoá vĩnh viễn tài khoản của bạn. '
                        'Đây là màn hình mô phỏng nên thao tác này sẽ không xoá gì cả.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Huỷ'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Xoá', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}

class _SimpleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  const _SimpleTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyRegular),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText!, style: AppTextStyles.bodySecondary),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.textHint),
        ],
      ),
      onTap: onTap,
    );
  }
}
