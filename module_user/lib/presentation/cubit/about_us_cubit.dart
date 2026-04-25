import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:equatable/equatable.dart';

part 'about_us_state.dart';

class AboutUsCubitUser extends Cubit<AboutUsUserState> {
  final FirebaseFunctions _functions;

  AboutUsCubitUser(this._functions) : super(AboutUsUserInitial());

  Future<void> load() async {
    emit(AboutUsUserLoading());
    try {
      final callable = _functions.httpsCallable('getAboutUsContent');
      final result = await callable.call();
      final data = result.data['data'] as Map<String, dynamic>? ?? {};

      emit(AboutUsUserLoaded(
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
      emit(AboutUsUserError(e.toString()));
    }
  }
}
