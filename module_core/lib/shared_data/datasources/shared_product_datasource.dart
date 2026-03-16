import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/runcatching.dart';
import '../models/product_model.dart';

abstract class SharedProductDatasource {
  Future<List<ProductModel>> getAllProducts();
  Future<List<ProductModel>> getDiscountProducts();
  Future<ProductModel> getProductById(String uid);
}

class SharedProductDatasourceImpl implements SharedProductDatasource {
  final FirebaseFirestore _firestore;

  SharedProductDatasourceImpl(this._firestore);

  @override
  Future<List<ProductModel>> getAllProducts() async {
    return await (() async {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();
    })().guardDatasource();
  }

  @override
  Future<List<ProductModel>> getDiscountProducts() async {
    return await (() async {
      final snapshot = await _firestore.collection('products').where('diskon', isGreaterThan: 0).get();
      return snapshot.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();
    })().guardDatasource();
  }
  
  @override
  Future<ProductModel> getProductById(String uid) async{
   return await (() async {
    final snapshot = await _firestore.collection("products").doc(uid).get();
    if(snapshot.exists){
      return ProductModel.fromJson(snapshot.data()!);
    } else {
      throw Exception("Product not found");
    }
   })().guardDatasource();
  }
}
