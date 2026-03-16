import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    if (timestamp is String) {
      final dt = DateTime.tryParse(timestamp);
      if (dt != null) return dt;
    }
    try {
      if (timestamp != null && timestamp.toString().contains('seconds=')) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
      }
    } catch (_) {}
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime date) => date.millisecondsSinceEpoch;
}
