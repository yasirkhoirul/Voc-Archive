import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_core/widget/snackbar.dart';
import '../../domain/entities/create_product_input.dart';
import '../bloc/product_mutation_bloc.dart';

class ProductSetting extends StatefulWidget {
  const ProductSetting({super.key});

  @override
  State<ProductSetting> createState() => _ProductSettingState();
}

class _ProductSettingState extends State<ProductSetting> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _hargaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _detailController = TextEditingController();
  final _diskonController = TextEditingController();
  final _stokController = TextEditingController();
  final _gambarController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    _detailController.dispose();
    _diskonController.dispose();
    _stokController.dispose();
    _gambarController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final input = CreateProductInput(
        namaBrand: _brandController.text.trim(),
        harga: double.tryParse(_hargaController.text.trim()) ?? 0.0,
        deskripsi: _deskripsiController.text.trim(),
        detail: _detailController.text.trim(),
        diskon: double.tryParse(_diskonController.text.trim()),
        gambar: [_gambarController.text.trim()], // Sederhana: 1 gambar
        sizes: {
          'onesize': int.tryParse(_stokController.text.trim()) ?? 0,
        },
      );

      context.read<ProductMutationBloc>().add(CreateProductSubmitted(input));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
      ),
      body: BlocConsumer<ProductMutationBloc, ProductMutationState>(
        listener: (context, state) {
          if (state is ProductMutationSuccess) {
            AppSnackbar.onSuccess(context, 'Produk berhasil ditambahkan!');
            _formKey.currentState?.reset();
            _brandController.clear();
            _hargaController.clear();
            _deskripsiController.clear();
            _detailController.clear();
            _diskonController.clear();
            _stokController.clear();
            _gambarController.clear();
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
                    decoration: const InputDecoration(labelText: 'Nama Brand', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hargaController,
                    decoration: const InputDecoration(labelText: 'Harga', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _deskripsiController,
                    decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _detailController,
                    decoration: const InputDecoration(labelText: 'Detail Produk', border: OutlineInputBorder()),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _diskonController,
                    decoration: const InputDecoration(labelText: 'Diskon (Nominal/Opsional)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stokController,
                    decoration: const InputDecoration(labelText: 'Total Stok (Onesize)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _gambarController,
                    decoration: const InputDecoration(labelText: 'URL Gambar', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(context),
                      child: isLoading
                          ? const CircularProgressIndicator()
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