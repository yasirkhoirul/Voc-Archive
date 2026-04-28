part of 'auth_bloc.dart';

@immutable
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class Authenticated extends AuthState {
  final AppUser user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {}

final class EmailVerificationSent extends AuthState {
  final String email;

  const EmailVerificationSent(this.email);

  @override
  List<Object?> get props => [email];
}

final class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
