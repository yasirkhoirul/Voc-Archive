import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/search_notifier.dart';
import '../logo/voc_logo.dart';

class AppbarUser extends StatelessWidget implements PreferredSizeWidget {
  final StatefulNavigationShell statefulNavigationShell;
  final bool isAuthenticated;
  final bool isAuthLoading;
  final String? userName;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  const AppbarUser({
    super.key, 
    required this.statefulNavigationShell,
    required this.isAuthenticated,
    this.isAuthLoading = false,
    this.userName,
    required this.onLogin,
    required this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 900;
    if (!isSmallScreen) {
      return Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const VocLogo(),
            const Spacer(),
            _buildNavItem(context, 'Home', () {
              statefulNavigationShell.goBranch(0);
            }),
            const SizedBox(width: 24),
            _buildNavItem(context, 'Discount', () {
              statefulNavigationShell.goBranch(1);
            }),
            const SizedBox(width: 24),
            _buildNavItem(context, 'Catalog', () {
              statefulNavigationShell.goBranch(2);
            }),
            const SizedBox(width: 24),
            _buildNavItem(context, 'About', () {
              statefulNavigationShell.goBranch(3);
            }),
            const SizedBox(width: 24),
            if (statefulNavigationShell.currentIndex == 1 || statefulNavigationShell.currentIndex == 2)
              SizedBox(
                width: 250,
                height: 36,
                child: TextField(
                  onSubmitted: (value) {
                    searchNotifier.value = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search brand / description',
                    hintStyle: const TextStyle(fontSize: 14),
                    suffixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 24),
            if (isAuthenticated)
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined),
                onPressed: () {
                  context.pushNamed('history');
                },
              ),
            const SizedBox(width: 16),
            _buildUserIcon(context),
          ],
        ),
      );
    }
    return SafeArea(
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            const Expanded(child: Center(child: VocLogo())),
            if (isAuthenticated)
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined),
                onPressed: () {
                  context.pushNamed('history');
                },
              ),
            _buildUserIcon(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserIcon(BuildContext context) {
    if (isAuthLoading) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (!isAuthenticated) {
      return IconButton(
        icon: const Icon(Icons.login),
        onPressed: onLogin,
        tooltip: 'Login',
      );
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.person_outline),
      offset: const Offset(0, 48),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            userName ?? 'User',
            style: const TextStyle(
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
          onLogout();
        }
      },
    );
  }

  Widget _buildNavItem(BuildContext context, String title, VoidCallback ontap) {
    return InkWell(
      onTap: ontap,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ItemAppBar extends StatelessWidget {
  final String title;
  const ItemAppBar({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Text(title, style: Theme.of(context).textTheme.displayLarge)],
    );
  }
}
