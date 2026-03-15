import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:module_admin/presentations/product_setting.dart';
import 'package:module_core/module_core.dart';
import 'package:module_user/module_user.dart';
import 'package:voc_archive/router/route_name.dart';

class AppRouter {
  AppRouter._();
  GoRouter routerConfig(BlocBase authBloc) {
    return GoRouter(
      initialLocation: RouteName.home.path,
      redirect: (context, state) {},
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainScaffold(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.home.path,
                  builder: (context, state) => const Home(),
                ),
              ],
            ),
          ],
        ),

        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainScaffoldAdmin(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.adminproductssetting.path,
                  builder: (context, state) => const ProductSetting(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
