import 'dart:convert';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:equatable/equatable.dart';

part 'aboutus_state.dart';

class AboutUsCubit extends Cubit<AboutUsState> {
  final FirebaseFunctions _functions;

  AboutUsCubit(this._functions) : super(AboutUsInitial());

  Future<void> loadAboutUs() async {
    emit(AboutUsLoading());
    try {
      final callable = _functions.httpsCallable('getAboutUsContent');
      final result = await callable.call();
      final data = result.data['data'] as Map<String, dynamic>? ?? {};

      emit(AboutUsLoaded(
        heroImage: data['hero_image'] as String? ?? '',
        title: data['title'] as String? ?? 'About Us',
        subtitle: data['subtitle'] as String? ?? 'voc.archive',
        location: data['location'] as String? ?? 'BASED IN INDONESIA',
        bodyTitle: data['body_title'] as String? ?? 'voc.archive',
        bodyText: data['body_text'] as String? ?? '',
        galleryImages: (data['gallery_images'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      ));
    } catch (e) {
      emit(AboutUsError(e.toString()));
    }
  }

  Future<void> saveAboutUs({
    String? heroImageBase64,
    required String title,
    required String subtitle,
    required String location,
    required String bodyTitle,
    required String bodyText,
    List<String>? galleryImagesBase64,
    List<String>? keepGalleryImages,
  }) async {
    emit(AboutUsSaving());
    try {
      final callable = _functions.httpsCallable('updateAboutUsContent');
      final payload = <String, dynamic>{
        'title': title,
        'subtitle': subtitle,
        'location': location,
        'body_title': bodyTitle,
        'body_text': bodyText,
      };

      if (heroImageBase64 != null) {
        payload['hero_image_base64'] = heroImageBase64;
      }
      if (galleryImagesBase64 != null && galleryImagesBase64.isNotEmpty) {
        payload['gallery_images_base64'] = galleryImagesBase64;
      }
      if (keepGalleryImages != null) {
        payload['keep_gallery_images'] = keepGalleryImages;
      }

      await callable.call(payload);
      emit(AboutUsSaved());

      // Reload after saving
      await loadAboutUs();
    } catch (e) {
      emit(AboutUsError(e.toString()));
    }
  }

  /// Convert Uint8List bytes to base64 string
  static String bytesToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }
}
