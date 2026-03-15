import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voc_archive/dependency_injector.dart';
import 'package:voc_archive/router/app_router.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dependencyInitializer();
  runApp(MultiBlocProvider(providers: [

  ], child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: AppRouter.routerConfig());
  }
}
