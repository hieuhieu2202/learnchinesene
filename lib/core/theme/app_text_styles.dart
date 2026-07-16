import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const display = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    height: 1.15,
  );
  static const title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );
  static const section = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const body = TextStyle(
    fontSize: 15,
    height: 1.45,
    color: AppColors.ink,
  );
  static const muted = TextStyle(
    fontSize: 14,
    height: 1.4,
    color: AppColors.muted,
  );
}
