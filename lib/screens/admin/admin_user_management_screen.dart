import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/role_controller.dart';
import '../../models/user_role.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  String _searchQuery = '';

  Future<void> _changeRole(BuildContext context, String uid, UserRole newRole, String name) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == myUid && newRole == UserRole.user) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn không thể tự thu hồi quyền admin của chính mình.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'role': newRole.value,
    });

    if (uid == myUid) {
      RoleController.instance.setRole(newRole);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Quản lý người dùng', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
                }

                var docs = snapshot.data?.docs ?? [];

                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data();
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final email = (data['email'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery) || email.contains(_searchQuery);
                  }).toList();
                }

                final adminCount = (snapshot.data?.docs ?? []).where((d) => userRoleFromString(d.data()['role'] as String?).isAdmin).length;
                final userCount = (snapshot.data?.docs.length ?? 0) - adminCount;

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty ? 'Chưa có người dùng nào.' : 'Không tìm thấy người dùng phù hợp.',
                      style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }

                return Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(child: _SummaryChip(icon: Icons.people_outline, label: 'Tổng người dùng', value: '${snapshot.data?.docs.length ?? 0}', color: AppColors.primary)),
                          const SizedBox(width: 10),
                          Expanded(child: _SummaryChip(icon: Icons.admin_panel_settings_outlined, label: 'Quản trị viên', value: '$adminCount', color: const Color(0xFF7B61FF))),
                          const SizedBox(width: 10),
                          Expanded(child: _SummaryChip(icon: Icons.person_outline, label: 'Khách hàng', value: '$userCount', color: AppColors.success)),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data();
                          final name = (data['name'] ?? 'Chưa đặt tên') as String;
                          final email = (data['email'] ?? '') as String;
                          final phone = (data['phone'] ?? '') as String;
                          final role = userRoleFromString(data['role'] as String?);
                          final isMe = doc.id == myUid;
                          final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: role.isAdmin ? AppColors.primary.withOpacity(0.4) : AppColors.border),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: role.isAdmin ? AppColors.primary.withOpacity(0.15) : AppColors.divider,
                                  child: Text(
                                    initial,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: role.isAdmin ? AppColors.primary : AppColors.textSecondary,
                                    ),
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
                                              style: AppTextStyles.heading3,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                              child: const Text('Bạn', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(email, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      if (phone.isNotEmpty) Text(phone, style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<UserRole>(
                                    value: role,
                                    borderRadius: BorderRadius.circular(12),
                                    items: UserRole.values
                                        .map((r) => DropdownMenuItem(
                                              value: r,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(r.isAdmin ? Icons.admin_panel_settings : Icons.person_outline, size: 16, color: r.isAdmin ? AppColors.primary : AppColors.textSecondary),
                                                  const SizedBox(width: 6),
                                                  Text(r.label, style: const TextStyle(fontSize: 13)),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (newRole) {
                                      if (newRole != null && newRole != role) {
                                        _changeRole(context, doc.id, newRole, name);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
