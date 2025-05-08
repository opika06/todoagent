import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/gallery_image.dart';

class StorageService extends GetxService {
  // 存储图片列表
  final RxList<GalleryImage> images = <GalleryImage>[].obs;
  
  // 单例模式
  static StorageService get to => Get.find<StorageService>();
  
  // 应用数据目录
  late final Directory _appDir;
  late final Directory _imagesDir;
  
  // 图片索引文件名
  final String _indexFileName = 'gallery_index.json';
  
  // 初始化服务
  Future<StorageService> init() async {
    try {
      // 获取应用支持目录
      _appDir = await getApplicationSupportDirectory();
      // 创建图片存储目录
      _imagesDir = Directory(path.join(_appDir.path, 'gallery_images'));
      if (!await _imagesDir.exists()) {
        await _imagesDir.create(recursive: true);
      }
      debugPrint('应用存储目录: ${_appDir.path}');
      debugPrint('图片存储目录: ${_imagesDir.path}');
      
      // 加载已保存的图片
      await loadImages();
      
      return this;
    } catch (e) {
      debugPrint('初始化存储服务失败: $e');
      rethrow;
    }
  }
  
  // 保存图片到本地存储
  Future<GalleryImage?> saveImage(File sourceFile) async {
    try {
      // 生成唯一的文件名
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(sourceFile.path)}';
      final targetPath = path.join(_imagesDir.path, fileName);
      final targetFile = File(targetPath);
      
      // 复制文件到应用目录
      await sourceFile.copy(targetPath);
      
      // 创建图片对象
      final galleryImage = GalleryImage(
        id: fileName,
        file: targetFile,
        name: path.basename(sourceFile.path),
        addedDate: DateTime.now(),
        size: await targetFile.length(),
      );
      
      // 添加到列表
      images.add(galleryImage);
      
      // 保存索引
      await _saveIndex();
      
      return galleryImage;
    } catch (e) {
      debugPrint('保存图片失败: $e');
      return null;
    }
  }
  
  // 批量保存图片
  Future<List<GalleryImage>> saveImages(List<File> sourceFiles) async {
    final savedImages = <GalleryImage>[];
    
    for (final file in sourceFiles) {
      final image = await saveImage(file);
      if (image != null) {
        savedImages.add(image);
      }
    }
    
    return savedImages;
  }
  
  // 删除图片
  Future<bool> deleteImage(String id) async {
    try {
      // 找到要删除的图片
      final index = images.indexWhere((image) => image.id == id);
      if (index >= 0) {
        final image = images[index];
        
        // 删除文件
        if (await image.file.exists()) {
          await image.file.delete();
        }
        
        // 从列表中移除
        images.removeAt(index);
        
        // 更新索引
        await _saveIndex();
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('删除图片失败: $e');
      return false;
    }
  }
  
  // 清空所有图片
  Future<void> clearAll() async {
    try {
      // 删除所有图片文件
      for (final image in images) {
        if (await image.file.exists()) {
          await image.file.delete();
        }
      }
      
      // 清空列表
      images.clear();
      
      // 更新索引
      await _saveIndex();
    } catch (e) {
      debugPrint('清空图片失败: $e');
    }
  }
  
  // 加载已保存的图片
  Future<void> loadImages() async {
    try {
      final indexFile = File(path.join(_appDir.path, _indexFileName));
      
      // 检查索引文件是否存在
      if (!await indexFile.exists()) {
        debugPrint('索引文件不存在，没有图片可加载');
        return;
      }
      
      // 读取索引内容
      final jsonContent = await indexFile.readAsString();
      final List<dynamic> imagesList = jsonDecode(jsonContent);
      
      // 清空当前列表
      images.clear();
      
      // 加载每张图片
      for (final item in imagesList) {
        final filePath = item['filePath'];
        final file = File(filePath);
        
        // 检查文件是否存在
        if (await file.exists()) {
          final galleryImage = GalleryImage(
            id: item['id'],
            file: file,
            name: item['name'],
            addedDate: DateTime.parse(item['addedDate']),
            size: item['size'],
          );
          
          images.add(galleryImage);
        } else {
          debugPrint('图片文件不存在: $filePath');
        }
      }
      
      debugPrint('已加载 ${images.length} 张图片');
    } catch (e) {
      debugPrint('加载图片失败: $e');
    }
  }
  
  // 保存图片索引
  Future<void> _saveIndex() async {
    try {
      final indexFile = File(path.join(_appDir.path, _indexFileName));
      
      // 准备索引数据
      final List<Map<String, dynamic>> indexData = images.map((image) => {
        'id': image.id,
        'name': image.name,
        'filePath': image.file.path,
        'addedDate': image.addedDate.toIso8601String(),
        'size': image.size,
      }).toList();
      
      // 写入索引文件
      await indexFile.writeAsString(jsonEncode(indexData));
      
      debugPrint('已保存 ${images.length} 张图片索引');
    } catch (e) {
      debugPrint('保存图片索引失败: $e');
    }
  }
} 