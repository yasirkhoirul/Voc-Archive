part of 'aboutus_cubit.dart';

sealed class AboutUsState extends Equatable {
  const AboutUsState();

  @override
  List<Object?> get props => [];
}

final class AboutUsInitial extends AboutUsState {}

final class AboutUsLoading extends AboutUsState {}

final class AboutUsLoaded extends AboutUsState {
  final String heroImage;
  final String title;
  final String subtitle;
  final String location;
  final String bodyTitle;
  final String bodyText;
  final List<String> galleryImages;

  const AboutUsLoaded({
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

final class AboutUsSaving extends AboutUsState {}

final class AboutUsSaved extends AboutUsState {}

final class AboutUsError extends AboutUsState {
  final String message;

  const AboutUsError(this.message);

  @override
  List<Object?> get props => [message];
}
