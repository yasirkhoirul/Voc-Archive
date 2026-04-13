part of 'display_cubit.dart';

sealed class DisplayState extends Equatable {
  const DisplayState();

  @override
  List<Object> get props => [];
}

final class DisplayInitial extends DisplayState {}
final class DisplayLoading extends DisplayState {}
final class DisplaySuccess extends DisplayState {
  final List<DisplaySection> displaySections;
  const DisplaySuccess(this.displaySections);
}
final class DisplayError extends DisplayState {
  final String message;
  const DisplayError(this.message);
}
