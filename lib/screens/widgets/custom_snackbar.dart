import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static void showSnackBar({
    required String title,
    required String message,
    Color backgroundColor = Colors.yellow,
    Color textColor = Colors.black,
    Color iconColor = Colors.red,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.info,
  }) {
    Get.snackbar(
      title,
      message,
      icon: Icon(icon, color: iconColor),
      snackPosition: snackPosition,
      backgroundColor: backgroundColor,
      colorText: textColor,
      borderRadius: 8,
      margin: const EdgeInsets.all(10),
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }
}
