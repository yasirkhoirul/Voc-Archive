import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_admin/presentations/bloc/settings_bloc.dart';
import 'package:module_admin/presentations/bloc/brand_bloc.dart';
import 'package:module_core/module_core.dart';
import 'package:module_admin/presentations/bloc/product_list_bloc.dart';
import 'package:module_admin/presentations/bloc/product_mutation_bloc.dart';
import 'package:module_admin/presentations/bloc/slider_mutation_bloc.dart';
import 'package:module_admin/presentations/bloc/display_mutation_bloc.dart';
import 'package:module_auth/presentation/bloc/auth_bloc.dart';
import 'package:module_user/presentation/cubit/display_cubit.dart';
import 'package:module_user/presentation/cubit/home_cubit.dart';
import 'package:module_user/presentation/bloc/catalog_bloc.dart';
import 'package:module_user/presentation/bloc/cart_bloc.dart';
import 'package:module_user/presentation/cubit/catalog_discount_cubit.dart';
import 'package:module_user/presentation/bloc/checkout_bloc.dart';
import 'package:module_user/presentation/cubit/history_user_cubit.dart';
import 'package:module_admin/presentations/cubit/history_cubit.dart';
import 'package:voc_archive/dependency_injector.dart';
import 'package:voc_archive/firebase_options.dart';
import 'package:voc_archive/router/app_router.dart';
import 'package:voc_archive/theme/color.dart';
import 'package:voc_archive/theme/text.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dependencyInitializer();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<CurrencyCubit>(create: (_) => getIt<CurrencyCubit>()),
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<ProductMutationBloc>(
          create: (_) => getIt<ProductMutationBloc>(),
        ),
        BlocProvider<ProductListBloc>(create: (_) => getIt<ProductListBloc>()),
        BlocProvider<SliderMutationBloc>(
          create: (_) => getIt<SliderMutationBloc>(),
        ),
        BlocProvider<DisplayMutationBloc>(
          create: (_) => getIt<DisplayMutationBloc>(),
        ),
        BlocProvider<HomeCubit>(
          create: (_) => getIt<HomeCubit>()..fetchSliders(),
        ),
        BlocProvider<DisplayCubit>(
          create: (_) => getIt<DisplayCubit>()..fetchDisplaySection(),
        ),
        BlocProvider<CatalogBloc>(
          create: (_) => getIt<CatalogBloc>()..add(FetchCatalogProducts()),
        ),
        BlocProvider<CatalogDiscountCubit>(
          create: (_) => getIt<CatalogDiscountCubit>()..fetchDiscountProducts(),
        ),
        BlocProvider<SettingsBloc>(create: (_) => getIt<SettingsBloc>()),
        BlocProvider<BrandBloc>(create: (_) => getIt<BrandBloc>()),
        BlocProvider<CartBloc>(create: (_) => getIt<CartBloc>()),
        BlocProvider<CheckoutBloc>(
          create: (_) => getIt<CheckoutBloc>()..add(LoadShippingRatesEvent()),
        ),
        BlocProvider<HistoryUserCubit>(
          create: (_) => getIt<HistoryUserCubit>(),
        ),
        BlocProvider<HistoryCubit>(create: (_) => getIt<HistoryCubit>()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        textTheme: MyTheme.textStyle,
        colorScheme: AppColors.lightColorScheme,
      ),
      builder: (context, child) {
        final isMobile = MediaQuery.of(context).size.width < 900;
        final responsiveTextTheme = MyTheme.getTextTheme(isMobile);
        return Theme(
          data: Theme.of(context).copyWith(textTheme: responsiveTextTheme),
          child: child!,
        );
      },
      routerConfig: AppRouter.routerConfig(getIt<AuthBloc>()),
    );
  }
}
