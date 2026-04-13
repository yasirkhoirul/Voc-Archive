import 'package:flutter/material.dart';

import '../../utils/app_assets.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 16.0, bottom: 20.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(AppAssets.logo, width: 40, height: 40, fit: BoxFit.cover),
                ),
                const SizedBox(width: 8),
                const Text(
                  'voc.archive',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(title: 'Home', onTap: () {}),
          _buildDrawerItem(title: 'Catalog', onTap: () {}),
          _buildDrawerItem(title: 'Chrome hearts', onTap: () {}),
          _buildDrawerItem(title: 'Japanese brand', onTap: () {}),
          _buildDrawerItem(title: 'Racing', onTap: () {}),
          _buildDrawerItem(title: 'Sold', onTap: () {}),
          _buildDrawerItem(title: 'Discount', onTap: () {}),
          _buildDrawerItem(title: 'About', onTap: () {}),
          _buildDrawerItem(title: 'Contact', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );
  }
}

