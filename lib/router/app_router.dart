import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/web.dart';
import 'package:module_admin/presentations/pages/admin_settings_page.dart';
import 'package:module_admin/presentations/pages/admin_brand_page.dart';
import 'package:module_admin/presentations/pages/product_admin.dart';
import 'package:module_admin/presentations/pages/product_setting.dart';
import 'package:module_admin/presentations/pages/admin_soldout_page.dart';
import 'package:module_admin/presentations/pages/admin_slider_page.dart';
import 'package:module_admin/presentations/pages/admin_display_page.dart';
import 'package:module_admin/presentations/pages/history_admin_page.dart';
import 'package:module_auth/presentation/bloc/auth_bloc.dart';
import 'package:module_auth/presentation/pages/auth_login.dart';
import 'package:module_auth/presentation/pages/auth_signup.dart';
import 'package:module_core/module_core.dart';
import 'package:module_user/module_user.dart';
import 'package:module_user/presentation/pages/about_us.dart';
import 'package:module_user/presentation/pages/catalog_sold_out.dart';
import 'package:module_user/presentation/pages/catalog.dart';
import 'package:module_user/presentation/pages/catalog_discount.dart';
import 'package:module_user/presentation/pages/cart.dart';
import 'package:module_user/presentation/pages/checkout/checkout.dart';
import 'package:module_user/presentation/pages/detail_product.dart';
import 'package:module_user/presentation/pages/history_user.dart';
import 'package:voc_archive/router/route_name.dart';
import 'package:voc_archive/router/router_listener.dart';

class AppRouter {
  AppRouter._();
  static GoRouter routerConfig(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: RouteName.home.path,
      refreshListenable: RouterListener(authBloc),
      redirect: (context, state) {
        final authState = authBloc.state;

        final generalPath = [
          RouteName.home.path,
          RouteName.discount.path,
          RouteName.about.path,
          RouteName.soldout.path,
          RouteName.product.path,
          RouteName.productDetail.path,
        ];

        final authPath = [
          RouteName.signIn.path,
          RouteName.signUp.path,
          RouteName.splash.path,
        ];

        final userPath = [
          RouteName.cart.path,
          RouteName.checkout.path,
          RouteName.history.path,
        ];

        final adminPath = [
          RouteName.adminproducts.path,
          RouteName.adminproductssetting.path,
          RouteName.adminsoldout.path,
          RouteName.adminsliders.path,
          RouteName.admindisplays.path,
          RouteName.settings.path,
          RouteName.adminbrands.path,
          RouteName.adminhistory.path,
        ];
        // Cek jika butuh login
        final isGoingToSecurePath =
            userPath.contains(state.fullPath) ||
            adminPath.contains(state.fullPath);

        if (authState is! Authenticated) {
          if (isGoingToSecurePath) {
            return RouteName.signIn.path;
          }
          return null; // Boleh ke general path
        }

        // Handle User vs Admin
        final role = authState.user.role;
        Logger().i("role: $role, trying to access: ${state.fullPath}");

        if (role == 'admin') {
          // Admin tidak usah lihat auth page maupun general page / user cart,
          // lempar ke admin area
          if (authPath.contains(state.fullPath) ||
              generalPath.contains(state.fullPath) ||
              userPath.contains(state.fullPath)) {
            return RouteName.adminproducts.path;
          }
          return null; // Bebas akses adminPath
        } else {
          // User Role
          if (adminPath.contains(state.fullPath)) {
            return RouteName.home.path; // Tidak boleh akses dashboard admin
          }
          // Biarkan halaman Auth tertangani oleh listener di dalamnya agar bisa melakukan context.pop()
          // ke halaman sebelumnya (misal Catalog) tanpa harus force redirect ke "/"
          return null; // Bebas akses general dan userPath
        }
      },
      routes: [
        GoRoute(
          path: RouteName.cart.path,
          name: RouteName.cart.name,
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          path: RouteName.checkout.path,
          name: RouteName.checkout.name,
          builder: (context, state) => const CheckoutPage(),
        ),
        GoRoute(
          path: RouteName.history.path,
          name: RouteName.history.name,
          builder: (context, state) => const HistoryUserPage(),
        ),
        GoRoute(
          path: RouteName.signIn.path,
          builder: (context, state) => const AuthLogin(),
        ),
        GoRoute(
          path: RouteName.signUp.path,
          builder: (context, state) => const AuthSignup(),
        ),
        StatefulShellRoute(
          navigatorContainerBuilder: (context, navigationShell, children) {
            return children[navigationShell.currentIndex];
          },
          builder: (context, state, navigationShell) {
            return BlocBuilder<AuthBloc, AuthState>(
              bloc: authBloc,
              builder: (context, authState) {
                bool isAuthenticated = authState is Authenticated;
                bool isAuthLoading = authState is AuthLoading;
                String? userName;
                if (authState is Authenticated) {
                  userName = authState.user.displayName ?? authState.user.email;
                }
                return MainScaffold(
                  navigationShell: navigationShell,
                  isAuthenticated: isAuthenticated,
                  isAuthLoading: isAuthLoading,
                  userName: userName,
                  onLogin: () => context.push(RouteName.signIn.path),
                  onLogout: () {
                    authBloc.add(AuthLogoutEvent());
                  },
                );
              },
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.home.path,
                  name: "home",
                  builder: (context, state) => const Home(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.discount.path,
                  name: RouteName.discount.name,
                  builder: (context, state) => const CatalogDiscount(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.product.path,
                  builder: (context, state) => const Catalog(),
                  routes: [
                    GoRoute(
                      name: RouteName.productDetail.name,
                      path: ':id',
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return DetailProduct(uid: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.about.path,
                  builder: (context, state) => const AboutUs(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.soldout.path,
                  builder: (context, state) => const CatalogSoldOut(),
                ),
              ],
            ),
          ],
        ),

        StatefulShellRoute(
          navigatorContainerBuilder: (context, navigationShell, children) {
            return children[navigationShell.currentIndex];
          },
          builder: (context, state, navigationShell) =>
              MainScaffoldAdmin(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.adminproducts.path,
                  builder: (context, state) => ProductAdmin(
                    onDetailTap: (uidProduct) {
                      if (uidProduct != null) {
                        context.goNamed(
                          RouteName.adminproductssetting.name,
                          pathParameters: {'id': uidProduct},
                        );
                      } else {
                        context.goNamed(
                          RouteName.adminproductssetting.name,
                          pathParameters: {'id': 'new'},
                        );
                      }
                    },
                  ),
                  routes: [
                    GoRoute(
                      path: ':id',
                      name: RouteName.adminproductssetting.name,
                      builder: (context, state) {
                        final String? rawId = state.pathParameters['id'];
                        final String? productId = rawId == 'new' ? null : rawId;
                        return ProductSetting(productId: productId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.adminsoldout.path,
                  builder: (context, state) => AdminSoldoutPage(
                    onDetailTap: (uidProduct) {
                      if (uidProduct != null) {
                        context.goNamed(
                          RouteName.adminproductssetting.name,
                          pathParameters: {'id': uidProduct},
                        );
                      } else {
                        context.goNamed(
                          RouteName.adminproductssetting.name,
                          pathParameters: {'id': 'new'},
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.adminsliders.path,
                  builder: (context, state) => const AdminSliderPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.admindisplays.path,
                  builder: (context, state) => const AdminDisplayPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.settings.path,
                  builder: (context, state) => const AdminSettingsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.adminbrands.path,
                  builder: (context, state) => const AdminBrandPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteName.adminhistory.path,
                  builder: (context, state) => const HistoryAdminPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
