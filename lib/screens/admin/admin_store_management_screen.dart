import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/store_controller.dart';
import '../../data/categories.dart';
import '../../models/store.dart';

class AdminStoreManagementScreen extends StatefulWidget {
  const AdminStoreManagementScreen({super.key});

  @override
  State<AdminStoreManagementScreen> createState() => _AdminStoreManagementScreenState();
}

class _AdminStoreManagementScreenState extends State<AdminStoreManagementScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const _tabs = [StoreStatus.pending, StoreStatus.approved, StoreStatus.rejected];
  static const _labels = ['Chờ duyệt', 'Đã duyệt', 'Bị từ chối'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _approve(BuildContext context, Store store) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Duyệt cửa hàng'),
        content: Text('Duyệt cho "${store.name}" (${store.ownerEmail}) được bán hàng trên sàn?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Duyệt')),
        ],
      ),
    );
    if (confirm == true) {
      await StoreController.instance.approveStore(store);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã duyệt cửa hàng "${store.name}"')));
      }
    }
  }

  Future<void> _reject(BuildContext context, Store store) async {
    final reasonCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Từ chối yêu cầu'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Lý do từ chối (không bắt buộc)'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await StoreController.instance.rejectStore(store, reason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Quản lý cửa hàng', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => showDialog(context: context, builder: (_) => const _CreateStoreDialog()),
        icon: const Icon(Icons.add_business_outlined, color: Colors.white),
        label: const Text('Tạo cửa hàng thủ công', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<Store>>(
        stream: StoreController.instance.watchAllStores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final allStores = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: _tabs.map((status) {
              final stores = allStores.where((s) => s.status == status).toList();

              if (stores.isEmpty) {
                return Center(child: Text('Không có cửa hàng nào ở mục này.', style: AppTextStyles.bodySecondary));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: stores.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final store = stores[index];
                  final categoryTitles = store.categoryIds.map(AppCategories.titleOf).join(', ');

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              backgroundImage: store.logoUrl.isNotEmpty ? NetworkImage(store.logoUrl) : null,
                              child: store.logoUrl.isEmpty
                                  ? Text(store.name.isNotEmpty ? store.name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(store.name, style: AppTextStyles.heading3),
                                  Text(store.ownerEmail, style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (store.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(store.description, style: AppTextStyles.bodyRegular),
                        ],
                        if (categoryTitles.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Ngành hàng: $categoryTitles', style: AppTextStyles.caption),
                        ],
                        if (store.status == StoreStatus.rejected && store.rejectReason != null) ...[
                          const SizedBox(height: 6),
                          Text('Lý do từ chối: ${store.rejectReason}', style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                        ],
                        if (store.status == StoreStatus.pending) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _reject(context, store),
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                                  child: const Text('Từ chối'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _approve(context, store),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                  child: const Text('Duyệt', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _CreateStoreDialog extends StatefulWidget {
  const _CreateStoreDialog();

  @override
  State<_CreateStoreDialog> createState() => _CreateStoreDialogState();
}

class _CreateStoreDialogState extends State<_CreateStoreDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  final _bannerCtrl = TextEditingController();
  final Set<String> _selectedCategories = {};
  bool _saving = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _logoCtrl.dispose();
    _bannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 ngành hàng')),
      );
      return;
    }

    setState(() => _saving = true);

    final error = await StoreController.instance.createStoreForUser(
      ownerEmail: _emailCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      logoUrl: _logoCtrl.text.trim(),
      bannerUrl: _bannerCtrl.text.trim(),
      categoryIds: _selectedCategories.toList(),
    );

    if (!mounted) return;

    if (error != null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Đã tạo cửa hàng "${_nameCtrl.text.trim()}" và duyệt luôn cho tài khoản đó!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.add_business_outlined, color: Colors.white),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Tạo cửa hàng thủ công', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
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
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email tài khoản sẽ làm chủ cửa hàng',
                          helperText: 'Tài khoản này phải ĐÃ đăng ký sẵn trong app (Firebase Auth).',
                          helperMaxLines: 2,
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc nhập' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Tên cửa hàng / thương hiệu (VD: Samsung)', prefixIcon: Icon(Icons.storefront_outlined)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc nhập' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(labelText: 'Mô tả ngắn', alignLabelWithHint: true),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _logoCtrl,
                        decoration: const InputDecoration(labelText: 'Link logo (URL)', prefixIcon: Icon(Icons.image_outlined)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _bannerCtrl,
                        decoration: const InputDecoration(labelText: 'Link ảnh nền/banner (URL, không bắt buộc)', prefixIcon: Icon(Icons.panorama_outlined)),
                      ),
                      const SizedBox(height: 16),
                      Text('Ngành hàng', style: AppTextStyles.heading3.copyWith(fontSize: 14)),
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
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Tạo & Duyệt luôn', style: TextStyle(color: Colors.white)),
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
