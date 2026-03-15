class CreateProductInput {
  final List<String> gambar;
  final String namaBrand;
  final double harga;
  final String deskripsi;
  final String detail;
  final Map<String, int> sizes;
  final double? diskon;

  const CreateProductInput({
    required this.gambar,
    required this.namaBrand,
    required this.harga,
    required this.deskripsi,
    required this.detail,
    required this.sizes,
    this.diskon,
  });
}
