import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'home_screen.dart';
import 'users_list_screen.dart';

class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MainNavigationController controller = Get.put(MainNavigationController());
    final AuthController authController = Get.find<AuthController>();

    return Obx(() {
      final canManageUsers = authController.canManageUsers;

      // If user does not have user management privileges (e.g. CO role), show only HomeScreen
      if (!canManageUsers) {
        return const HomeScreen();
      }

      final List<Widget> pages = const [
        HomeScreen(),
        UsersListScreen(),
      ];

      return Scaffold(
        body: Obx(() {
          return IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          );
        }),
        bottomNavigationBar: Obx(() {
          return NavigationBar(
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: (index) {
              controller.changeIndex(index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline_rounded),
                selectedIcon: Icon(Icons.people_rounded),
                label: 'Users',
              ),
            ],
          );
        }),
      );
    });
  }
}

