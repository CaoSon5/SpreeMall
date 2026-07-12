import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';

class _Address {
  String name;
  String phone;
  String detail;
  bool isDefault;

  _Address({
    required this.name,
    required this.phone,
    required this.detail,
    this.isDefault = false,
  });
}

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final List<_Address> _addresses = [
    _Address(
      name: 'Nguyễn Văn A',
      phone: '0901 234 567',
      detail: '123 Đường Lê Lợi, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
      isDefault: true,
    ),
    _Address(
      name: 'Nguyễn Văn A (Công ty)',
      phone: '0901 234 567',
      detail: '45 Đường Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
    ),
  ];

  void _setDefault(int index) {
    setState(() {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i].isDefault = i == index;
      }
    });
  }

  void _deleteAddress(int index) {
    setState(() => _addresses.removeAt(index));
  }

  void _showAddressForm({_Address? existing, int? index}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final detailController = TextEditingController(text: existing?.detail ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                existing == null ? 'Thêm địa chỉ mới' : 'Chỉnh sửa địa chỉ',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Họ và tên người nhận',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Địa chỉ chi tiết',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: existing == null ? 'Thêm địa chỉ' : 'Lưu thay đổi',
                onPressed: () {
                  if (nameController.text.trim().isEmpty ||
                      phoneController.text.trim().isEmpty ||
                      detailController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                    );
                    return;
                  }

                  setState(() {
                    if (existing == null) {
                      _addresses.add(_Address(
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        detail: detailController.text.trim(),
                      ));
                    } else if (index != null) {
                      _addresses[index]
                        ..name = nameController.text.trim()
                        ..phone = phoneController.text.trim()
                        ..detail = detailController.text.trim();
                    }
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Địa chỉ giao hàng')),
      body: _addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_outlined, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('Chưa có địa chỉ nào', style: AppTextStyles.bodySecondary),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(15),
              itemCount: _addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: address.isDefault ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(address.name, style: AppTextStyles.heading3),
                          ),
                          if (address.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Mặc định',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(address.phone, style: AppTextStyles.bodySecondary),
                      const SizedBox(height: 4),
                      Text(address.detail, style: AppTextStyles.bodyRegular),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (!address.isDefault)
                            TextButton(
                              onPressed: () => _setDefault(index),
                              child: const Text('Đặt làm mặc định'),
                            ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => _showAddressForm(existing: address, index: index),
                            icon: const Icon(Icons.edit_outlined, size: 20),
                          ),
                          IconButton(
                            onPressed: () => _deleteAddress(index),
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Thêm địa chỉ'),
      ),
    );
  }
}
