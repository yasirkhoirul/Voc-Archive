import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:module_admin/presentations/pages/product_admin.dart';
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
        Logger().i('Current route: ${state.fullPath}');
        final isAuthenticated = authBloc.state is Authenticated;
        final generalPath = [
          RouteName.signIn.path,
          RouteName.signUp.path,
          RouteName.splash.path,
        ];
        // final adminPath = [
        //   RouteName.adminproducts.path,
        //   RouteName.adminproductssetting.path,
        // ];
        if (isAuthenticated && generalPath.contains(state.fullPath)) {
          return RouteName.adminproducts.path;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: RouteName.signIn.path,
          builder: (context, state) => const AuthLogin(),
        ),
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
                  path: RouteName.adminproducts.path,
                  builder: (context, state) => ProductAdmin(
                    onDetailTap: (uidProduct) {
                      context.goNamed(
                        RouteName.adminproductssetting.name,
                        pathParameters: {'id': uidProduct},
                      );
                    },
                  ),
                  routes: [
                    GoRoute(
                      path: RouteName.adminproductssetting.path,
                      name: RouteName.adminproductssetting.name,
                      builder: (context, state) {
                        final String? productId = state.pathParameters['id'];
                        return ProductSetting(productId: productId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
