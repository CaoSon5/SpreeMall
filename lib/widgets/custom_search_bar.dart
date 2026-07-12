import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),

      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm...',
          border: InputBorder.none,

          prefixIcon: Icon(
            Icons.search,
          ),

          contentPadding: EdgeInsets.only(top: 12),
        ),
      ),
    );
  }
}