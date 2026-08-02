import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/product.dart';
import '../../models/store.dart';
import '../home/product_grid_section.dart';
import '../../widgets/recommended_products_section.dart';

enum _SortOption { popular, bestSelling, priceAsc, priceDesc }

class BrandProductsScreen extends StatefulWidget {
  final String brandName;
  final String? brandLogoUrl;

  const BrandProductsScreen({
    super.key,
    required this.brandName,
    this.brandLogoUrl,
  });

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _isFollowing = false;
  late final TabController _tabController;
  String? _selectedCategory;
  _SortOption _sortOption = _SortOption.popular;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyword = widget.brandName.trim().toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('stores')
            .where('name', isEqualTo: widget.brandName)
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, storeSnapshot) {
          final storeDocs = storeSnapshot.data?.docs ?? [];
          final Store? realStore = storeDocs.isEmpty ? null : Store.fromMap(storeDocs.first.id, storeDocs.first.data());

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              final allProducts = (snapshot.data?.docs ?? []).map((d) => Product.fromMap(d.id, d.data())).toList();

              var brandProducts = allProducts.where((p) => p.brand.trim().toLowerCase() == keyword).toList();
              if (brandProducts.isEmpty) {
                brandProducts = allProducts
                    .where((p) => p.name.toLowerCase().contains(keyword) || p.category.toLowerCase().contains(keyword))
                    .toList();
              }

              final avgRating = brandProducts.isEmpty ? 0.0 : brandProducts.fold<double>(0, (sum, p) => sum + p.rating) / brandProducts.length;
              final totalSold = brandProducts.fold<int>(0, (sum, p) => sum + p.soldCount);

              final availableCategories = brandProducts.map((p) => p.category).where((c) => c.trim().isNotEmpty).toSet().toList()..sort();

              return Column(
                children: [
                  _ShopHeader(
                    name: widget.brandName,
                    logoUrl: widget.brandLogoUrl,
                    bannerUrl: realStore?.bannerUrl,
                    isOfficialStore: realStore != null,
                    avgRating: avgRating,
                    totalSold: totalSold,
                    productCount: brandProducts.length,
                    searchCtrl: _searchCtrl,
                    isFollowing: _isFollowing,
                    onSearchChanged: (v) => setState(() => _searchQuery = v),
                    onFollowTap: () => setState(() => _isFollowing = !_isFollowing),
                    onChatTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng chat đang được phát triển')),
                    ),
                  ),
                  Container(
                    color: Colors.black,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      tabs: const [Tab(text: 'Shop'), Tab(text: 'Sản phẩm'), Tab(text: 'Danh mục')],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _ShopTab(products: brandProducts, shopName: widget.brandName),
                        _ProductsTab(
                          products: brandProducts,
                          searchQuery: _searchQuery,
                          selectedCategory: _selectedCategory,
                          sortOption: _sortOption,
                          onSortSelected: (s) => setState(() => _sortOption = s),
                          onClearCategory: () => setState(() => _selectedCategory = null),
                        ),
                        _CategoryTab(
                          products: brandProducts,
                          availableCategories: availableCategories,
                          onCategoryTap: (c) {
                            setState(() => _selectedCategory = c);
                            _tabController.animateTo(1);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ShopTab extends StatelessWidget {
  final List<Product> products;
  final String shopName;

  const _ShopTab({required this.products, required this.shopName});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Text('$shopName chưa có sản phẩm nào.', style: AppTextStyles.bodySecondary),
      );
    }

    final shuffled = List.of(products)..shuffle(Random());
    final suggested = shuffled.take(8).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gợi ý cho bạn', style: AppTextStyles.heading3.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: suggested.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) => ProductCard(product: suggested[index]),
          ),
        ],
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  final List<Product> products;
  final String searchQuery;
  final String? selectedCategory;
  final _SortOption sortOption;
  final ValueChanged<_SortOption> onSortSelected;
  final VoidCallback onClearCategory;

  const _ProductsTab({
    required this.products,
    required this.searchQuery,
    required this.selectedCategory,
    required this.sortOption,
    required this.onSortSelected,
    required this.onClearCategory,
  });

  @override
  Widget build(BuildContext context) {
    var filtered = products;

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    if (selectedCategory != null) {
      filtered = filtered.where((p) => p.category == selectedCategory).toList();
    }

    final sorted = List.of(filtered);
    switch (sortOption) {
      case _SortOption.popular:
        break;
      case _SortOption.bestSelling:
        sorted.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      case _SortOption.priceAsc:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _SortOption.priceDesc:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    return Column(
      children: [

        if (selectedCategory != null)
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 6,
              children: [
                Chip(
                  label: Text(selectedCategory!, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  side: const BorderSide(color: AppColors.primary),
                  deleteIcon: const Icon(Icons.close, size: 15, color: AppColors.primary),
                  onDeleted: onClearCategory,
                ),
              ],
            ),
          ),

        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _SortTab(label: 'Phổ biến', selected: sortOption == _SortOption.popular, onTap: () => onSortSelected(_SortOption.popular)),
              _SortTab(label: 'Bán chạy', selected: sortOption == _SortOption.bestSelling, onTap: () => onSortSelected(_SortOption.bestSelling)),
              _SortTab(
                label: 'Giá',
                selected: sortOption == _SortOption.priceAsc || sortOption == _SortOption.priceDesc,
                trailingIcon: sortOption == _SortOption.priceAsc
                    ? Icons.arrow_upward
                    : sortOption == _SortOption.priceDesc
                        ? Icons.arrow_downward
                        : null,
                onTap: () => onSortSelected(sortOption == _SortOption.priceAsc ? _SortOption.priceDesc : _SortOption.priceAsc),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: sorted.isEmpty
              ? Center(
                  child: Text(
                    searchQuery.isNotEmpty ? 'Không tìm thấy sản phẩm phù hợp.' : 'Chưa có sản phẩm nào ở mục này.',
                    style: AppTextStyles.bodySecondary,
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: sorted.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) => ProductCard(product: sorted[index]),
                ),
        ),
      ],
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final List<Product> products;
  final List<String> availableCategories;
  final ValueChanged<String> onCategoryTap;

  const _CategoryTab({
    required this.products,
    required this.availableCategories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (availableCategories.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Shop chưa có danh mục nào.', style: AppTextStyles.bodySecondary),
            )
          else
            ...availableCategories.map((category) {
              final count = products.where((p) => p.category == category).length;
              return Container(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                child: ListTile(
                  title: Text(category, style: AppTextStyles.bodyRegular.copyWith(fontWeight: FontWeight.w600)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('($count)', style: AppTextStyles.bodySecondary),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: AppColors.textHint),
                    ],
                  ),
                  onTap: () => onCategoryTap(category),
                ),
              );
            }),
          const SizedBox(height: 20),

          const RecommendedProductsSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SortTab extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? trailingIcon;
  final VoidCallback onTap;

  const _SortTab({required this.label, required this.selected, required this.onTap, this.trailingIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 2),
              Icon(trailingIcon, size: 13, color: AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShopHeader extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final String? bannerUrl;
  final bool isOfficialStore;
  final double avgRating;
  final int totalSold;
  final int productCount;
  final TextEditingController searchCtrl;
  final bool isFollowing;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFollowTap;
  final VoidCallback onChatTap;

  const _ShopHeader({
    required this.name,
    required this.logoUrl,
    this.bannerUrl,
    required this.isOfficialStore,
    required this.avgRating,
    required this.totalSold,
    required this.productCount,
    required this.searchCtrl,
    required this.isFollowing,
    required this.onSearchChanged,
    required this.onFollowTap,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [

          if (bannerUrl != null && bannerUrl!.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                bannerUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          if (bannerUrl != null && bannerUrl!.isNotEmpty)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.55), Colors.black.withOpacity(0.72)],
                  ),
                ),
              ),
            ),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 18, color: AppColors.textHint),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: searchCtrl,
                              onChanged: onSearchChanged,
                              style: const TextStyle(fontSize: 13.5),
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm sản phẩm trong $name',
                                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (logoUrl != null && logoUrl!.isNotEmpty)
                          ? Image.network(
                              logoUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => _LogoFallback(name: name),
                            )
                          : _LogoFallback(name: name),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isOfficialStore) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                                child: const Text('CHÍNH HÃNG', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                            const SizedBox(width: 2),
                            Text(avgRating > 0 ? avgRating.toStringAsFixed(1) : '—', style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 10),
                            Text('$productCount sản phẩm', style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                            const SizedBox(width: 10),
                            Text('Đã bán $totalSold', style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: onFollowTap,
                              icon: Icon(isFollowing ? Icons.check : Icons.add, size: 15, color: Colors.white),
                              label: Text(isFollowing ? 'Đang theo dõi' : 'Theo dõi', style: const TextStyle(color: Colors.white, fontSize: 12.5)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white70),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: onChatTap,
                              icon: const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.white),
                              label: const Text('Chat', style: TextStyle(color: Colors.white, fontSize: 12.5)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white70),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }
}

class _LogoFallback extends StatelessWidget {
  final String name;
  const _LogoFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.divider,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 22),
      ),
    );
  }
}
