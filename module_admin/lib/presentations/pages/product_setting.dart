import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:module_core/widget/snackbar.dart';
import '../../domain/entities/create_product_input.dart';
import '../bloc/product_mutation_bloc.dart';

class ProductSetting extends StatefulWidget {
  final String? productId;
  const ProductSetting({super.key, this.productId});

  @override
  State<ProductSetting> createState() => _ProductSettingState();
}

class _ProductSettingState extends State<ProductSetting> {
  @override
  void initState() {
    if (widget.productId != null) {
      context.read<ProductMutationBloc>().add(
        GetProductByIdEvent(widget.productId!),
      );
    }
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _hargaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _detailController = TextEditingController();
  final _diskonController = TextEditingController();
  final _stokController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<String> _gambarBase64List = [];
  List<String> _gambarNames = [];

  @override
  void dispose() {
    _brandController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    _detailController.dispose();
    _diskonController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      List<String> base64List = [];
      List<String> names = [];
      for (var image in images) {
        final bytes = await image.readAsBytes();
        base64List.add(base64Encode(bytes));
        names.add(image.name);
      }
      setState(() {
        _gambarBase64List = base64List;
        _gambarNames = names;
      });
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_gambarBase64List.isEmpty) {
        AppSnackbar.onFailure(
          context,
          'Gambar produk wajib dipilih (minimal 1)',
        );
        return;
      }

      final input = CreateProductInput(
        namaBrand: _brandController.text.trim(),
        harga: double.tryParse(_hargaController.text.trim()) ?? 0.0,
        deskripsi: _deskripsiController.text.trim(),
        detail: _detailController.text.trim(),
        diskon: double.tryParse(_diskonController.text.trim()),
        gambarBase64: _gambarBase64List,
        sizes: {'onesize': int.tryParse(_stokController.text.trim()) ?? 0},
      );

      if (widget.productId != null) {
        context.read<ProductMutationBloc>().add(UpdateProductSubmitted(input));
      } else {
        context.read<ProductMutationBloc>().add(CreateProductSubmitted(input));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: BlocConsumer<ProductMutationBloc, ProductMutationState>(
        listener: (context, state) {
          if (state is ProductMutationLoaded) {
            _brandController.text = state.product.namaBrand;
            _hargaController.text = state.product.harga.toString();
            _deskripsiController.text = state.product.deskripsi;
            _detailController.text = state.product.detail;
            _diskonController.text = state.product.diskon.toString();
            _stokController.text = state.product.sizes['onesize'].toString();
            _gambarBase64List = state.product.gambar;
            _gambarNames = state.product.gambarPaths;
          }
          if (state is ProductMutationSuccess) {
            AppSnackbar.onSuccess(context, 'Produk berhasil ditambahkan!');
            _formKey.currentState?.reset();
            _brandController.clear();
            _hargaController.clear();
            _deskripsiController.clear();
            _detailController.clear();
            _diskonController.clear();
            _stokController.clear();
            setState(() {
              _gambarBase64List.clear();
              _gambarNames.clear();
            });
          } else if (state is ProductMutationError) {
            AppSnackbar.onFailure(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is ProductMutationLoading;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Brand',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hargaController,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _deskripsiController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _detailController,
                    decoration: const InputDecoration(
                      labelText: 'Detail Produk',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _diskonController,
                    decoration: const InputDecoration(
                      labelText: 'Diskon (Nominal/Opsional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stokController,
                    decoration: const InputDecoration(
                      labelText: 'Total Stok (Onesize)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : _pickImages,
                    icon: const Icon(Icons.image),
                    label: const Text('Pilih Gambar (Multiple)'),
                  ),
                  if (_gambarBase64List.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _gambarBase64List.length,
                        itemBuilder: (context, index) {
                          final imgString = _gambarBase64List[index];

                          // Validasi apakah imgString berupa link cloud firestorage atau url biasa.
                          // base64 murni biasanya diawali dengan pola tertentu tergantung format gambar atau langsung alfanumerik.
                          // Teks Base64 encode *TIDAK MENGANDUNG* karakter titik (.)
                          // Jadi jika mengandung titik (.) atau awalan 'http' atau '/', besar kemungkinan = file/url
                          final isNetworkOrPath =
                              imgString.startsWith('http') ||
                              (imgString.contains('/') &&
                                  imgString.contains('.'));

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: isNetworkOrPath
                                      ? Image.network(
                                          imgString,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, err, stac) {
                                            Logger().e(
                                              'Failed to load image from network: $err $stac',
                                            );
                                            return const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                            );
                                          },
                                        )
                                      : Image.memory(
                                          base64Decode(imgString),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 50,
                                              ),
                                        ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _gambarBase64List.removeAt(index);
                                        if (_gambarNames.length > index) {
                                          _gambarNames.removeAt(index);
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(context),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan Produk'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
