import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/address_controller.dart';
import '../../models/address.dart';
import '../../widgets/custom_button.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  void _showAddressForm(BuildContext context, {Address? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final detailController = TextEditingController(text: existing?.detail ?? '');
    bool isSaving = false;
    bool isDefault = existing?.isDefault ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            existing == null ? Icons.add_location_alt_outlined : Icons.edit_location_alt_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            existing == null ? 'Thêm địa chỉ mới' : 'Chỉnh sửa địa chỉ',
                            style: AppTextStyles.heading2,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: 'Họ và tên người nhận',
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Số điện thoại',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: detailController,
                            maxLines: 2,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              labelText: 'Địa chỉ chi tiết (số nhà, đường, phường/xã, quận/huyện...)',
                              alignLabelWithHint: true,
                              prefixIcon: const Icon(Icons.location_on_outlined),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: isDefault,
                        activeColor: AppColors.primary,
                        title: const Text('Đặt làm địa chỉ mặc định', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Tự động chọn địa chỉ này khi Thanh toán', style: TextStyle(fontSize: 12)),
                        onChanged: (value) => setModalState(() => isDefault = value),
                      ),
                    ),
                    const SizedBox(height: 20),

                    CustomButton(
                      text: existing == null ? 'Thêm địa chỉ' : 'Lưu thay đổi',
                      isLoading: isSaving,
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty ||
                            phoneController.text.trim().isEmpty ||
                            detailController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                          );
                          return;
                        }

                        setModalState(() => isSaving = true);

                        try {
                          if (existing == null) {
                            await AddressController.instance.addAddress(
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              detail: detailController.text.trim(),
                              isDefault: isDefault,
                            );
                          } else {
                            await AddressController.instance.updateAddress(
                              existing.id,
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              detail: detailController.text.trim(),
                            );
                            if (isDefault && !existing.isDefault) {
                              await AddressController.instance.setDefault(existing.id);
                            }
                          }
                          if (context.mounted) Navigator.of(context).pop();
                        } catch (e) {
                          setModalState(() => isSaving = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAddress(BuildContext context, Address address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xoá địa chỉ'),
        content: Text('Bạn có chắc muốn xoá địa chỉ của "${address.name}" không?'),
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
      await AddressController.instance.deleteAddress(address.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Địa chỉ giao hàng')),
      body: StreamBuilder<List<Address>>(
        stream: AddressController.instance.watchAddresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
                    child: const Icon(Icons.location_off_outlined, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text('Chưa có địa chỉ nào', style: AppTextStyles.heading3),
                  const SizedBox(height: 6),
                  Text('Thêm địa chỉ để đặt hàng nhanh hơn', style: AppTextStyles.bodySecondary),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 90),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: address.isDefault ? AppColors.primary : AppColors.border,
                    width: address.isDefault ? 1.4 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (address.isDefault ? AppColors.primary : AppColors.textSecondary).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            address.isDefault ? Icons.location_on : Icons.location_on_outlined,
                            size: 18,
                            color: address.isDefault ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(address.name, style: AppTextStyles.heading3, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Mặc định',
                              style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(address.phone, style: AppTextStyles.bodySecondary),
                          const SizedBox(height: 4),
                          Text(address.detail, style: AppTextStyles.bodyRegular),
                        ],
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        if (!address.isDefault)
                          TextButton.icon(
                            onPressed: () => AddressController.instance.setDefault(address.id),
                            icon: const Icon(Icons.check_circle_outline, size: 16),
                            label: const Text('Đặt làm mặc định'),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _showAddressForm(context, existing: address),
                          icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          onPressed: () => _deleteAddress(context, address),
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressForm(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm địa chỉ', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
