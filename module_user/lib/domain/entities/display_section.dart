import 'package:module_core/module_core.dart';

/// A display section with title and resolved product list.
class DisplaySection {
  final String uid;
  final String judul;
  final List<Product> products;

  const DisplaySection({
    required this.uid,
    required this.judul,
    required this.products,
  });
}
