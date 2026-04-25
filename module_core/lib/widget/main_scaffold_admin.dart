import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:module_core/widget/app_bar/sidebar_admin.dart';
import 'package:module_core/widget/logo/voc_logo.dart';

class MainScaffoldAdmin extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final VoidCallback? onLogout;

  const MainScaffoldAdmin({
    super.key,
    required this.navigationShell,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade300, height: 1.0),
        ),
        title: const Row(
          children: [
            VocLogo(title: 'voc.archive', fontWeight: FontWeight.w900),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            offset: const Offset(0, 48),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  'Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                onLogout?.call();
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: isMobile
          ? Drawer(
              child: SidebarAdmin(
                currentIndex: navigationShell.currentIndex,
                onTap: (int index) {
                  navigationShell.goBranch(index);
                  if (Scaffold.of(context).isDrawerOpen) {
                    Navigator.pop(context);
                  }
                },
              ),
            )
          : null,
      body: isMobile
          ? navigationShell
          : Row(
              children: [
                SizedBox(
                  width: 250,
                  child: SidebarAdmin(
                    currentIndex: navigationShell.currentIndex,
                    onTap: (int index) {
                      navigationShell.goBranch(index);
                    },
                  ),
                ),
                // Vertical Divider
                Container(width: 1, color: Colors.grey.shade300),
                Expanded(child: navigationShell),
              ],
            ),
    );
  }
}
