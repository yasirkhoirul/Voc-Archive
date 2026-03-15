import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffoldAdmin extends StatelessWidget{
  final StatefulNavigationShell navigationShell;
  const MainScaffoldAdmin({super.key, required this.navigationShell});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
    );
  }
}