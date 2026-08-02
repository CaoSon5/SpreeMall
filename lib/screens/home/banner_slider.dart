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

        if (_totalBanners != bannerDocs.length) {
          _totalBanners = bannerDocs.length;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _resetAndStartTimer();
          });
        }

        return Column(
          children: [

            GestureDetector(
              onTapDown: (_) => _stopTimer(),
              onTapUp: (_) => _resetAndStartTimer(),
              onTapCancel: () => _resetAndStartTimer(),
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio: 2.5,
                  child: Stack(
                    children: [

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
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (index) {

                            _currentPage = index;
                          },
                          itemBuilder: (context, index) {
                            final String imageUrl = bannerDocs[index]['url'] ?? '';

                            return SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Image.asset(
                                imageUrl,
                                fit: BoxFit.fill,
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

                      Positioned(
                        bottom: 12,
                        left: 20,
                        child: ListenableBuilder(
                          listenable: _pageController,
                          builder: (context, child) {

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

class _PolicyItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PolicyItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

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
        color: Colors.transparent,
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