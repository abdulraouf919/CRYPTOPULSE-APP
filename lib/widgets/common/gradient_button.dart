import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  final List<Color>? gradientColors;
  final List<BoxShadow>? boxShadow;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.gradientColors,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? AppConstants.primaryGradient;
    final shadows = boxShadow ?? AppConstants.gradientShadow;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          gradient: LinearGradient(
            colors: isLoading 
                ? [Colors.grey.shade600, Colors.grey.shade800]
                : colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: isLoading ? null : shadows,
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      text,
                      style: AppConstants.whiteTextStyle.copyWith(fontSize: 18),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
} 