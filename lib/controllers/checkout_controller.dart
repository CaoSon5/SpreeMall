import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_controller.dart';
import '../models/product.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/order_status.dart';

class CheckoutController extends GetxController {
  static CheckoutController get instance => Get.find<CheckoutController>();

  final Rx<Address?> selectedAddress = Rx<Address?>(null);

  final Rx<PaymentMethod> selectedPaymentMethod = PaymentMethod.cod.obs;

  final RxBool isPlacingOrder = false.obs;

  final Rx<CartItem?> quickBuyItem = Rx<CartItem?>(null);

  void startQuickBuy(Product product, {required int quantity, String? size}) {
    quickBuyItem.value = CartItem(product: product, quantity: quantity, selected: true, size: size);
  }

  void clearQuickBuy() {
    quickBuyItem.value = null;
  }

  List<CartItem> get checkoutItems {
    final quick = quickBuyItem.value;
    if (quick != null) return [quick];
    return CartController.instance.items.where((i) => i.selected).toList();
  }

  double get checkoutTotal => checkoutItems.fold<int>(0, (sum, i) => sum + i.totalPrice).toDouble();

  void selectAddress(Address address) {
    selectedAddress.value = address;
  }

  void changePaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  void resetPaymentMethod() {
    selectedPaymentMethod.value = PaymentMethod.cod;
  }

  Future<bool> processOrder() async {
    final address = selectedAddress.value;

    if (address == null) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng chọn địa chỉ giao hàng', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    final itemsToOrder = checkoutItems;

    if (itemsToOrder.isEmpty) {
      Get.snackbar('Thiếu thông tin', 'Không có sản phẩm nào để đặt hàng', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    final totalAmount = checkoutTotal;
    final isQuickBuy = quickBuyItem.value != null;

    isPlacingOrder.value = true;
    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'uid': FirebaseAuth.instance.currentUser?.uid ?? '',
        'customerName': address.name,
        'customerPhone': address.phone,
        'customerAddress': address.detail,
        'paymentMethod': selectedPaymentMethod.value.value,
        'totalAmount': totalAmount,
        'status': OrderStatus.pending.value,
        'items': itemsToOrder
            .map((i) => {
                  'productId': i.product.id,
                  'productName': i.product.name,
                  'quantity': i.quantity,
                  'price': i.product.price,
                  'size': i.size,
                  'storeId': i.product.storeId,
                })
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      final productsRef = FirebaseFirestore.instance.collection('products');
      final batch = FirebaseFirestore.instance.batch();
      for (final item in itemsToOrder) {
        batch.update(productsRef.doc(item.product.id), {
          'stock': FieldValue.increment(-item.quantity),
          'soldCount': FieldValue.increment(item.quantity),
        });
      }
      await batch.commit();

      if (isQuickBuy) {

        quickBuyItem.value = null;
      } else {

        CartController.instance.checkoutSelected();
      }

      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể đặt hàng lúc này, vui lòng thử lại: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isPlacingOrder.value = false;
    }
  }
}
