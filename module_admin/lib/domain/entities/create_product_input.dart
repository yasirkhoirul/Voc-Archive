class CreateProductInput {
  final List<String> gambarBase64;
  final String namaBrand;
  final double harga;
  final String deskripsi;
  final String detail;
  final Map<String, int> sizes;
  final double? diskon;
  final String type;

  const CreateProductInput({
    required this.gambarBase64,
    required this.namaBrand,
    required this.harga,
    required this.deskripsi,
    required this.detail,
    required this.sizes,
    required this.type,
    this.diskon,
  });

  Map<String, dynamic> toMap() {
    return {
      'gambarBase64': gambarBase64,
      'namaBrand': namaBrand,
      'harga': harga,
      'deskripsi': deskripsi,
      'detail': detail,
      'sizes': sizes,
      'type': type,
      if (diskon != null) 'diskon': diskon,
    };
  }
}
