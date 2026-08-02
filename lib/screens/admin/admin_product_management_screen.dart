import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/product.dart';
import '../../utils/formatters.dart';

class AdminProductManagementScreen extends StatelessWidget {
  const AdminProductManagementScreen({super.key});

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      FirebaseFirestore.instance.collection('products');

  void _openProductForm(BuildContext context, {Product? existing, String? docId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ProductFormDialog(existing: existing, docId: docId),
    );
  }

  Future<void> _deleteProduct(BuildContext context, String docId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xoá sản phẩm'),
        content: Text('Bạn có chắc muốn xoá "$name" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _productsRef.doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Quản lý sản phẩm', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openProductForm(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm sản phẩm', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _productsRef.orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 56, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có sản phẩm nào.\nBấm "Thêm sản phẩm" để bắt đầu.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final product = Product.fromMap(doc.id, doc.data());
              final lowStock = product.stock <= 5;

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: product.hasImage
                                ? Image.network(
                                    product.image,
                                    width: 68,
                                    height: 68,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 68,
                                      height: 68,
                                      color: AppColors.divider,
                                      child: const Icon(Icons.image_not_supported_outlined, size: 22),
                                    ),
                                  )
                                : Container(
                                    width: 68,
                                    height: 68,
                                    color: AppColors.divider,
                                    child: const Icon(Icons.image_outlined, size: 22),
                                  ),
                          ),
                          if (product.isFlashSale)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(8)),
                                ),
                                child: const Text('⚡', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: AppTextStyles.heading3, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Text(product.category, style: AppTextStyles.caption),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(formatVnd(product.price), style: AppTextStyles.price.copyWith(fontSize: 15)),
                                if (product.hasDiscount) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    formatVnd(product.oldPrice ?? product.price),
                                    style: AppTextStyles.caption.copyWith(decoration: TextDecoration.lineThrough),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (lowStock ? AppColors.error : AppColors.success).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Kho: ${product.stock}',
                                    style: TextStyle(fontSize: 11, color: lowStock ? AppColors.error : AppColors.success, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (product.sizes.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      product.sizes.join(', '),
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF8A6D00), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
                            onPressed: () => _openProductForm(context, existing: product, docId: doc.id),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                            onPressed: () => _deleteProduct(context, doc.id, product.name),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  final Product? existing;
  final String? docId;

  const _ProductFormDialog({this.existing, this.docId});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _customIdCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _oldPriceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _customSizeCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _extraImagesCtrl;
  late List<_SpecRow> _specRows;

  bool _isFlashSale = false;
  bool _saving = false;
  late Set<String> _selectedSizes;
  late String _selectedGender;

  static const List<String> _shoeSizeSuggestions = ['36', '37', '38', '39', '40', '41', '42', '43', '44'];
  static const List<String> _clothingSizeSuggestions = ['S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _customIdCtrl = TextEditingController();
    _categoryCtrl = TextEditingController(text: p?.category ?? '');
    _priceCtrl = TextEditingController(text: p != null ? p.price.toString() : '');
    _oldPriceCtrl = TextEditingController(text: p?.oldPrice != null ? p!.oldPrice.toString() : '');
    _stockCtrl = TextEditingController(text: p != null ? p.stock.toString() : '100');
    _imageCtrl = TextEditingController(text: p?.image ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _customSizeCtrl = TextEditingController();
    _brandCtrl = TextEditingController(text: p?.brand ?? '');
    _extraImagesCtrl = TextEditingController(text: (p?.images ?? []).join('\n'));
    _specRows = (p?.specs.entries ?? const <MapEntry<String, String>>[])
        .map((e) => _SpecRow(key: e.key, value: e.value))
        .toList();
    if (_specRows.isEmpty) _specRows.add(_SpecRow());
    _isFlashSale = p?.isFlashSale ?? false;
    _selectedSizes = {...(p?.sizes ?? [])};
    _selectedGender = p?.gender ?? 'unisex';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _customIdCtrl.dispose();
    _categoryCtrl.dispose();
    _priceCtrl.dispose();
    _oldPriceCtrl.dispose();
    _stockCtrl.dispose();
    _imageCtrl.dispose();
    _descCtrl.dispose();
    _customSizeCtrl.dispose();
    _brandCtrl.dispose();
    _extraImagesCtrl.dispose();
    for (final row in _specRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _toggleSize(String size) {
    setState(() {
      if (_selectedSizes.contains(size)) {
        _selectedSizes.remove(size);
      } else {
        _selectedSizes.add(size);
      }
    });
  }

  void _addCustomSize() {
    final value = _customSizeCtrl.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _selectedSizes.add(value);
      _customSizeCtrl.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'category': _categoryCtrl.text.trim(),
      'price': int.parse(_priceCtrl.text.trim()),
      'oldPrice': _oldPriceCtrl.text.trim().isEmpty ? null : int.parse(_oldPriceCtrl.text.trim()),
      'rating': widget.existing?.rating ?? 4.5,
      'soldCount': widget.existing?.soldCount ?? 0,
      'stock': int.parse(_stockCtrl.text.trim()),
      'image': _imageCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'isFlashSale': _isFlashSale,
      'sizes': _selectedSizes.toList(),
      'brand': _brandCtrl.text.trim(),
      'gender': _selectedGender,
      'images': _extraImagesCtrl.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'specs': {
        for (final row in _specRows)
          if (row.keyCtrl.text.trim().isNotEmpty) row.keyCtrl.text.trim(): row.valueCtrl.text.trim(),
      },
    };

    final ref = FirebaseFirestore.instance.collection('products');

    try {
      if (widget.docId != null) {
        await ref.doc(widget.docId).update(data);
      } else {
        final customId = _customIdCtrl.text.trim();

        if (customId.isEmpty) {

          await ref.add(data);
        } else {

          final existing = await ref.doc(customId).get();
          if (existing.exists) {
            if (mounted) {
              setState(() => _saving = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mã "$customId" đã được dùng cho sản phẩm khác, vui lòng đặt mã khác.')),
              );
            }
            return;
          }
          await ref.doc(customId).set(data);
        }
      }

      await _ensureBrandExists(_brandCtrl.text.trim(), _categoryCtrl.text.trim(), _selectedGender);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu sản phẩm: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<String> _resolveCategoryIds(String categoryText, String gender) {
    final text = categoryText.toLowerCase();

    bool has(List<String> keywords) => keywords.any((k) => text.contains(k));

    if (has(['giày', 'dép', 'sneaker'])) {
      if (gender == 'nam') return ['giay_dep_nam'];
      if (gender == 'nu') return ['giay_dep_nu'];
      return ['giay_dep_nam', 'giay_dep_nu'];
    }
    if (has(['thời trang', 'quần áo', 'áo', 'quần', 'váy'])) {
      if (gender == 'nam') return ['thoi_trang_nam'];
      if (gender == 'nu') return ['thoi_trang_nu'];
      return ['thoi_trang_nam', 'thoi_trang_nu'];
    }
    if (has(['điện thoại', 'smartphone'])) return ['dien_thoai'];
    if (has(['laptop', 'máy tính xách tay'])) return ['laptop'];
    if (has(['đồng hồ'])) return ['dong_ho'];
    if (has(['tai nghe'])) return ['tai_nghe'];
    if (has(['bếp', 'nồi', 'chảo'])) return ['nha_bep'];
    if (has(['tv', 'tivi'])) return ['tv'];

    return ['khac'];
  }

  Future<void> _ensureBrandExists(String brandName, String categoryText, String gender) async {
    if (brandName.isEmpty) return;

    final categoryIds = _resolveCategoryIds(categoryText, gender);
    final brandsRef = FirebaseFirestore.instance.collection('brands');

    final snapshot = await brandsRef.get();
    QueryDocumentSnapshot<Map<String, dynamic>>? existingDoc;
    for (final doc in snapshot.docs) {
      final name = (doc.data()['name'] ?? '').toString().trim().toLowerCase();
      if (name == brandName.toLowerCase()) {
        existingDoc = doc;
        break;
      }
    }

    if (existingDoc == null) {
      await brandsRef.add({
        'name': brandName,
        'url': '',
        'categoryIds': categoryIds,
      });
    } else {
      final current = List<String>.from(existingDoc.data()['categoryIds'] ?? []);
      final merged = {...current, ...categoryIds}.toList();
      await existingDoc.reference.update({'categoryIds': merged});
    }
  }

  Widget _sectionLabel(String text, {String? subtitle}) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: AppTextStyles.heading3.copyWith(fontSize: 13, color: AppColors.primary)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.docId != null;
    final allSizeSuggestions = {..._shoeSizeSuggestions, ..._clothingSizeSuggestions, ..._selectedSizes}.toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(isEdit ? Icons.edit_outlined : Icons.add_box_outlined, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm mới',
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _saving ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 96,
                            height: 96,
                            color: AppColors.divider,
                            child: _imageCtrl.text.trim().isEmpty
                                ? const Icon(Icons.image_outlined, size: 32, color: AppColors.textHint)
                                : Image.network(
                                    _imageCtrl.text.trim(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 32, color: AppColors.textHint),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _sectionLabel('THÔNG TIN CƠ BẢN'),

                      if (widget.docId == null) ...[
                        TextFormField(
                          controller: _customIdCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Mã sản phẩm - ID (không bắt buộc)',
                            helperText: 'Để trống thì Firestore tự sinh ID ngẫu nhiên. Tự đặt (VD: "samsung_z_fold7") sẽ dễ tìm/sửa trực tiếp trên Firebase Console hơn.',
                            helperMaxLines: 3,
                            prefixIcon: Icon(Icons.tag_outlined),
                          ),

                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_\-]')),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],

                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Tên sản phẩm', prefixIcon: Icon(Icons.label_outline)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc nhập' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _imageCtrl,
                        decoration: const InputDecoration(labelText: 'Link ảnh sản phẩm (URL)', prefixIcon: Icon(Icons.image_outlined)),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _extraImagesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Ảnh phụ (không bắt buộc)',
                          helperText: 'Mỗi dòng 1 link ảnh - khách sẽ vuốt xem được nhiều ảnh ở trang chi tiết.',
                          helperMaxLines: 2,
                          prefixIcon: Icon(Icons.photo_library_outlined),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        minLines: 2,
                      ),

                      _sectionLabel(
                        'DANH MỤC & THƯƠNG HIỆU',
                        subtitle: 'Quyết định sản phẩm hiện ở đâu: trong danh mục nào, khi bấm vào logo thương hiệu, và ở tab Nam/Nữ nào.',
                      ),
                      TextFormField(
                        controller: _categoryCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Danh mục (VD: Giày Chạy Bộ, Giày Da Lộn...)',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc nhập' : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _brandCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Thương hiệu (VD: Nike, Samsung, IKEA...)',
                          helperText: 'Gõ ĐÚNG tên thương hiệu - sẽ tự động hiện ở mục "Thương hiệu ưa chuộng" cho đúng danh mục sản phẩm.',
                          helperMaxLines: 2,
                          prefixIcon: Icon(Icons.storefront_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text('Giới tính áp dụng', style: AppTextStyles.bodyRegular.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Text(
                        'Chọn "Unisex" nếu sản phẩm dùng được cho cả nam và nữ - sẽ tự hiện ở cả 2 tab.',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _GenderOption(
                            label: '🚻 Unisex',
                            value: 'unisex',
                            groupValue: _selectedGender,
                            onTap: () => setState(() => _selectedGender = 'unisex'),
                          ),
                          const SizedBox(width: 8),
                          _GenderOption(
                            label: '👨 Nam',
                            value: 'nam',
                            groupValue: _selectedGender,
                            onTap: () => setState(() => _selectedGender = 'nam'),
                          ),
                          const SizedBox(width: 8),
                          _GenderOption(
                            label: '👩 Nữ',
                            value: 'nu',
                            groupValue: _selectedGender,
                            onTap: () => setState(() => _selectedGender = 'nu'),
                          ),
                        ],
                      ),

                      _sectionLabel('GIÁ & KHO HÀNG (đơn vị: đ)'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceCtrl,
                              decoration: const InputDecoration(labelText: 'Giá bán (đ)', prefixIcon: Icon(Icons.sell_outlined)),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Bắt buộc';
                                if (int.tryParse(v.trim()) == null) return 'Số không hợp lệ';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _oldPriceCtrl,
                              decoration: const InputDecoration(labelText: 'Giá gốc (đ)'),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                if (int.tryParse(v.trim()) == null) return 'Số không hợp lệ';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _stockCtrl,
                        decoration: const InputDecoration(labelText: 'Tồn kho', prefixIcon: Icon(Icons.inventory_2_outlined)),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Bắt buộc';
                          if (int.tryParse(v.trim()) == null) return 'Số không hợp lệ';
                          return null;
                        },
                      ),

                      _sectionLabel('SIZE SẢN PHẨM'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allSizeSuggestions.map((size) {
                          final selected = _selectedSizes.contains(size);
                          return FilterChip(
                            label: Text(size),
                            selected: selected,
                            onSelected: (_) => _toggleSize(size),
                            selectedColor: AppColors.primary.withOpacity(0.15),
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textPrimary, fontWeight: FontWeight.w600),
                            side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customSizeCtrl,
                              decoration: const InputDecoration(labelText: 'Thêm size khác (VD: 45, 3XL...)'),
                              onSubmitted: (_) => _addCustomSize(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                            onPressed: _addCustomSize,
                            icon: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),

                      _sectionLabel(
                        'THÔNG SỐ KỸ THUẬT',
                        subtitle: 'Tự thêm các thông số phù hợp với ĐÚNG loại sản phẩm (VD: điện thoại thì "RAM", "Dung lượng"; giày thì "Chất liệu", "Xuất xứ"...). Để trống nếu không cần.',
                      ),
                      ...List.generate(_specRows.length, (index) {
                        final row = _specRows[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: TextField(
                                  controller: row.keyCtrl,
                                  decoration: const InputDecoration(hintText: 'Tên thông số (VD: RAM)', isDense: true),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 5,
                                child: TextField(
                                  controller: row.valueCtrl,
                                  decoration: const InputDecoration(hintText: 'Giá trị (VD: 12GB)', isDense: true),
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                                onPressed: _specRows.length == 1
                                    ? null
                                    : () => setState(() {
                                          _specRows[index].dispose();
                                          _specRows.removeAt(index);
                                        }),
                              ),
                            ],
                          ),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _specRows.add(_SpecRow())),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm thông số'),
                        ),
                      ),

                      _sectionLabel('KHÁC'),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(labelText: 'Mô tả sản phẩm', alignLabelWithHint: true),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 4),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _isFlashSale,
                        title: const Text('Hiển thị ở mục ⚡ Flash Sale'),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) => setState(() => _isFlashSale = value ?? false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Huỷ'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Lưu sản phẩm', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.12) : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecRow {
  final TextEditingController keyCtrl;
  final TextEditingController valueCtrl;

  _SpecRow({String key = '', String value = ''})
      : keyCtrl = TextEditingController(text: key),
        valueCtrl = TextEditingController(text: value);

  void dispose() {
    keyCtrl.dispose();
    valueCtrl.dispose();
  }
}
