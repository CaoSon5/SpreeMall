import 'package:flutter/material.dart';

class PolicyDetailScreen extends StatelessWidget {
  const PolicyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0.5,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Color(0xFFD32F2F)),
    onPressed: () => Navigator.pop(context),
  ),
  title: const Text(
    'An tâm mua sắm cùng SpreeMall', // Hợp thức hóa thương hiệu SpreeMall của bạn
    style: TextStyle(
      color: Colors.black87,
      fontSize: 18,
      fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _PolicyDetailBlock(
              icon: Icons.assignment_return_outlined,
              title: 'Trả hàng 15 ngày',
              description:
                  'Miễn phí Trả hàng trong 15 ngày để đảm bảo bạn hoàn toàn có thể yên tâm khi mua hàng ở SpreeMall.\nNgoài ra, tại thời điểm nhận hàng, bạn có thể đồng kiểm và được trả hàng miễn phí.',
            ),
            SizedBox(height: 24),
            _PolicyDetailBlock(
              icon: Icons.gpp_good_outlined,
              title: 'Chính hãng 100%',
              description:
                  'Cam kết 100% hàng chính hãng cho tất cả các sản phẩm từ SpreeMall. Bạn sẽ được hoàn lại gấp đôi số tiền bạn đã thanh toán cho sản phẩm thuộc SpreeMall và được chứng minh là không chính hãng.',
            ),
            SizedBox(height: 24),
            _PolicyDetailBlock(
              icon: Icons.local_shipping_outlined,
              title: 'Giao miễn phí',
              description:
                  'Miễn phí vận chuyển lên tới 40,000đ khi mua từ SpreeMall với tổng thanh toán từ một Shop là 150,000đ.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyDetailBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PolicyDetailBlock({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFD32F2F), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}