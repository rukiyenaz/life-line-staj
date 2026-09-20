import 'package:flutter/material.dart';
import 'package:life_line/features/widgets/common/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appBar,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(title,
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
