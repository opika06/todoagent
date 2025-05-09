import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../../../models/staff_model.dart';

class StaffService extends GetxService {
  final RxList<Staff> staffList = <Staff>[].obs;
  final uuid = Uuid();
  
  // 应用数据目录
  late final Directory _appDir;
  
  // 干员数据文件名
  final String _staffFileName = 'staff_data.json';

  // 初始化服务
  Future<StaffService> init() async {
    try {
      // 获取应用支持目录
      _appDir = await getApplicationSupportDirectory();
      debugPrint('应用存储目录: ${_appDir.path}');
      
      // 加载已保存的干员数据
      await loadStaffData();
      
      return this;
    } catch (e) {
      debugPrint('初始化干员服务失败: $e');
      rethrow;
    }
  }

  // 添加干员
  Future<void> addStaff(String name, String detail, List<String> tags) async {
    final staff = Staff(
      id: uuid.v4(),
      name: name,
      detail: detail,
      tags: tags,
    );
    staffList.add(staff);
    // 保存到本地存储
    await saveStaffData();
  }

  // 删除干员
  Future<void> deleteStaff(String id) async {
    staffList.removeWhere((staff) => staff.id == id);
    // 保存到本地存储
    await saveStaffData();
  }

  // 更新干员
  Future<void> updateStaff(String id, String name, String detail, List<String> tags) async {
    final index = staffList.indexWhere((staff) => staff.id == id);
    if (index != -1) {
      staffList[index] = Staff(
        id: id,
        name: name,
        detail: detail,
        tags: tags,
      );
      // 保存到本地存储
      await saveStaffData();
    }
  }

  // 加载干员数据
  Future<void> loadStaffData() async {
    try {
      final file = File(path.join(_appDir.path, _staffFileName));
      
      // 检查文件是否存在
      if (!await file.exists()) {
        debugPrint('干员数据文件不存在，将创建新文件');
        return;
      }
      
      // 读取文件内容
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      // 清空当前列表
      staffList.clear();
      
      // 转换为Staff对象并添加到列表
      for (final json in jsonList) {
        final staff = Staff.fromJson(json);
        staffList.add(staff);
      }
      
      debugPrint('已加载 ${staffList.length} 个干员数据');
    } catch (e) {
      debugPrint('加载干员数据失败: $e');
    }
  }

  // 保存干员数据
  Future<void> saveStaffData() async {
    try {
      final file = File(path.join(_appDir.path, _staffFileName));
      
      // 将干员列表转换为JSON
      final List<Map<String, dynamic>> jsonList = staffList.map((staff) => staff.toJson()).toList();
      
      // 写入文件
      await file.writeAsString(jsonEncode(jsonList));
      
      debugPrint('已保存 ${staffList.length} 个干员数据');
    } catch (e) {
      debugPrint('保存干员数据失败: $e');
    }
  }
} 