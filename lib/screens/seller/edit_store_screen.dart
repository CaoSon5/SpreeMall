import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/store_controller.dart';
import '../../data/categories.dart';
import '../../models/store.dart';

class EditStoreScreen extends StatefulWidget {
  final Store store;
  const EditStoreScreen({super.key, required this.store});

  @override
  State<EditStoreScreen> createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _logoCtrl;
  late final TextEditingController _bannerCtrl;
  late Set<String> _selectedCategories;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.store.description);
    _logoCtrl = TextEditingController(text: widget.store.logoUrl);
    _bannerCtrl = TextEditingController(text: widget.store.bannerUrl);
    _selectedCategories = {...widget.store.categoryIds};
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _logoCtrl.dispose();
    _bannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 ngành hàng')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await StoreController.instance.updateStoreInfo(
        storeId: widget.store.id,
        description: _descCtrl.text.trim(),
        logoUrl: _logoCtrl.text.trim(),
        bannerUrl: _bannerCtrl.text.trim(),
        categoryIds: _selectedCategories.toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đã cập nhật thông tin cửa hàng!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Sửa thông tin cửa hàng')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            TextFormField(
              initialValue: widget.store.name,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Tên cửa hàng',
                helperText: 'Không thể đổi tên cửa hàng vì sản phẩm đã đăng đang gắn theo tên này.',
                helperMaxLines: 2,
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Mô tả ngắn về cửa hàng', alignLabelWithHint: true),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _logoCtrl,
              decoration: const InputDecoration(labelText: 'Link logo cửa hàng (URL)', prefixIcon: Icon(Icons.image_outlined)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _bannerCtrl,
              decoration: const InputDecoration(
                labelText: 'Link ảnh nền/banner cửa hàng (URL)',
                helperText: 'Ảnh sẽ hiện mờ phía sau tên shop, nên chọn ảnh khổ ngang.',
                helperMaxLines: 2,
                prefixIcon: Icon(Icons.panorama_outlined),
              ),
            ),
            const SizedBox(height: 18),
            Text('Ngành hàng kinh doanh', style: AppTextStyles.heading3.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppCategories.all.map((c) {
                final id = c['id']!;
                final selected = _selectedCategories.contains(id);
                return FilterChip(
                  label: Text(c['title']!),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    if (selected) {
                      _selectedCategories.remove(id);
                    } else {
                      _selectedCategories.add(id);
                    }
                  }),
                  selectedColor: AppColors.primary.withOpacity(0.15),
                  labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textPrimary),
                  side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
