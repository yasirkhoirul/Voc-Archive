class DisplayItem {
  final String uid;
  final String judul;
  final List<String> productIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DisplayItem({
    required this.uid,
    required this.judul,
    required this.productIds,
    required this.createdAt,
    required this.updatedAt,
  });
}
