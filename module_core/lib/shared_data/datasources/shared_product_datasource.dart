import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../utils/runcatching.dart';
import '../models/product_model.dart';

abstract class SharedProductDatasource {
  Future<List<ProductModel>> getAllProducts({
    String? query,
    List<String>? types,
    double? minPrice,
    double? maxPrice,
  });
  Future<List<ProductModel>> getDiscountProducts({String? query});
  Future<ProductModel> getProductById(String uid);
}

class SharedProductDatasourceImpl implements SharedProductDatasource {
  final FirebaseFirestore _firestore;

  SharedProductDatasourceImpl(this._firestore);

  @override
  Future<List<ProductModel>> getAllProducts({
    String? query,
    List<String>? types,
    double? minPrice,
    double? maxPrice,
  }) async {
    return await (() async {
      Query queryRef = _firestore.collection('products');
      Logger().d(
        "Fetching products with filters - query: $query, types: $types, minPrice: $minPrice, maxPrice: $maxPrice",
      );
      if (types != null && types.isNotEmpty) {
        queryRef = queryRef.where('type', whereIn: types);
      }

      final snapshot = await queryRef.get();
      var products = snapshot.docs
          .map(
            (doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      if (query != null && query.isNotEmpty) {
        final search = query.toLowerCase();
        products = products
            .where((p) => p.namaBrand.toLowerCase().contains(search))
            .toList();
      }

      if (minPrice != null) {
        products = products.where((p) => p.harga >= minPrice).toList();
      }
      if (maxPrice != null) {
        products = products.where((p) => p.harga <= maxPrice).toList();
      }

      return products;
    })().guardDatasource();
  }

  @override
  Future<List<ProductModel>> getDiscountProducts({String? query}) async {
    return await (() async {
      final snapshot = await _firestore
          .collection('products')
          .where('diskon', isGreaterThan: 0)
          .get();
      var products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
      if (query != null && query.isNotEmpty) {
        final search = query.toLowerCase();
        products = products
            .where((p) => p.namaBrand.toLowerCase().contains(search))
            .toList();
      }
      return products;
    })().guardDatasource();
  }

  @override
  Future<ProductModel> getProductById(String uid) async {
    return await (() async {
      final snapshot = await _firestore.collection("products").doc(uid).get();
      if (snapshot.exists) {
        return ProductModel.fromJson(snapshot.data()!);
      } else {
        throw Exception("Product not found");
      }
    })().guardDatasource();
  }
}
