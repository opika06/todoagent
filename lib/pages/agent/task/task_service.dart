import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'dart:math'; // 导入dart:math用于随机数
import '../../../models/task_model.dart';
import '../staff/staff_service.dart'; // 导入StaffService
import '../gallery/gallery_service.dart'; // 导入GalleryService
import '../../../widgets/dialog_image.dart'; // 导入DialogImage
import '../../../models/gallery_image.dart'; // 导入GalleryImage

class TaskService extends GetxService {
  // 获取StaffService和GalleryService实例
  final StaffService _staffService = Get.find<StaffService>();
  final GalleryService _galleryService = Get.find<GalleryService>();

  final RxList<Task> taskList = <Task>[].obs;
  final uuid = Uuid();
  
  // 应用数据目录
  late final Directory _appDir;
  
  // 任务数据文件名
  final String _taskFileName = 'task_data.json';

  // 初始化服务
  Future<TaskService> init() async {
    try {
      // 获取应用支持目录
      _appDir = await getApplicationSupportDirectory();
      debugPrint('应用存储目录: ${_appDir.path}');
      
      // 加载已保存的任务数据
      await loadTaskData();
      
      return this;
    } catch (e) {
      debugPrint('初始化任务服务失败: $e');
      rethrow;
    }
  }

  // 添加任务
  Future<void> addTask(String name, String detail, String staffId) async {
    final task = Task(
      id: uuid.v4(),
      name: name,
      detail: detail,
      staffId: staffId,
    );
    taskList.add(task);
    // 保存到本地存储
    await saveTaskData();
  }

  // 删除任务
  Future<void> deleteTask(String id) async {
    taskList.removeWhere((task) => task.id == id);
    // 保存到本地存储
    await saveTaskData();
  }

  // 更新任务
  Future<void> updateTask(String id, String name, String detail, String staffId) async {
    final index = taskList.indexWhere((task) => task.id == id);
    if (index != -1) {
      final currentTask = taskList[index];
      taskList[index] = Task(
        id: id,
        name: name,
        detail: detail,
        staffId: staffId,
        isCompleted: currentTask.isCompleted.value,
      );
      // 保存到本地存储
      await saveTaskData();
    }
  }

  // 切换任务完成状态
  Future<void> toggleTaskCompleted(String id) async {
    final index = taskList.indexWhere((task) => task.id == id);
    if (index != -1) {
      final currentTask = taskList[index];
      // 切换完成状态
      currentTask.isCompleted.toggle();

      // 如果任务已完成，显示关联干员的随机图片
      if (currentTask.isCompleted.value) {
        final staff = _staffService.getStaffById(currentTask.staffId);
        if (staff != null && staff.imageIds.isNotEmpty) {
          // 随机选择一个图片ID
          final random = Random();
          final randomImageId = staff.imageIds[random.nextInt(staff.imageIds.length)];

          // 获取图片并显示
          final image = _galleryService.getImageById(randomImageId);
          if (image != null) {
            DialogImage.show(image);
          }
        }
      }

      // 保存到本地存储
      await saveTaskData();
    }
  }

  // 加载任务数据
  Future<void> loadTaskData() async {
    try {
      final file = File(path.join(_appDir.path, _taskFileName));
      
      // 检查文件是否存在
      if (!await file.exists()) {
        debugPrint('任务数据文件不存在，将创建新文件');
        return;
      }
      
      // 读取文件内容
      final jsonString = await file.readAsString();
      if (jsonString.isEmpty) {
        debugPrint('任务数据文件为空');
        return;
      }
      
      // 解析JSON数据
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // 清空当前列表并添加解析后的数据
      taskList.clear();
      for (var item in jsonList) {
        taskList.add(Task.fromJson(item));
      }
      
      debugPrint('成功加载 ${taskList.length} 个任务');
    } catch (e) {
      debugPrint('加载任务数据失败: $e');
    }
  }
  
  // 保存任务数据
  Future<void> saveTaskData() async {
    try {
      final file = File(path.join(_appDir.path, _taskFileName));
      
      // 确保目录存在
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      
      // 将任务列表转换为JSON并保存
      final jsonList = taskList.map((task) => task.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      
      debugPrint('成功保存 ${taskList.length} 个任务');
    } catch (e) {
      debugPrint('保存任务数据失败: $e');
    }
  }
  
  // 根据ID获取任务
  Task? getTaskById(String id) {
    return taskList.firstWhereOrNull((task) => task.id == id);
  }
}