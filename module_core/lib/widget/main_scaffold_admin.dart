import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:module_core/widget/app_bar/sidebar_admin.dart';

class MainScaffoldAdmin extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainScaffoldAdmin({super.key, required this.navigationShell});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: SidebarAdmin(
              onTap: (int index) {
                navigationShell.goBranch(index);
              },
            ),
          ),
          Expanded(flex: 4, child: navigationShell),
        ],
      ),
    );
  }
}
