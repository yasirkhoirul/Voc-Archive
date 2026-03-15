import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:module_admin/presentations/pages/product_setting.dart';
import 'package:module_auth/presentation/bloc/auth_bloc.dart';
import 'package:module_auth/presentation/pages/auth_login.dart';
import 'package:module_core/module_core.dart';
import 'package:module_user/module_user.dart';
import 'package:voc_archive/router/route_name.dart';
import 'package:voc_archive/router/router_listener.dart';

class AppRouter {
  AppRouter._();
  static GoRouter routerConfig(BlocBase authBloc) {
    return GoRouter(
      initialLocation: RouteName.signIn.path,
      refreshListenable: RouterListener(authBloc),
      redirect: (context, state) {
        final isAuthenticated = authBloc.state is Authenticated;
        if (isAuthenticated) {
          return RouteName.adminproductssetting.path;
        }
        return null;
      },
      routes: [
        GoRoute(path: RouteName.signIn.path, builder: (context, state) => const AuthLogin(),),
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
