import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_auth/presentation/bloc/auth_bloc.dart';
import 'package:voc_archive/dependency_injector.dart';
import 'package:voc_archive/firebase_options.dart';
import 'package:voc_archive/router/app_router.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await dependencyInitializer();
  runApp(MultiBlocProvider(providers: [
    BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>(),)
  ], child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: AppRouter.routerConfig(getIt<AuthBloc>()),);
  }
}
