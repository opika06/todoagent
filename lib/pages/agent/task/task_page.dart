import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/task_model.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/dialog_confirm.dart';
import 'task_service.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取TaskController实例
    final controller = Get.put(TaskController());

    return Stack(
      children: [
        Column(
          children: [
            AppBar(
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Todo',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Agent',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                // 新建待办任务
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => Get.toNamed(Routes.TASK_EDIT),
                ),
              ],
            ),
            Expanded(
              child: Obx(() {
                final taskList = controller.taskService.taskList;

                if (taskList.isEmpty) {
                  // 空状态显示
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.view_list_rounded),
                          iconSize: 80,
                          color: Colors.blueAccent,
                          onPressed: () => Get.toNamed(Routes.TASK_EDIT),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '暂无待办',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '点击上方 "+" 按钮添加',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                } else {
                  // 显示任务列表
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: taskList.length,
                    itemBuilder: (context, index) {
                      final task = taskList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskCard(task: task),
                      );
                    },
                  );
                }
              }),
            ),
          ],
        ),
        // 浮动添加按钮
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            onPressed: () => Get.toNamed(Routes.TASK_EDIT),
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class TaskController extends GetxController {
  late final TaskService taskService;

  @override
  void onInit() {
    super.onInit();
    taskService = Get.put(TaskService());
  }
}

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => Get.toNamed(Routes.TASK_EDIT, arguments: task),
        onLongPress: () { // 添加长按事件
          Get.find<TaskService>().toggleTaskCompleted(task.id);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 任务内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration:
                            task.isCompleted.value
                                ? TextDecoration.lineThrough
                                : null,
                        color:
                            task.isCompleted.value ? Colors.grey : Colors.black,
                      ),
                    ),
                    if (task.detail.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          task.detail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            decoration:
                                task.isCompleted.value
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              // 删除按钮
              // IconButton(
              //   icon: const Icon(Icons.delete_outline, color: Colors.grey),
              //   onPressed: () {
              //     DialogConfirm.show(
              //       title: '删除任务',
              //       content: '确定要删除任务「${task.name}」吗？',
              //       onConfirm: () async {
              //         await Get.find<TaskService>().deleteTask(task.id);
              //         Get.back();
              //       },
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
