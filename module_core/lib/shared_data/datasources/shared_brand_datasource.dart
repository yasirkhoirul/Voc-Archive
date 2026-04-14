import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:module_core/utils/runcatching.dart';

abstract class SharedBrandDatasource {
  Future<List<Map<String, dynamic>>> getBrands();
}

class SharedBrandDatasourceImpl implements SharedBrandDatasource {
  final FirebaseFirestore _firestore;

  SharedBrandDatasourceImpl(this._firestore);

  @override
  Future<List<Map<String, dynamic>>> getBrands() async {
    return await (() async {
      final snapshot = await _firestore
          .collection('brands')
          .orderBy('nama')
          .get();
      return snapshot.docs
          .map((doc) => {
                'uid': doc.id,
                'nama': doc.data()['nama'] as String,
                'jenis_produk': doc.data()['jenis_produk'] as List<dynamic>? ?? [],
              })
          .toList();
    })().guardDatasource();
  }
}
