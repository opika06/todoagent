import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/gallery_image.dart';
import '../widgets/dialog_image.dart';
import 'storage_service.dart';

class GalleryService extends GetxController {
  // 图片选择器
  final ImagePicker _picker = ImagePicker();
  
  // 存储服务
  final StorageService _storageService = Get.find<StorageService>();

  // 获取图片列表的引用
  RxList<GalleryImage> get images => _storageService.images;
  
  // 单例模式
  static GalleryService get to => Get.find<GalleryService>();
  
  // 图片导入
  Future<void> pickImage() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      
      if (pickedFiles.isNotEmpty) {
        // 显示加载指示器
        final loadingDialog = Get.dialog(
          const Center(
            child: CircularProgressIndicator(),
          ),
          barrierDismissible: false,
        );
        
        // 转换XFile为File
        final files = pickedFiles.map((xFile) => File(xFile.path)).toList();
        
        // 保存图片到本地存储
        final savedImages = await _storageService.saveImages(files);
        
        // 关闭加载指示器
        Get.back();
        
        Get.snackbar(
          '成功', 
          '已导入 ${savedImages.length} 张图片',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('选择多张图片失败: $e');
      Get.snackbar('错误', '选择图片失败',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 获取随机图片
  GalleryImage? getRandomImage() {
    if (images.isEmpty) return null;
    
    final random = Random();
    final index = random.nextInt(images.length);
    return images[index];
  }
  
  // 显示随机图片
  void showRandomImage() {
    final randomImage = getRandomImage();
    if (randomImage != null) {
      DialogImage.show(randomImage);
    } else {
      Get.snackbar(
        '提示', 
        '没有可显示的图片，请先导入图片',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // 删除图片
  Future<void> deleteImage(String id) async {
    await _storageService.deleteImage(id);
  }
  
  // 清空所有图片
  Future<void> clearAll() async {
    await _storageService.clearAll();
    Get.snackbar('成功', '已清空所有图片',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1));
  }
} 