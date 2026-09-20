import 'package:flutter/material.dart';
import 'package:life_line/features/widgets/common/colors.dart';

class AuthCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const AuthCard({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: label.contains('Şifre'),
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '$label giriniz',
            ),
          ),
        ],
      ),
    );
  }
}
