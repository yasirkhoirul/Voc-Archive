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
  final String? type;

  const UpdateProductInput({
    required this.uid,
    this.gambarBase64,
    this.keepGambarPaths,
    this.namaBrand,
    this.harga,
    this.deskripsi,
    this.detail,
    this.sizes,
    this.type,
    this.diskon,
  });

  Map<String, dynamic> toMap() {
    return {
      if (gambarBase64 != null) 'gambarBase64': gambarBase64,
      if (keepGambarPaths != null) 'keepGambarPaths': keepGambarPaths,
      if (namaBrand != null) 'namaBrand': namaBrand,
      if (harga != null) 'harga': harga,
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (detail != null) 'detail': detail,
      if (sizes != null) 'sizes': sizes,
      if (type != null) 'type': type,
      if (diskon != null) 'diskon': diskon,
    };
  }
}
