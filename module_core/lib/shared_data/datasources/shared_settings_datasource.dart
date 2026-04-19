import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:module_core/utils/runcatching.dart';

abstract class SharedSettingsDatasource {
  Future<double?> getExchangeRate();
  Future<List<Map<String, dynamic>>> getShippingRates();
}

class SharedSettingsDatasourceImpl implements SharedSettingsDatasource {
  final FirebaseFirestore _firestore;

  SharedSettingsDatasourceImpl(this._firestore);

  @override
  Future<double?> getExchangeRate() async {
    return await (() async {
      final doc = await _firestore
          .collection('settings')
          .doc('exchange_rate')
          .get();
      if (!doc.exists) return null;
      return (doc.data()?['usd_to_idr'] as num?)?.toDouble();
    })().guardDatasource();
  }

  @override
  Future<List<Map<String, dynamic>>> getShippingRates() async {
    return await (() async {
      final doc = await _firestore
          .collection('settings')
          .doc('shipping_rates')
          .get();
      if (!doc.exists) return <Map<String, dynamic>>[];
      final rates = doc.data()?['rates'] as List<dynamic>?;
      if (rates == null) return <Map<String, dynamic>>[];
      return rates.map((r) => Map<String, dynamic>.from(r as Map)).toList();
    })().guardDatasource();
  }
}
