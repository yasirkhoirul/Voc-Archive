
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:module_admin/data/datasources/admin_home_datasource.dart';
import 'package:module_admin/domain/usecases/update_product_usecase.dart';

// Module Core / Shared
import 'package:module_core/module_core.dart';

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
import 'package:module_admin/presentations/bloc/product_list_bloc.dart';
import 'package:module_admin/data/repositories/admin_home_repository.dart';
import 'package:module_admin/domain/repositories/admin_home_repository.dart';
import 'package:module_admin/domain/usecases/create_slider_usecase.dart';
import 'package:module_admin/domain/usecases/delete_slider_usecase.dart';
import 'package:module_admin/domain/usecases/create_display_usecase.dart';
import 'package:module_admin/domain/usecases/update_display_usecase.dart';
import 'package:module_admin/domain/usecases/delete_display_usecase.dart';
import 'package:module_admin/presentations/bloc/slider_mutation_bloc.dart';
import 'package:module_admin/presentations/bloc/display_mutation_bloc.dart';
import 'package:module_core/shared_domain/shared_usecases/get_product_by_id.dart';

final GetIt getIt = GetIt.instance;

Future<void> dependencyInitializer() async {
  // General
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFunctions>(() => FirebaseFunctions.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Datasources
  getIt.registerLazySingleton<AuthDatasource>(() => AuthDatasourceImpl(getIt()));
  getIt.registerLazySingleton<AdminHomeDatasource>(() => AdminHomeDataSourceImpl(getIt()),);
  getIt.registerLazySingleton<AdminProductDatasource>(() => AdminProductDatasourceImpl(getIt()));
  getIt.registerLazySingleton<SharedProductDatasource>(() => SharedProductDatasourceImpl(getIt()));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()));
  getIt.registerLazySingleton<AdminProductRepository>(() => AdminProductRepositoryImpl(getIt()));
  getIt.registerLazySingleton<SharedProductRepository>(() => SharedProductRepositoryImpl(getIt()));
  getIt.registerLazySingleton<AdminHomeRepository>(() => AdminHomeRepositoryImpl(getIt()));

  // Usecases
  // - Auth
  getIt.registerLazySingleton(() => SignInUseCase(getIt()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAuthStateUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  
  // - Shared Product
  getIt.registerLazySingleton(() => GetAllProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetProductById(getIt()));
  getIt.registerLazySingleton(() => GetDiscountProductsUseCase(getIt()));

  // - Admin (Product)
  getIt.registerLazySingleton(() => CreateProductUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProductUsecase(getIt()));

  // - Admin (Home)
  getIt.registerLazySingleton(() => CreateSliderUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteSliderUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateDisplayUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateDisplayUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteDisplayUseCase(getIt()));

  // Blocs
  getIt.registerLazySingleton<CurrencyCubit>(() => CurrencyCubit());
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt(), getIt(), getIt(), getIt()));
  getIt.registerFactory<ProductMutationBloc>(() => ProductMutationBloc(getIt(),getIt(), getIt()));
  getIt.registerFactory<ProductListBloc>(() => ProductListBloc(getIt()));
  getIt.registerFactory<SliderMutationBloc>(() => SliderMutationBloc(getIt(), getIt()));
  getIt.registerFactory<DisplayMutationBloc>(() => DisplayMutationBloc(getIt(), getIt(), getIt()));
}