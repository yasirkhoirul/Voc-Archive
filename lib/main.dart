import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_core/module_core.dart';
import 'package:module_admin/presentations/bloc/product_list_bloc.dart';
import 'package:module_admin/presentations/bloc/product_mutation_bloc.dart';
import 'package:module_admin/presentations/bloc/slider_mutation_bloc.dart';
import 'package:module_admin/presentations/bloc/display_mutation_bloc.dart';
import 'package:module_auth/presentation/bloc/auth_bloc.dart';
import 'package:voc_archive/dependency_injector.dart';
import 'package:voc_archive/firebase_options.dart';
import 'package:voc_archive/router/app_router.dart';
import 'package:voc_archive/theme/text.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await dependencyInitializer();
  runApp(MultiBlocProvider(providers: [
    BlocProvider<CurrencyCubit>(create: (_) => getIt<CurrencyCubit>(),),
    BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>(),),
    BlocProvider<ProductMutationBloc>(create: (_) => getIt<ProductMutationBloc>(),),
    BlocProvider<ProductListBloc>(create: (_) => getIt<ProductListBloc>(),),
    BlocProvider<SliderMutationBloc>(create: (_) => getIt<SliderMutationBloc>(),),
    BlocProvider<DisplayMutationBloc>(create: (_) => getIt<DisplayMutationBloc>(),),
  ], child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        textTheme: MyTheme.textStyle
      ),
      routerConfig: AppRouter.routerConfig(getIt<AuthBloc>()),);
  }
}
