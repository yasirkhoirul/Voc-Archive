import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:module_auth/domain/entities/app_user.dart';
import 'package:module_auth/domain/usecases/get_auth_state_usecase.dart';
import 'package:module_auth/domain/usecases/register_usecase.dart';
import 'package:module_auth/domain/usecases/sign_in_usecase.dart';
import 'package:module_auth/domain/usecases/sign_out_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final GetAuthStateUseCase _getCurrentUserUseCase;
  final RegisterUseCase _registerUseCase;
  final SignOutUseCase _signOutUseCase;

  late final StreamSubscription<AppUser?> _authSubscription;

  AuthBloc(
    this._signInUseCase,
    this._getCurrentUserUseCase,
    this._registerUseCase,
    this._signOutUseCase,
  ) : super(AuthInitial()) {
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthLoginEvent>(_onAuthLogin);
    on<AuthRegisterEvent>(_onAuthRegister);
    on<AuthLogoutEvent>(_onAuthLogout);

    _authSubscription = _getCurrentUserUseCase().listen((user) {
      add(AuthUserChanged(user));
    });
  }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated());
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signInUseCase(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => null, // Sukses akan dihandle otomatis oleh Stream lewat AuthUserChanged
    );
  }

  Future<void> _onAuthRegister(AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _registerUseCase(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => null,
    );
  }

  Future<void> _onAuthLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signOutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => null,
    );
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
