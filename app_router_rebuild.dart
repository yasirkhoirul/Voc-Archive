import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/web.dart';

// Admin imports
import 'package:module_admin/presentations/pages/admin_settings_page.dart';
import 'package:module_admin/presentations/pages/admin_brand_page.dart';
import 'package:module_admin/presentations/pages/product_admin.dart';
import 'package:module_admin/presentations/pages/product_setting.dart';
import 'package:module_admin/presentations/pages/admin_soldout_page.dart';
import 'package:module_admin/presentations/pages/admin_slider_page.dart';
import 'package:module_admin/presentations/pages/admin_display_page.dart';
import 'package:module_admin/presentations/pages/history_admin_page.dart';

// Auth imports
import 'package:module_auth/presentation/bloc/auth_bloc.dart';
import 'package:module_auth/presentation/pages/auth_login.dart';
import 'package:module_auth/presentation/pages/auth_signup.dart';

// Core imports
import 'package:module_core/module_core.dart';

// User imports
import 'package:module_user/module_user.dart';
import 'package:module_user/presentation/pages/soldout_user.dart';
import 'package:module_user/presentation/pages/about_us.dart';
import 'package:module_user/presentation/pages/catalog.dart';
import 'package:module_user/presentation/pages/catalog_discount.dart';
import 'package:module_user/presentation/pages/cart.dart';
import 'package:module_user/presentation/pages/checkout/checkout.dart';
import 'package:module_user/presentation/pages/detail_product.dart';
import 'package:module_user/presentation/pages/history_user.dart';

// Router imports
import 'package:voc_archive/router/route_name.dart';
import 'package:voc_archive/router/router_listener.dart';