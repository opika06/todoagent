import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogConfirm {
  static void show({
    required String title,
    required String content,
    required Function onConfirm,
    String confirmText = '确认',
    String cancelText = '取消',
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
} 