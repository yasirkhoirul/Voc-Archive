part of 'about_us_cubit.dart';

sealed class AboutUsUserState extends Equatable {
  const AboutUsUserState();

  @override
  List<Object?> get props => [];
}

final class AboutUsUserInitial extends AboutUsUserState {}

final class AboutUsUserLoading extends AboutUsUserState {}

final class AboutUsUserLoaded extends AboutUsUserState {
  final String heroImage;
  final String title;
  final String subtitle;
  final String location;
  final String bodyTitle;
  final String bodyText;
  final List<String> galleryImages;

  const AboutUsUserLoaded({
    required this.heroImage,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.bodyTitle,
    required this.bodyText,
    required this.galleryImages,
  });

  @override
  List<Object?> get props => [
        heroImage,
        title,
        subtitle,
        location,
        bodyTitle,
        bodyText,
        galleryImages,
      ];
}

final class AboutUsUserError extends AboutUsUserState {
  final String message;

  const AboutUsUserError(this.message);

  @override
  List<Object?> get props => [message];
}
