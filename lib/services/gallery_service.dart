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
  
  // 选中的图片ID集合
  final RxSet<String> selectedImageIds = <String>{}.obs;
  
  // 是否处于选择模式
  final RxBool isSelectMode = false.obs;
  
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
  
  // 切换图片喜欢状态
  void toggleImageLike(String id) {
    final index = images.indexWhere((image) => image.id == id);
    if (index >= 0) {
      images[index].toggleLike();
      // 保存喜欢状态到持久化存储
      _storageService.saveIndex();
    }
  }
  
  // 切换图片选中状态
  void toggleImageSelection(String id) {
    if (selectedImageIds.contains(id)) {
      selectedImageIds.remove(id);
    } else {
      selectedImageIds.add(id);
    }
    
    // 如果没有选中的图片，退出选择模式
    if (selectedImageIds.isEmpty) {
      isSelectMode.value = false;
    } else if (!isSelectMode.value) {
      // 如果不是选择模式，进入选择模式
      isSelectMode.value = true;
    }
  }
  
  // 选择所有图片
  void selectAll() {
    selectedImageIds.clear();
    for (var image in images) {
      selectedImageIds.add(image.id);
    }
  }
  
  // 取消选择所有图片
  void clearSelection() {
    selectedImageIds.clear();
    isSelectMode.value = false;
  }
  
  // 删除选中的图片
  Future<void> deleteSelected() async {
    // 复制选中的ID列表，因为在删除过程中会修改原列表
    final idsToDelete = selectedImageIds.toList();
    
    // 显示加载指示器
    final loadingDialog = Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
    
    int successCount = 0;
    for (final id in idsToDelete) {
      final success = await _storageService.deleteImage(id);
      if (success) {
        successCount++;
      }
    }
    
    // 关闭加载指示器
    Get.back();
    
    // 清空选择
    clearSelection();
    
    // 显示结果
    Get.snackbar(
      '删除完成', 
      '已删除 $successCount 张图片',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
} 