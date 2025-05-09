import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'agent/gallery/gallery_page.dart';
import '../pages/demo_page.dart';
import 'agent/staff/staff_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final allowPop = await controller.onWillPop();
          if (allowPop && context.mounted) {
            Navigator.of(context).maybePop(); // TODO 为什么不用 GetX 路由
          }
        }
      },
      child: Scaffold(
        body: Obx(
          () => IndexedStack(
            index: controller.currentIndex.value,
            children: const [DemoPage(), StaffPage(), GalleryPage()],
          ),
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.abc), label: '示例'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: '干员'), 
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '图库'),
            ],
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: false,
            iconSize: 24,
            selectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final List<int> _history = [0];

  void changePage(int index) {
    if (index != currentIndex.value) {
      _history.add(index);
      currentIndex.value = index;
    }
  }

  Future<bool> onWillPop() async {
    if (_history.length <= 1) {
      return true; // 允许退出应用
    } else {
      // 移除当前页面
      _history.removeLast();
      // 回到历史上一页
      currentIndex.value = _history.last;
      return false; // 不允许退出应用，而是返回上一个选项卡
    }
  }
}
