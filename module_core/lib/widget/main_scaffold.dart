import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:module_core/widget/app_bar/appbar_user.dart';
import 'package:module_core/widget/drawer/drawer.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool isAuthenticated;
  final bool isAuthLoading;
  final String? userName;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  const MainScaffold({
    super.key, 
    required this.navigationShell,
    required this.isAuthenticated,
    this.isAuthLoading = false,
    this.userName,
    required this.onLogin,
    required this.onLogout,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppbarUser(
        statefulNavigationShell: navigationShell,
        isAuthenticated: isAuthenticated,
        isAuthLoading: isAuthLoading,
        userName: userName,
        onLogin: onLogin,
        onLogout: onLogout,
      ),
      body: navigationShell,
    );
  }
}
