
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Module Auth
import 'package:module_auth/data/datasource/auth_datasource.dart';
import 'package:module_auth/data/repositories/auth_repository_impl.dart';
import 'package:module_auth/domain/repositories/auth_repository.dart';
import 'package:module_auth/domain/usecases/get_auth_state_usecase.dart';
import 'package:module_auth/domain/usecases/register_usecase.dart';
import 'package:module_auth/domain/usecases/sign_in_usecase.dart';
import 'package:module_auth/domain/usecases/sign_out_usecase.dart';
import 'package:module_auth/presentation/bloc/auth_bloc.dart';

// Module Admin
import 'package:module_admin/data/datasources/admin_product_datasource.dart';
import 'package:module_admin/data/repositories/admin_product_repository_impl.dart';
import 'package:module_admin/domain/repositories/admin_product_repository.dart';
import 'package:module_admin/domain/usecases/create_product_usecase.dart';
import 'package:module_admin/presentations/bloc/product_mutation_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> dependencyInitializer() async {
  // General
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFunctions>(() => FirebaseFunctions.instance);

  // Datasources
  getIt.registerLazySingleton<AuthDatasource>(() => AuthDatasourceImpl(getIt()));
  getIt.registerLazySingleton<AdminProductDatasource>(() => AdminProductDatasourceImpl(getIt()));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()));
  getIt.registerLazySingleton<AdminProductRepository>(() => AdminProductRepositoryImpl(getIt()));

  // Usecases
  // - Auth
  getIt.registerLazySingleton(() => SignInUseCase(getIt()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAuthStateUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  
  // - Admin (Product)
  getIt.registerLazySingleton(() => CreateProductUseCase(getIt()));

  // Blocs
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt(), getIt(), getIt(), getIt()));
  getIt.registerFactory<ProductMutationBloc>(() => ProductMutationBloc(getIt()));
}