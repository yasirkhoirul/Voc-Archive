import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared_data/models/order_history_model.dart';

abstract class SharedHistoryRemoteDataSource {
  Future<List<OrderHistoryModel>> getAllHistory();
  Future<List<OrderHistoryModel>> getHistoryByUserId(String userId);
}

class SharedHistoryRemoteDataSourceImpl
    implements SharedHistoryRemoteDataSource {
  final FirebaseFirestore firestore;

  SharedHistoryRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<OrderHistoryModel>> getAllHistory() async {
    try {
      final snapshot = await firestore
          .collection('order_history')
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderHistoryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<OrderHistoryModel>> getHistoryByUserId(String userId) async {
    try {
      final snapshot = await firestore
          .collection('order_history')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderHistoryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
