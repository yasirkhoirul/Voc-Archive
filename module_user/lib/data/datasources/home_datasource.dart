import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:module_core/module_core.dart';
import '../models/slider_model.dart';
import '../../domain/entities/display_section.dart';

abstract class HomeDatasource {
  Future<List<DisplaySection>> getDisplaySections();
  Future<List<SliderModel>> getSliders();
}

class HomeDatasourceImpl implements HomeDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  HomeDatasourceImpl(this._firestore)
    : _functions = FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ); // Sesuaikan region jika perlu

  @override
  Future<List<DisplaySection>> getDisplaySections({int limit = 2}) async {
    return await (() async {
      final HttpsCallable callable = _functions.httpsCallable(
        'getDisplaySections',
      );

      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        'limit': limit,
      });

      final Map<String, dynamic> data = result.data as Map<String, dynamic>;

      if (data['success'] != true || data['data'] == null) {
        throw Exception(
          'Failed to fetch display sections from cloud functions',
        );
      }

      final List<dynamic> sectionsData = data['data'] as List<dynamic>;

      return sectionsData.map((dynamic sectionRaw) {
        final Map<String, dynamic> sectionMap = Map<String, dynamic>.from(
          sectionRaw as Map,
        );
        final List<dynamic> productsDataRaw =
            sectionMap['products'] as List<dynamic>;

        // Deserialize ke ProductModel
        final List<ProductModel> products = productsDataRaw.map((
          dynamic productRaw,
        ) {
          final Map<String, dynamic> productMap = Map<String, dynamic>.from(
            productRaw as Map,
          );
          return ProductModel.fromJson(productMap);
        }).toList();

        return DisplaySection(
          uid: sectionMap['uid'] as String? ?? '',
          judul: sectionMap['judul'] as String? ?? 'Untitled',
          products: products,
        );
      }).toList();
    })().guardDatasource();
  }

  @override
  Future<List<SliderModel>> getSliders() async {
    return await (() async {
      final snapshot = await _firestore
          .collection('sliders')
          .orderBy('created_at', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => SliderModel.fromJson(doc.data()))
          .toList();
    })().guardDatasource();
  }
}
