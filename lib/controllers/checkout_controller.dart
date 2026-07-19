import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutController extends GetxController {
  // Trạng thái lưu phương thức thanh toán được chọn (COD hoặc Thẻ)
  var selectedPaymentMethod = 'COD'.obs;
  
  // Các controller quản lý nhập liệu thông tin giao hàng
  final addressController = ''.obs;
  final phoneController = ''.obs;
  final nameController = ''.obs;

  void changePaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void processOrder({required double totalAmount}) {
    if (nameController.value.isEmpty || addressController.value.isEmpty || phoneController.value.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng điền đầy đủ thông tin giao hàng',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Logic xử lý thanh toán/đặt hàng (gọi API hoặc kết nối Firebase ở đây)
    Get.dialog(
      SimpleDialog(
        title: const Text('Đặt hàng thành công!'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Cảm ơn bạn đã mua hàng. Tổng tiền: \$${totalAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.close(2); // Đóng dialog và quay lại màn hình chính
                  },
                  child: const Text('Quay lại trang chủ'),
                )
              ],
            ),
          )
        ],
      ),
      barrierDismissible: false,
    );
  }
}