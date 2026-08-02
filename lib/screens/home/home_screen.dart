import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../profile/profile_screen.dart';
import 'banner_slider.dart';
import '../home/category_section.dart';
import 'flash_sale_section.dart';
import 'home_app_bar.dart';
import 'home_bottom_nav.dart';
import 'home_tabs.dart';
import 'notifications_tab.dart';
import 'product_grid_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<String> _titles = [
    "Trang chủ",
    "Thông báo",
    "Giỏ hàng",
    "Tài khoản",
  ];

  void _goToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      const _HomeTabContent(),
      const NotificationsTab(),
      const CartTab(),
      const ProfileScreen(),
    ];

    final PreferredSizeWidget? appBar = _currentIndex == 0
        ? HomeAppBar(onCartTap: () => _goToTab(2))
        : (_currentIndex == 3
            ? null
            : AppBar(title: Text(_titles[_currentIndex])));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: appBar,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: _goToTab,
      ),
    );
  }
}

class _HomeTabContent extends StatelessWidget {
  const _HomeTabContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          BannerSlider(),
          SizedBox(height: 8),
          CategorySection(),
          SizedBox(height: 8),
          FlashSaleSection(),
          SizedBox(height: 8),
          ProductGridSection(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
