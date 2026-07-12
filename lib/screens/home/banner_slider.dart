import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'policy_detail_screen.dart'; 
class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  int _totalBanners = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  // Hàm kích hoạt chạy tự động chuẩn, chỉ chạy khi có nhiều hơn 1 banner
  void _resetAndStartTimer() {
    _timer?.cancel();
    if (_totalBanners <= 1) return;

    _timer = Timer.periodic(const Duration(milliseconds: 3500), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _totalBanners - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('banners').snapshots(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: Colors.orange)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final bannerDocs = snapshot.data!.docs;

        // KIỂM TRA ĐỘNG: Khi Firebase trả dữ liệu về lần đầu hoặc số lượng ảnh thay đổi
        if (_totalBanners != bannerDocs.length) {
          _totalBanners = bannerDocs.length;
          // Đợi widget dựng cấu trúc xong sẽ kích hoạt chu kỳ chạy tự động
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _resetAndStartTimer();
          });
        }

        return Column(
          children: [
            // Bọc GestureDetector để khi người dùng nhấn giữ vào ảnh thì dừng tự động chạy
            GestureDetector(
              onTapDown: (_) => _stopTimer(),
              onTapUp: (_) => _resetAndStartTimer(),
              onTapCancel: () => _resetAndStartTimer(),
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio: 2.5, // Tỷ lệ vàng khít ảnh, xóa bỏ khoảng xám trên dưới
                  child: Stack(
                    children: [
                      // Lắng nghe thao tác cuộn để tắt/bật Timer, tránh bị xung đột giật lag
                      NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          if (notification is ScrollStartNotification) {
                            _stopTimer();
                          } else if (notification is ScrollEndNotification) {
                            _resetAndStartTimer();
                          }
                          return false;
                        },
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _totalBanners,
                          physics: const BouncingScrollPhysics(), // Giúp kéo vuốt mượt mà trên cả Web lẫn Điện thoại
                          onPageChanged: (index) {
                            // Cập nhật vị trí trang hiện tại mà KHÔNG dùng setState ở đây 
                            // nhằm giải phóng PageView khỏi việc bị khóa cứng luồng kéo vuốt.
                            _currentPage = index;
                          },
                          itemBuilder: (context, index) {
                            final String imageUrl = bannerDocs[index]['url'] ?? '';

                            return SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Image.asset(
                                imageUrl,
                                fit: BoxFit.fill, // Ép ảnh phủ kín khít khung viền ngang dọc
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Thanh chấm tròn (Dots Indicator) - Tự động đồng bộ theo trang lướt bằng luồng riêng
                      Positioned(
                        bottom: 12,
                        left: 20,
                        child: ListenableBuilder(
                          listenable: _pageController,
                          builder: (context, child) {
                            // Tính toán vị trí trang hiển thị dựa trên chỉ số cuộn thực tế của PageController
                            int activePage = 0;
                            if (_pageController.hasClients && _pageController.page != null) {
                              activePage = _pageController.page!.round();
                            } else {
                              activePage = _currentPage;
                            }

                            return Row(
                              children: List.generate(
                                _totalBanners,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.only(right: 6),
                                  height: 6,
                                  width: activePage == index ? 18 : 6,
                                  decoration: BoxDecoration(
                                    color: activePage == index ? Colors.black87 : Colors.black26,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- PHẦN THÊM MỚI: Dòng thông tin tiện ích ngay dưới Banner ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PolicyItem(
                    icon: Icons.assignment_return_outlined,
                    label: 'Trả hàng 15 ngày',
                  ),
                  _PolicyItem(
                    icon: Icons.gpp_good_outlined,
                    label: 'Chính hãng 100%',
                  ),
                  _PolicyItem(
                    icon: Icons.local_shipping_outlined,
                    label: 'Giao miễn phí',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// Widget con cấu trúc chung cho từng mục Tiện ích (Có khả năng click chuyển màn hình)
class _PolicyItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PolicyItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Bắt sự kiện chạm vào dòng thông tin cam kết
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PolicyDetailScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        color: Colors.transparent, // Bọc màu nền trong suốt giúp vùng chạm ăn chuột/tay nhạy hơn
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFFD32F2F),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}