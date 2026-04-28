import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:module_core/widget/snackbar.dart';
import '../../domain/entities/create_product_input.dart';
import '../../domain/entities/update_product_input.dart';
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
    context.read<ProductMutationBloc>().add(
      LoadProductFormEvent(productId: widget.productId),
    );
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _hargaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _detailController = TextEditingController();
  final _diskonController = TextEditingController();

  String? _selectedType;

  final Map<String, int> _stocks = {
    'onesize': 0,
    'xs': 0,
    's': 0,
    'm': 0,
    'l': 0,
    'xl': 0,
    'xxl': 0,
  };

  final ImagePicker _picker = ImagePicker();
  final List<String> _gambarBase64List = [];
  final List<String> _gambarNames = [];
  List<String> _existingGambarPaths = [];
  List<String> _existingGambarUrls = [];

  List<Map<String, dynamic>> _brands = [];

  @override
  void dispose() {
    _brandController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    _detailController.dispose();
    _diskonController.dispose();
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
        _gambarBase64List.addAll(base64List);
        _gambarNames.addAll(names);
      });
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_brandController.text.trim().isEmpty || _selectedType == null) {
        AppSnackbar.onFailure(context, 'Brand dan Tipe harus diisi/dipilih');
        return;
      }

      if (widget.productId == null && _gambarBase64List.isEmpty) {
        AppSnackbar.onFailure(
          context,
          'Gambar produk wajib dipilih (minimal 1)',
        );
        return;
      }
      if (widget.productId != null &&
          _gambarBase64List.isEmpty &&
          _existingGambarPaths.isEmpty) {
        AppSnackbar.onFailure(context, 'Gambar produk tidak boleh kosong');
        return;
      }

      if (widget.productId != null) {
        final input = UpdateProductInput(
          uid: widget.productId!,
          namaBrand: _brandController.text.trim(),
          type: _selectedType!,
          harga: double.tryParse(_hargaController.text.trim()) ?? 0.0,
          deskripsi: _deskripsiController.text.trim(),
          detail: _detailController.text.trim(),
          diskon: double.tryParse(_diskonController.text.trim()),
          gambarBase64: _gambarBase64List.isNotEmpty ? _gambarBase64List : null,
          keepGambarPaths: _existingGambarPaths,
          sizes: _stocks,
        );
        context.read<ProductMutationBloc>().add(UpdateProductSubmitted(input));
      } else {
        final input = CreateProductInput(
          namaBrand: _brandController.text.trim(),
          type: _selectedType!,
          harga: double.tryParse(_hargaController.text.trim()) ?? 0.0,
          deskripsi: _deskripsiController.text.trim(),
          detail: _detailController.text.trim(),
          diskon: double.tryParse(_diskonController.text.trim()),
          gambarBase64: _gambarBase64List,
          sizes: _stocks,
        );
        context.read<ProductMutationBloc>().add(CreateProductSubmitted(input));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId != null ? 'Edit Produk' : 'Tambah Produk'),
        actions: widget.productId != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Produk'),
                        content: const Text(
                          'Yakin ingin menghapus produk ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<ProductMutationBloc>().add(
                                DeleteProductSubmitted(widget.productId!),
                              );
                            },
                            child: const Text(
                              'Hapus',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: BlocConsumer<ProductMutationBloc, ProductMutationState>(
        listener: (context, state) {
          if (state is ProductFormLoaded) {
            _brands = state.brands;

            if (state.product != null && _brandController.text.isEmpty) {
              _brandController.text = state.product!.namaBrand;
              _selectedType = state.product!.type;
              _hargaController.text = state.product!.harga.toString();
              _deskripsiController.text = state.product!.deskripsi;
              _detailController.text = state.product!.detail;
              _diskonController.text = state.product!.diskon.toString();

              _existingGambarUrls = List.from(state.product!.gambar);
              _existingGambarPaths = List.from(state.product!.gambarPaths);

              _stocks.updateAll((key, value) => 0);
              state.product!.sizes.forEach((key, value) {
                if (_stocks.containsKey(key)) {
                  _stocks[key] = value;
                }
              });

              _gambarBase64List.clear();
              _gambarNames.clear();
            }
            setState(() {});
          }
          if (state is ProductMutationSuccess) {
            AppSnackbar.onSuccess(context, 'Tindakan berhasil!');
            Navigator.of(context).pop();
          } else if (state is ProductMutationError) {
            AppSnackbar.onFailure(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is ProductMutationLoading &&
              _brandController.text.isEmpty &&
              _selectedType == null &&
              widget.productId != null) {
            return const Center(child: CircularProgressIndicator());
          }

          final isLoading = state is ProductMutationLoading;

          List<String> allTypes = _brands
              .map((b) => b['nama'] as String)
              .toSet()
              .toList();

          if (_selectedType != null && !allTypes.contains(_selectedType)) {
            allTypes.add(_selectedType!);
          }

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
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    value: allTypes.contains(_selectedType)
                        ? _selectedType
                        : null,
                    items: allTypes
                        .map(
                          (t) => DropdownMenuItem<String>(
                            value: t,
                            child: Text(t),
                          ),
                        )
                        .toList(),
                    onChanged: isLoading
                        ? null
                        : (val) {
                            setState(() {
                              _selectedType = val;
                            });
                          },
                    validator: (v) => v == null ? 'Wajib dipilih' : null,
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
                      labelText: 'Item',
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
                      labelText: 'Description',
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
                  const Text(
                    'Atur Stok Per Ukuran:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: _stocks.keys.map((sz) {
                      return IntrinsicWidth(
                        child: Column(
                          children: [
                            Text(
                              sz.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            if (_stocks[sz]! > 0) {
                                              setState(
                                                () => _stocks[sz] =
                                                    _stocks[sz]! - 1,
                                              );
                                            }
                                          },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      '${_stocks[sz]}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            setState(
                                              () => _stocks[sz] =
                                                  _stocks[sz]! + 1,
                                            );
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : _pickImages,
                    icon: const Icon(Icons.image),
                    label: const Text('Pilih Gambar (Multiple)'),
                  ),
                  if (_gambarBase64List.isNotEmpty ||
                      _existingGambarUrls.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            _existingGambarUrls.length +
                            _gambarBase64List.length,
                        itemBuilder: (context, index) {
                          final isExisting = index < _existingGambarUrls.length;
                          final imgString = isExisting
                              ? _existingGambarUrls[index]
                              : _gambarBase64List[index -
                                    _existingGambarUrls.length];

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: isExisting
                                      ? Image.network(
                                          imgString,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, err, stac) {
                                            Logger().e(
                                              'Failed to load image: $err $stac',
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
                                          errorBuilder:
                                              (context, error, stackTrace) =>
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
                                        if (isExisting) {
                                          _existingGambarUrls.removeAt(index);
                                          if (_existingGambarPaths.length >
                                              index) {
                                            _existingGambarPaths.removeAt(
                                              index,
                                            );
                                          }
                                        } else {
                                          final newIndex =
                                              index -
                                              _existingGambarUrls.length;
                                          _gambarBase64List.removeAt(newIndex);
                                          if (_gambarNames.length > newIndex) {
                                            _gambarNames.removeAt(newIndex);
                                          }
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
