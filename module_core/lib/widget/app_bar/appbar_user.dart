import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../logo/voc_logo.dart';

class AppbarUser extends StatelessWidget implements PreferredSizeWidget {
  final StatefulNavigationShell statefulNavigationShell;
  const AppbarUser({super.key, required this.statefulNavigationShell});

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
            _buildNavItem(context, 'Discount', () {}),
            const SizedBox(width: 24),
            _buildNavItem(context, 'Catalog', () {
              statefulNavigationShell.goBranch(1);
            }),
            const SizedBox(width: 24),
            _buildNavItem(context, 'About', () {
              statefulNavigationShell.goBranch(2);
            }),
            const SizedBox(width: 24),
            SizedBox(
              width: 250,
              height: 36,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search something?',
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
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined),
              onPressed: () {
                context.pushNamed('history');
              },
            ),
            const SizedBox(width: 16),
            const Icon(Icons.person_outline),
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
            const Icon(Icons.person_outline),
          ],
        ),
      ),
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
