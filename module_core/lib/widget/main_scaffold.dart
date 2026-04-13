import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:module_core/widget/app_bar/appbar_user.dart';
import 'package:module_core/widget/drawer/drawer.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainScaffold({super.key, required this.navigationShell});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppbarUser(statefulNavigationShell: navigationShell),
      body: navigationShell,
    );
  }
}
