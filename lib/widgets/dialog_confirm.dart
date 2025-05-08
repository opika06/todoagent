import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogConfirm extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmTextColor;
  final bool barrierDismissible;

  const DialogConfirm({
    super.key,
    required this.title,
    required this.content,
    this.cancelText = '取消',
    this.confirmText = '确定',
    this.onConfirm,
    this.onCancel,
    this.confirmTextColor = Colors.red,
    this.barrierDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: Text(cancelText),
          onPressed: () {
            if (onCancel != null) {
              onCancel!();
            }
            Get.back();
          },
        ),
        TextButton(
          child: Text(
            confirmText,
            style: TextStyle(color: confirmTextColor),
          ),
          onPressed: () {
            if (onConfirm != null) {
              onConfirm!();
            }
            Get.back();
          },
        ),
      ],
    );
  }

  // 静态方法，方便直接调用
  static void show({
    required String title,
    required String content,
    String cancelText = '取消',
    String confirmText = '确定',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color confirmTextColor = Colors.red,
    bool barrierDismissible = true,
  }) {
    Get.dialog(
      DialogConfirm(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmTextColor: confirmTextColor,
      ),
      barrierDismissible: barrierDismissible,
    );
  }
} 