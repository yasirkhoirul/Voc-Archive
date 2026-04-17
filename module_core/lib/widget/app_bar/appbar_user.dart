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
            AnimatedNavItem(
              title: 'Home',
              isActive: statefulNavigationShell.currentIndex == 0,
              onTap: () {
                statefulNavigationShell.goBranch(0);
              },
            ),
            const SizedBox(width: 24),
            AnimatedNavItem(
              title: 'Discount',
              isActive: statefulNavigationShell.currentIndex == 1,
              onTap: () {
                statefulNavigationShell.goBranch(1);
              },
            ),
            const SizedBox(width: 24),
            AnimatedNavItem(
              title: 'Catalog',
              isActive: statefulNavigationShell.currentIndex == 2,
              onTap: () {
                statefulNavigationShell.goBranch(2);
              },
            ),
            const SizedBox(width: 24),
            AnimatedNavItem(
              title: 'About',
              isActive: statefulNavigationShell.currentIndex == 3,
              onTap: () {
                statefulNavigationShell.goBranch(3);
              },
            ),
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
}

class AnimatedNavItem extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final bool isActive;

  const AnimatedNavItem({
    super.key,
    required this.title,
    required this.onTap,
    required this.isActive,
  });

  @override
  State<AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<AnimatedNavItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final showLine = widget.isActive || _isHovering;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0), // Jarak untuk garis
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutQuad,
                tween: Tween<double>(
                  begin: 0.0,
                  end: showLine ? 1.0 : 0.0,
                ),
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
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
