part of 'auth_bloc.dart';

@immutable
sealed class AuthState extends Equatable {}

final class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}
final class Authenticated extends AuthState {
  @override
  List<Object?> get props => [];
}
final class Unauthenticated extends AuthState {
  @override
  List<Object?> get props => [];
}
