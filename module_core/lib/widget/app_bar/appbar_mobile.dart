import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../logo/voc_logo.dart';

class CustomDrawer extends StatelessWidget {
  final StatefulNavigationShell statefulNavigationShell;
  final bool isAuthenticated;
  final bool isAuthLoading;
  final String? userName;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  const CustomDrawer({
    super.key,
    required this.statefulNavigationShell,
    required this.isAuthenticated,
    this.isAuthLoading = false,
    this.userName,
    required this.onLogin,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const VocLogo(),
                const SizedBox(height: 16),
                Text(
                  "Voc Archive",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerNavItem(context, 'Home', Icons.home, () {
            Navigator.pop(context);
            statefulNavigationShell.goBranch(0);
          }),
          _buildDrawerNavItem(context, 'Discount', Icons.local_offer, () {
            Navigator.pop(context);
            statefulNavigationShell.goBranch(1);
          }),
          _buildDrawerNavItem(context, 'Catalog', Icons.shopping_bag, () {
            Navigator.pop(context);
            statefulNavigationShell.goBranch(2);
          }),
          _buildDrawerNavItem(context, 'About', Icons.info, () {
            Navigator.pop(context);
            statefulNavigationShell.goBranch(3);
          }),
          _buildDrawerNavItem(
            context,
            'Sold Out',
            Icons.remove_shopping_cart,
            () {
              Navigator.pop(context);
              statefulNavigationShell.goBranch(4);
            },
          ),
          const Divider(),
          if (isAuthenticated)
            _buildDrawerNavItem(
              context,
              'History',
              Icons.receipt_long_outlined,
              () {
                Navigator.pop(context);
                context.pushNamed('history');
              },
            ),
          const Divider(),
          _buildAuthButton(context),
        ],
      ),
    );
  }

  Widget _buildDrawerNavItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(title: Text(title), onTap: onTap);
  }

  Widget _buildAuthButton(BuildContext context) {
    if (isAuthLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!isAuthenticated) {
      return ListTile(
        leading: const Icon(Icons.login),
        title: const Text('Login'),
        onTap: () {
          Navigator.pop(context);
          onLogin();
        },
      );
    }

    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Logout'),
      onTap: () {
        Navigator.pop(context);
        onLogout();
      },
    );
  }
}
