import 'package:flutter/material.dart';

class AuthTabSelector extends StatelessWidget {
  final TabController controller;

  const AuthTabSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.all(5),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: const Color(0xFFFF7B54),
          borderRadius: controller.index == 0
              ? const BorderRadius.only(
            topLeft: Radius.circular(50),
            bottomLeft: Radius.circular(50),
          )
              : const BorderRadius.only(
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF5A6A9A),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(child: Text('Đăng nhập')),
          Tab(child: Text('Đăng ký')),
        ],
      ),
    );
  }
}
