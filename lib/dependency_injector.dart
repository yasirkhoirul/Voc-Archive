
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:module_auth/data/datasource/auth_datasource.dart';
import 'package:module_auth/data/repositories/auth_repository_impl.dart';
import 'package:module_auth/domain/repositories/auth_repository.dart';
import 'package:module_auth/domain/usecases/get_auth_state_usecase.dart';
import 'package:module_auth/domain/usecases/register_usecase.dart';
import 'package:module_auth/domain/usecases/sign_in_usecase.dart';
import 'package:module_auth/domain/usecases/sign_out_usecase.dart';
import 'package:module_auth/presentation/bloc/auth_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> dependencyInitializer() async {

  //general
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance,);

  //datasources
  getIt.registerLazySingleton<AuthDatasource>(() => AuthDatasourceImpl(getIt()),);

  //repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()),);

  //usecases
  getIt.registerLazySingleton(() => SignInUseCase(getIt()),);
  getIt.registerLazySingleton(() => SignOutUseCase(getIt()),);
  getIt.registerLazySingleton(() => GetAuthStateUseCase(getIt()),);
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()),);

  //blocs
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt(),getIt(),getIt(),getIt()),);
}