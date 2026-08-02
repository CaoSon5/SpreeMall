import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/product.dart';
import '../../models/store.dart';
import '../../utils/formatters.dart';

class SellerProductManagementScreen extends StatelessWidget {
  final Store store;
  const SellerProductManagementScreen({super.key, required this.store});

  CollectionReference<Map<String, dynamic>> get _productsRef => FirebaseFirestore.instance.collection('products');

  void _openForm(BuildContext context, {Product? existing, String? docId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SellerProductFormDialog(store: store, existing: existing, docId: docId),
    );
  }

  Future<void> _delete(BuildContext context, String docId, String name) async {
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
    if (confirm == true) await _productsRef.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Sản phẩm của ${store.name}')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm sản phẩm', style: TextStyle(color: Colors.white)),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _productsRef.where('storeId', isEqualTo: store.id).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'Cửa hàng chưa có sản phẩm nào.\nBấm "Thêm sản phẩm" để bắt đầu.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textSecondary),
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

              return Container(
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: product.hasImage
                          ? Image.network(product.image, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: AppColors.divider, child: const Icon(Icons.image_not_supported_outlined)))
                          : Container(width: 60, height: 60, color: AppColors.divider, child: const Icon(Icons.image_outlined)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: AppTextStyles.heading3, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(formatVnd(product.price), style: AppTextStyles.price.copyWith(fontSize: 14)),
                          Text('Kho: ${product.stock} · Đã bán: ${product.soldCount}', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary), onPressed: () => _openForm(context, existing: product, docId: doc.id)),
                    IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: () => _delete(context, doc.id, product.name)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SellerProductFormDialog extends StatefulWidget {
  final Store store;
  final Product? existing;
  final String? docId;
  const _SellerProductFormDialog({required this.store, this.existing, this.docId});

  @override
  State<_SellerProductFormDialog> createState() => _SellerProductFormDialogState();
}

class _SellerProductFormDialogState extends State<_SellerProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _oldPriceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _descCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _categoryCtrl = TextEditingController(text: p?.category ?? '');
    _priceCtrl = TextEditingController(text: p != null ? p.price.toString() : '');
    _oldPriceCtrl = TextEditingController(text: p?.oldPrice != null ? p!.oldPrice.toString() : '');
    _stockCtrl = TextEditingController(text: p != null ? p.stock.toString() : '100');
    _imageCtrl = TextEditingController(text: p?.image ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _priceCtrl.dispose();
    _oldPriceCtrl.dispose();
    _stockCtrl.dispose();
    _imageCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
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
      'isFlashSale': widget.existing?.isFlashSale ?? false,
      'sizes': widget.existing?.sizes ?? [],

      'brand': widget.store.name,
      'storeId': widget.store.id,
      'gender': widget.existing?.gender ?? 'unisex',
      'images': widget.existing?.images ?? [],
      'specs': widget.existing?.specs ?? {},
    };

    final ref = FirebaseFirestore.instance.collection('products');

    try {
      if (widget.docId != null) {
        await ref.doc(widget.docId).update(data);
      } else {
        await ref.add(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi lưu sản phẩm: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.docId != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: Row(
                children: [
                  Icon(isEdit ? Icons.edit_outlined : Icons.add_box_outlined, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Text(isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm mới', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: _saving ? null : () => Navigator.pop(context)),
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

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text('Đăng dưới thương hiệu: ${widget.store.name}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Tên sản phẩm', prefixIcon: Icon(Icons.label_outline)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc nhập' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _categoryCtrl,
                        decoration: const InputDecoration(labelText: 'Danh mục (VD: Giày Chạy Bộ...)', prefixIcon: Icon(Icons.category_outlined)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc nhập' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _imageCtrl,
                        decoration: const InputDecoration(labelText: 'Link ảnh sản phẩm (URL)', prefixIcon: Icon(Icons.image_outlined)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceCtrl,
                              decoration: const InputDecoration(labelText: 'Giá bán (đ)'),
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
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(labelText: 'Mô tả sản phẩm', alignLabelWithHint: true),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
              child: Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Huỷ'))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
