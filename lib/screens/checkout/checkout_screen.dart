import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/address_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/checkout_controller.dart';
import '../../models/address.dart';
import '../../models/payment_method.dart';
import '../../routes/app_routes.dart';
import '../../utils/formatters.dart';
import '../profile/address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartController cartController = Get.find<CartController>();
  final CheckoutController checkoutController = Get.find<CheckoutController>();

  @override
  void initState() {
    super.initState();
    checkoutController.resetPaymentMethod();
    _loadDefaultAddress();
  }

  @override
  void dispose() {

    checkoutController.clearQuickBuy();
    super.dispose();
  }

  Future<void> _loadDefaultAddress() async {
    final address = await AddressController.instance.fetchDefaultAddress();
    if (mounted && address != null) {
      checkoutController.selectAddress(address);
    }
  }

  Future<void> _pickAddress() async {
    final addresses = await AddressController.instance.watchAddresses().first;

    if (addresses.isEmpty) {

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddressScreen()),
      );
      await _loadDefaultAddress();
      return;
    }

    if (!mounted) return;

    final chosen = await showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chọn địa chỉ giao hàng', style: AppTextStyles.heading2),
                const SizedBox(height: 12),
                ...addresses.map(
                  (a) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      a.isDefault ? Icons.location_on : Icons.location_on_outlined,
                      color: a.isDefault ? AppColors.primary : AppColors.textSecondary,
                    ),
                    title: Text(a.name, style: AppTextStyles.heading3),
                    subtitle: Text('${a.phone}\n${a.detail}'),
                    isThreeLine: true,
                    onTap: () => Navigator.pop(context, a),
                  ),
                ),
                const Divider(),
                TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddressScreen()),
                    );
                    await _loadDefaultAddress();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm địa chỉ mới'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (chosen != null) {
      checkoutController.selectAddress(chosen);
    }
  }

  Future<void> _submit() async {
    final totalAmount = checkoutController.checkoutTotal;
    final success = await checkoutController.processOrder();

    if (!mounted || !success) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đặt hàng thành công!'),
        content: Text('Cảm ơn bạn đã mua hàng. Tổng tiền: ${formatVnd(totalAmount)}'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Quay lại trang chủ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (mounted) Get.offAllNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Thanh toán')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text('Địa chỉ giao hàng', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Obx(() {
              final address = checkoutController.selectedAddress.value;
              return InkWell(
                onTap: _pickAddress,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: address == null
                            ? Text('Chọn địa chỉ giao hàng', style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textSecondary))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${address.name}  |  ${address.phone}', style: AppTextStyles.heading3),
                                  const SizedBox(height: 2),
                                  Text(address.detail, style: AppTextStyles.bodyRegular),
                                ],
                              ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            Text('Phương thức thanh toán', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Obx(() {
              final selected = checkoutController.selectedPaymentMethod.value;
              return Column(
                children: PaymentMethod.values.map((method) {
                  final isSelected = method == selected;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => checkoutController.changePaymentMethod(method),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: method.color.withOpacity(0.12),
                              child: Icon(method.icon, color: method.color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(method.label, style: AppTextStyles.heading3.copyWith(fontSize: 14)),
                                  Text(method.subtitle, style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            Radio<PaymentMethod>(
                              value: method,
                              groupValue: selected,
                              activeColor: AppColors.primary,
                              onChanged: (value) => checkoutController.changePaymentMethod(value!),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: 24),

            Text('Tóm tắt đơn hàng', style: AppTextStyles.heading3),
            const Divider(),
            Obx(() {

              final quick = checkoutController.quickBuyItem.value;

              Widget buildList(List<CartItem> selectedItems) {
                if (selectedItems.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Không có sản phẩm nào được chọn để thanh toán.'),
                  );
                }

                final total = selectedItems.fold<int>(0, (sum, i) => sum + i.totalPrice);

                return Column(
                  children: [
                    ...selectedItems.map((item) {
                      final product = item.product;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name, style: AppTextStyles.bodyRegular),
                                  if (item.size != null)
                                    Text('Size: ${item.size}', style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            Text(formatVnd(product.price), style: AppTextStyles.bodySecondary),
                            const SizedBox(width: 8),
                            Text('x${item.quantity}', style: AppTextStyles.bodySecondary),
                          ],
                        ),
                      );
                    }),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng cộng:', style: AppTextStyles.heading3),
                        Text(formatVnd(total), style: AppTextStyles.price.copyWith(fontSize: 18)),
                      ],
                    ),
                  ],
                );
              }

              if (quick != null) {
                return buildList([quick]);
              }

              return GetBuilder<CartController>(
                builder: (controller) => buildList(controller.items.where((i) => i.selected).toList()),
              );
            }),
            const SizedBox(height: 32),

            Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: checkoutController.isPlacingOrder.value ? null : _submit,
                  child: checkoutController.isPlacingOrder.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('XÁC NHẬN ĐẶT HÀNG', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
