class CreateProductInput {
  final List<String> gambarBase64;
  final String namaBrand;
  final double harga;
  final String deskripsi;
  final String detail;
  final Map<String, int> sizes;
  final double? diskon;

  const CreateProductInput({
    required this.gambarBase64,
    required this.namaBrand,
    required this.harga,
    required this.deskripsi,
    required this.detail,
    required this.sizes,
    this.diskon,
  });
}
