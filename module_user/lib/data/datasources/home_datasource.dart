import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:module_core/module_core.dart';
import '../models/display_item_model.dart';
import '../models/slider_model.dart';
import '../../domain/entities/display_section.dart';

abstract class HomeDatasource {
  Future<List<DisplaySection>> getDisplaySections();
  Future<List<SliderModel>> getSliders();
}

class HomeDatasourceImpl implements HomeDatasource {
  final FirebaseFirestore _firestore;

  HomeDatasourceImpl(this._firestore);

  @override
  Future<List<DisplaySection>> getDisplaySections({int limit = 2}) async {
    return await (() async {
      // 1. Fetch all display items
      final displaySnapshot = await _firestore
        .collection('display_items')
        .orderBy('created_at', descending: true)
        .limit(limit) // ← maksimal 2 section di homepage
        .get();
      final displayItems = displaySnapshot.docs
          .map((doc) => DisplayItemModel.fromJson(doc.data()))
          .toList();

      // 2. Collect all unique product IDs
      final allProductIds = <String>{};
      for (final display in displayItems) {
        allProductIds.addAll(display.productIds);
      }

      if (allProductIds.isEmpty) {
        return displayItems
            .map((d) => DisplaySection(uid: d.uid, judul: d.judul, products: []))
            .toList();
      }

      // 3. Fetch all products in batches of 10 (Firestore whereIn limit)
      final productMap = <String, ProductModel>{};
      final idList = allProductIds.toList();

      for (var i = 0; i < idList.length; i += 10) {
        final batch = idList.sublist(
            i, i + 10 > idList.length ? idList.length : i + 10);
        final productSnapshot = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in productSnapshot.docs) {
          productMap[doc.id] = ProductModel.fromJson(doc.data());
        }
      }

      // 4. Build DisplaySections with resolved products
      return displayItems.map((display) {
      final products = display.productIds
          .take(5) // ← konsisten dengan limit di atas
          .where((id) => productMap.containsKey(id))
          .map((id) => productMap[id]!)
          .toList();

        return DisplaySection(
          uid: display.uid,
          judul: display.judul,
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