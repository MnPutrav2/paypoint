import 'package:flutter/material.dart';
import 'package:kasir_offline/core/constants/app_text_styles.dart';

class AppAuthRedirect extends StatelessWidget {
  final String question; // "Tidak punya akun"
  final String actionText; // "Sign up"
  final VoidCallback onTap; // aksi saat diklik

  const AppAuthRedirect({
    super.key,
    required this.question,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$question  ', style: AppTextStyles.caption),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: AppTextStyles.caption.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
