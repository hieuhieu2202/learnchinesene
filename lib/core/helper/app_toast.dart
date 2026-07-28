import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppToast {
  AppToast();

  static void showSuccess({required String title, required BuildContext context}) {
    CherryToast.success(
      description: Text(title, textAlign: TextAlign.left),
      animationType: AnimationType.fromTop,
      animationDuration: const Duration(milliseconds: 250),
      borderRadius: 8.w,
      shadowColor: Colors.black.withValues(alpha: 0.07),
    ).show(context);
  }

  static void showInfo({required String title, required BuildContext context}) {
    CherryToast.info(
      description: Text(title),
      animationType: AnimationType.fromTop,
      animationDuration: const Duration(milliseconds: 250),
      borderRadius: 8.w,
      shadowColor: Colors.black.withValues(alpha: 0.07),
    ).show(context);
  }

  static void showWarning({required String title, required BuildContext context}) {
    CherryToast.warning(
      description: Text(title),
      animationType: AnimationType.fromTop,
      animationDuration: const Duration(milliseconds: 250),
      borderRadius: 8.w,
      shadowColor: Colors.black.withValues(alpha: 0.07),
    ).show(context);
  }

  static void showError({required String title, required BuildContext context}) {
    CherryToast.error(
      description: Text(title),
      animationType: AnimationType.fromTop,
      animationDuration: const Duration(milliseconds: 250),
      borderRadius: 8.w,
      shadowColor: Colors.black.withValues(alpha: 0.07),
    ).show(context);
  }
}
