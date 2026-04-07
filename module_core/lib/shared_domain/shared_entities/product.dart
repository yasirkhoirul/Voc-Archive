class Product {
  final String uid;
  final List<String> gambar;
  final List<String> gambarPaths;
  final String namaBrand;
  final double harga;
  final String deskripsi;
  final String detail;
  final Map<String, int> sizes;
  final int totalStok;
  final double diskon;
  final double hargaDiskon;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.uid,
    required this.gambar,
    required this.gambarPaths,
    required this.namaBrand,
    required this.harga,
    required this.deskripsi,
    required this.detail,
    required this.sizes,
    required this.totalStok,
    required this.diskon,
    required this.hargaDiskon,
    required this.createdAt,
    required this.updatedAt,
  });
}
