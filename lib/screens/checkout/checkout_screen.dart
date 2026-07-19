import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/checkout_controller.dart';
import '../../routes/app_routes.dart'; // 🆕 Thêm import app_routes để chuyển trang

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tìm hoặc khởi tạo các Controller cần thiết bằng GetX
    final CartController cartController = Get.find<CartController>();
    final CheckoutController checkoutController = Get.put(CheckoutController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin nhận hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => checkoutController.nameController.value = v,
              decoration: const InputDecoration(labelText: 'Tên người nhận', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => checkoutController.phoneController.value = v,
              decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => checkoutController.addressController.value = v,
              decoration: const InputDecoration(labelText: 'Địa chỉ giao hàng', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),

            const Text('Hình thức thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Obx(() => RadioListTile<String>(
                  title: const Text('Thanh toán khi nhận hàng (COD)'),
                  value: 'COD',
                  groupValue: checkoutController.selectedPaymentMethod.value,
                  onChanged: (value) => checkoutController.changePaymentMethod(value!),
                )),
            Obx(() => RadioListTile<String>(
                  title: const Text('Thẻ tín dụng / Ghi nợ'),
                  value: 'CARD',
                  groupValue: checkoutController.selectedPaymentMethod.value,
                  onChanged: (value) => checkoutController.changePaymentMethod(value!),
                )),
            const SizedBox(height: 24),

            const Text('Tóm tắt đơn hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            
            // 🆕 Thay thế AnimatedBuilder bằng GetBuilder chuẩn GetX
            GetBuilder<CartController>(
              builder: (controller) {
                // Lọc danh sách sản phẩm được chọn để thanh toán
                final selectedItems = controller.items.where((item) => item.selected).toList();

                if (selectedItems.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Không có sản phẩm nào được chọn để thanh toán.'),
                  );
                }

                return Column(
                  children: [
                    ...selectedItems.map((item) {
                      final product = item.product;
                      final quantity = item.quantity;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(product.name), 
                        trailing: Text('x$quantity'),
                      );
                    }),
                    
                    const Divider(),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng cộng:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '\$${controller.selectedTotalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Nút xác nhận đặt hàng
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                onPressed: () {
                  // 1. Thực hiện logic đặt hàng/thanh toán của hệ thống
                  checkoutController.processOrder(
                    totalAmount: cartController.selectedTotalPrice.toDouble(),
                  );

                  // 2. 🆕 Xóa các sản phẩm đã chọn thanh toán (giữ lại các sản phẩm chưa tick chọn)
                  cartController.checkoutSelected();

                  // 3. 🆕 Hiển thị thông báo nhanh cho khách hàng
                  Get.snackbar(
                    'Thành công', 
                    'Đơn hàng của bạn đã được thanh toán!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.8),
                    colorText: Colors.white,
                  );

                  // 4. 🆕 Bay thẳng về Trang chủ và xóa toàn bộ các trang trước đó khỏi history stack
                  Get.offAllNamed(AppRoutes.home);
                },
                child: const Text('XÁC NHẬN ĐẶT HÀNG', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}