part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final AppUser? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthRegisterEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthRegisterEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}
