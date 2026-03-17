class UpdateProductInput {
  final String uid;
  final List<String>? gambarBase64;
  final List<String>? keepGambarPaths;
  final String? namaBrand;
  final double? harga;
  final String? deskripsi;
  final String? detail;
  final Map<String, int>? sizes;
  final double? diskon;

  const UpdateProductInput({
    required this.uid,
    this.gambarBase64,
    this.keepGambarPaths,
    this.namaBrand,
    this.harga,
    this.deskripsi,
    this.detail,
    this.sizes,
    this.diskon,
  });
}
