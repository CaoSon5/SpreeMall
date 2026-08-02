import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/store_controller.dart';
import '../../data/categories.dart';
import '../../models/store.dart';
import 'seller_dashboard_screen.dart';

class RegisterStoreScreen extends StatefulWidget {
  const RegisterStoreScreen({super.key});

  @override
  State<RegisterStoreScreen> createState() => _RegisterStoreScreenState();
}

class _RegisterStoreScreenState extends State<RegisterStoreScreen> {
  bool _navigating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Kênh người bán')),
      body: StreamBuilder<Store?>(
        stream: StoreController.instance.watchMyStore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final store = snapshot.data;

          if (store == null) {
            return const _StoreForm();
          }

          switch (store.status) {
            case StoreStatus.approved:

              if (!_navigating) {
                _navigating = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => SellerDashboardScreen(store: store)),
                    );
                  }
                });
              }
              return const Center(child: CircularProgressIndicator());
            case StoreStatus.pending:
              return _PendingView(store: store);
            case StoreStatus.rejected:
              return _StoreForm(existing: store);
          }
        },
      ),
    );
  }
}

class _PendingView extends StatelessWidget {
  final Store store;
  const _PendingView({required this.store});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.hourglass_top_rounded, size: 48, color: AppColors.warning),
            ),
            const SizedBox(height: 20),
            Text('Yêu cầu đang chờ duyệt', style: AppTextStyles.heading2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Cửa hàng "${store.name}" của bạn đang chờ Admin xem xét và duyệt. Vui lòng quay lại sau.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreForm extends StatefulWidget {
  final Store? existing;
  const _StoreForm({this.existing});

  @override
  State<_StoreForm> createState() => _StoreFormState();
}

class _StoreFormState extends State<_StoreForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _logoCtrl;
  late final TextEditingController _bannerCtrl;
  late Set<String> _selectedCategories;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _logoCtrl = TextEditingController(text: e?.logoUrl ?? '');
    _bannerCtrl = TextEditingController(text: e?.bannerUrl ?? '');
    _selectedCategories = {...(e?.categoryIds ?? [])};
  }

  @override
  void dispose() {
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
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 ngành hàng bạn sẽ bán')),
      );
      return;
    }

    setState(() => _saving = true);

    final error = await StoreController.instance.requestStore(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      logoUrl: _logoCtrl.text.trim(),
      bannerUrl: _bannerCtrl.text.trim(),
      categoryIds: _selectedCategories.toList(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã gửi yêu cầu! Vui lòng chờ Admin duyệt.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isResubmit = widget.existing?.status == StoreStatus.rejected;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isResubmit) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Yêu cầu trước đã bị từ chối', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                          const SizedBox(height: 4),
                          Text(widget.existing?.rejectReason ?? '', style: AppTextStyles.bodySecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Icon(Icons.storefront_outlined, size: 56, color: AppColors.primary),
              const SizedBox(height: 12),
              Text('Đăng ký bán hàng trên SpreeMall', style: AppTextStyles.heading2),
              const SizedBox(height: 6),
              Text(
                'Điền thông tin cửa hàng của bạn. Sau khi Admin duyệt, bạn sẽ được đăng và quản lý sản phẩm dưới tên thương hiệu này.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 20),
            ],
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Tên cửa hàng / thương hiệu', prefixIcon: Icon(Icons.storefront_outlined)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc nhập' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Mô tả ngắn về cửa hàng', alignLabelWithHint: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _logoCtrl,
              decoration: const InputDecoration(labelText: 'Link logo cửa hàng (URL, không bắt buộc)', prefixIcon: Icon(Icons.image_outlined)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bannerCtrl,
              decoration: const InputDecoration(
                labelText: 'Link ảnh nền/banner cửa hàng (URL, không bắt buộc)',
                helperText: 'Ảnh sẽ hiện mờ phía sau tên shop, nên chọn ảnh khổ ngang.',
                helperMaxLines: 2,
                prefixIcon: Icon(Icons.panorama_outlined),
              ),
            ),
            const SizedBox(height: 18),
            Text('Ngành hàng sẽ kinh doanh', style: AppTextStyles.heading3.copyWith(fontSize: 14)),
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
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isResubmit ? 'Gửi lại yêu cầu' : 'Gửi yêu cầu mở cửa hàng', style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
