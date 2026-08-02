import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/order_status.dart';
import '../profile/order_history_screen.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _categories = [
    {'icon': Icons.thumb_up_alt_outlined, 'label': 'Thông báo\nnổi bật'},
    {'icon': Icons.sell_outlined, 'label': 'Khuyến mãi'},
    {'icon': Icons.account_balance_wallet_outlined, 'label': 'Thông tin\nTài chính'},
    {'icon': Icons.shopping_bag_outlined, 'label': 'Cập nhật\nSpreeMall'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: List.generate(_categories.length, (index) {
              final isSelected = _tabController.index == index;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _tabController.animateTo(index)),
                  child: Column(
                    children: [
                      Icon(
                        _categories[index]['icon'] as IconData,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _categories[index]['label'] as String,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _RealOrderNotifications(),
              _PlaceholderTab(
                icon: Icons.sell_outlined,
                title: 'Chưa có khuyến mãi nào',
                message: 'Voucher và ưu đãi dành riêng cho bạn sẽ hiện ở đây.',
              ),
              _PlaceholderTab(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Chưa có thông tin tài chính',
                message: 'Lịch sử thanh toán, hoàn tiền... sẽ hiện ở đây.',
              ),
              _SpreeMallUpdatesTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _RealOrderNotifications extends StatelessWidget {
  const _RealOrderNotifications();

  String _messageFor(OrderStatus status, String orderShortId) {
    switch (status) {
      case OrderStatus.pending:
        return 'Đơn hàng #$orderShortId của bạn đang chờ được xác nhận.';
      case OrderStatus.confirmed:
        return 'Đơn hàng #$orderShortId đã được xác nhận, đang chuẩn bị hàng.';
      case OrderStatus.shipping:
        return 'Đơn hàng #$orderShortId đang trên đường giao tới bạn.';
      case OrderStatus.delivered:
        return 'Đơn hàng #$orderShortId đã giao thành công. Cảm ơn bạn đã mua sắm!';
      case OrderStatus.cancelled:
        return 'Đơn hàng #$orderShortId đã bị huỷ.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Center(
        child: Text('Vui lòng đăng nhập để xem thông báo.', style: AppTextStyles.bodySecondary),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('orders').where('uid', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = (snapshot.data?.docs ?? []).toList()
          ..sort((a, b) {
            final aTime = a.data()['createdAt'];
            final bTime = b.data()['createdAt'];
            if (aTime is Timestamp && bTime is Timestamp) return bTime.compareTo(aTime);
            return 0;
          });

        if (docs.isEmpty) {
          return const _PlaceholderTab(
            icon: Icons.notifications_none_rounded,
            title: 'Chưa có thông báo nào',
            message: 'Thông báo về đơn hàng của bạn sẽ hiện ở đây.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(15),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final status = orderStatusFromString(data['status'] as String?);
            final shortId = doc.id.substring(0, doc.id.length > 8 ? 8 : doc.id.length);
            final createdAt = data['createdAt'];
            final dateLabel = createdAt is Timestamp
                ? '${createdAt.toDate().day.toString().padLeft(2, '0')}/${createdAt.toDate().month.toString().padLeft(2, '0')}/${createdAt.toDate().year}'
                : 'Vừa xong';

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen(initialTab: 0)),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: status.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(status.icon, color: status.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _messageFor(status, shortId),
                            style: AppTextStyles.bodyRegular.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(dateLabel, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _PlaceholderTab({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.bodyRegular.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(message, style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SpreeMallUpdatesTab extends StatelessWidget {
  const _SpreeMallUpdatesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.shopping_bag, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('SpreeMall v1.0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 2),
                    Text('Phiên bản đầu tiên đã ra mắt!', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text('Có gì mới', style: AppTextStyles.heading3),
        const SizedBox(height: 10),
        ..._updates.map((u) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(u, style: AppTextStyles.bodyRegular)),
                ],
              ),
            )),
      ],
    );
  }

  static const _updates = [
    'Theo dõi đơn hàng theo trạng thái real-time',
    'Đánh giá sản phẩm sau khi nhận hàng',
    'Sổ địa chỉ giao hàng, chọn nhanh lúc thanh toán',
    'Gợi ý sản phẩm dành riêng cho bạn',
  ];
}
