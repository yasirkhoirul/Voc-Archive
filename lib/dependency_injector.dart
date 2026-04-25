import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:module_admin/data/datasources/admin_home_datasource.dart';
import 'package:module_admin/domain/usecases/update_product_usecase.dart';
import 'package:module_admin/domain/usecases/delete_product_usecse.dart';
import 'package:module_admin/presentations/bloc/brand_bloc.dart';
import 'package:module_admin/presentations/bloc/settings_bloc.dart';

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
import 'package:module_admin/presentations/cubit/history_cubit.dart';
import 'package:module_admin/data/datasources/admin_settings_datasource.dart';
import 'package:module_admin/data/repositories/admin_settings_repository_impl.dart';
import 'package:module_admin/domain/repositories/admin_settings_repository.dart';
import 'package:module_admin/data/datasources/admin_brand_datasource.dart';
import 'package:module_admin/data/repositories/admin_brand_repository_impl.dart';
import 'package:module_admin/domain/repositories/admin_brand_repository.dart';
import 'package:module_admin/domain/usecases/create_brand_usecase.dart';
import 'package:module_admin/domain/usecases/update_brand_usecase.dart';
import 'package:module_admin/domain/usecases/delete_brand_usecase.dart';
import 'package:module_admin/domain/usecases/set_exchange_rate_usecase.dart';
import 'package:module_admin/domain/usecases/add_shipping_rate_usecase.dart';
import 'package:module_admin/domain/usecases/update_shipping_rate_usecase.dart';
import 'package:module_admin/domain/usecases/delete_shipping_rate_usecase.dart';

// Module Core
import 'package:module_core/shared_domain/shared_usecases/get_product_by_id.dart';
// Module Core (shared history)
import 'package:module_core/shared_data/datasources/shared_history_remote_datasource.dart';
import 'package:module_core/shared_data/repositories/shared_history_repository_impl.dart';
import 'package:module_core/shared_domain/shared_repositories/shared_history_repository.dart';
import 'package:module_core/shared_domain/shared_usecases/get_all_history_usecase.dart';
import 'package:module_core/shared_domain/shared_usecases/get_history_by_user_id_usecase.dart';

// Module User
import 'package:module_user/data/datasources/home_datasource.dart';
import 'package:module_user/data/repositories/home_repository_impl.dart';
import 'package:module_user/domain/repositories/home_repository.dart';
import 'package:module_user/domain/usecases/get_display_sections_usecase.dart';
import 'package:module_user/domain/usecases/get_sliders_usecase.dart';
import 'package:module_user/presentation/bloc/catalog_bloc.dart';
import 'package:module_user/presentation/bloc/cart_bloc.dart';
import 'package:module_user/presentation/bloc/checkout_bloc.dart';
import 'package:module_user/presentation/cubit/catalog_discount_cubit.dart';
import 'package:module_user/presentation/cubit/catalog_sold_out_cubit.dart';
import 'package:module_user/presentation/cubit/history_user_cubit.dart';
import 'package:module_user/presentation/cubit/detail_product_cubit.dart';
import 'package:module_user/presentation/cubit/display_cubit.dart';
import 'package:module_user/presentation/cubit/home_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> dependencyInitializer() async {
  // General
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFunctions>(
    () => FirebaseFunctions.instance,
  );
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Datasources
  getIt.registerLazySingleton<AuthDatasource>(
    () => AuthDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AdminHomeDatasource>(
    () => AdminHomeDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AdminProductDatasource>(
    () => AdminProductDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<SharedProductDatasource>(
    () => SharedProductDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<SharedBrandDatasource>(
    () => SharedBrandDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<SharedSettingsDatasource>(
    () => SharedSettingsDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AdminBrandDatasource>(
    () => AdminBrandDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AdminSettingsDatasource>(
    () => AdminSettingsDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<HomeDatasource>(
    () => HomeDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<SharedHistoryRemoteDataSource>(
    () => SharedHistoryRemoteDataSourceImpl(firestore: getIt()),
  );
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<AdminProductRepository>(
    () => AdminProductRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<SharedProductRepository>(
    () => SharedProductRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<AdminHomeRepository>(
    () => AdminHomeRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<SharedBrandRepository>(
    () => SharedBrandRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<SharedSettingsRepository>(
    () => SharedSettingsRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<AdminBrandRepository>(
    () => AdminBrandRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<AdminSettingsRepository>(
    () => AdminSettingsRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<SharedHistoryRepository>(
    () => SharedHistoryRepositoryImpl(remoteDataSource: getIt()),
  );
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

  // - Shared Settings & Brands
  getIt.registerLazySingleton(() => GetBrandsUsecase(getIt()));
  getIt.registerLazySingleton(() => GetExchangeRateUsecase(getIt()));
  getIt.registerLazySingleton(() => GetShippingRatesUsecase(getIt()));

  // - Admin (Product)
  getIt.registerLazySingleton(() => CreateProductUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProductUsecase(getIt()));
  getIt.registerLazySingleton(() => DeleteProductUseCase(getIt()));

  // - Admin (Home)
  getIt.registerLazySingleton(() => CreateSliderUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteSliderUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateDisplayUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateDisplayUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteDisplayUseCase(getIt()));

  // - Admin (Brands y Settings)
  getIt.registerLazySingleton(() => CreateBrandUsecase(getIt()));
  getIt.registerLazySingleton(() => UpdateBrandUsecase(getIt()));
  getIt.registerLazySingleton(() => DeleteBrandUsecase(getIt()));
  getIt.registerLazySingleton(() => SetExchangeRateUsecase(getIt()));
  getIt.registerLazySingleton(() => AddShippingRateUsecase(getIt()));
  getIt.registerLazySingleton(() => UpdateShippingRateUsecase(getIt()));
  getIt.registerLazySingleton(() => DeleteShippingRateUsecase(getIt()));

  // - User (Home & Display)
  getIt.registerLazySingleton(() => GetSlidersUsecase(getIt()));
  getIt.registerLazySingleton(() => GetDisplaySectionsUsecase(getIt()));
  getIt.registerLazySingleton(() => GetAllHistoryUseCase(getIt()));
  getIt.registerLazySingleton(() => GetHistoryByUserIdUseCase(getIt()));

  // Blocs
  getIt.registerLazySingleton<CurrencyCubit>(
    () => CurrencyCubit(getExchangeRateUsecase: getIt()),
  );
  getIt.registerFactory<SettingsBloc>(
    () => SettingsBloc(getIt(), getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<ProductMutationBloc>(
    () => ProductMutationBloc(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<ProductListBloc>(() => ProductListBloc(getIt()));
  getIt.registerFactory<SliderMutationBloc>(
    () => SliderMutationBloc(getIt(), getIt()),
  );
  getIt.registerFactory<DisplayMutationBloc>(
    () => DisplayMutationBloc(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<CartBloc>(() => CartBloc());
  getIt.registerFactory<CheckoutBloc>(
    () => CheckoutBloc(getShippingRatesUsecase: getIt(), functions: getIt()),
  );
  getIt.registerFactory<BrandBloc>(
    () => BrandBloc(getIt(), getIt(), getIt(), getIt()),
  );

  //cubit
  getIt.registerFactory(() => DetailProductCubit(getIt()));
  getIt.registerCachedFactory(() => HomeCubit(getIt()));
  getIt.registerCachedFactory(() => DisplayCubit(getIt()));
  getIt.registerCachedFactory(() => CatalogBloc(getIt()));
  getIt.registerCachedFactory(() => CatalogDiscountCubit(getIt()));
  getIt.registerFactory(() => HistoryUserCubit(getIt(), getIt()));
  getIt.registerFactory(
    () => HistoryCubit(
      getAllHistoryUseCase: getIt(),
      functions: getIt(),
    ),
  );
}
