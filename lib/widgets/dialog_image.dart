import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/gallery_image.dart';
import '../services/gallery_service.dart';
import 'dialog_confirm.dart';

class DialogImage {
  static void show(GalleryImage image) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图片内容
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: Get.height * 0.8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Stack(
                  children: [
                    // 可交互图片
                    InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        child: Image.file(
                          image.file,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    
                    // 删除按钮
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            // 先关闭图片对话框
                            Get.back();
                            // 显示确认对话框
                            DialogConfirm.show(
                              title: '删除图片',
                              content: '确定要删除这张图片吗？',
                              onConfirm: () => Get.find<GalleryService>().deleteImage(image.id),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(128),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
