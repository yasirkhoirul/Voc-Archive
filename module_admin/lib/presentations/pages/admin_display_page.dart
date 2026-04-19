import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_admin/domain/entities/create_display_input.dart';
import 'package:module_admin/presentations/bloc/display_mutation_bloc.dart';
import 'package:module_admin/presentations/bloc/product_list_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminDisplayPage extends StatefulWidget {
  const AdminDisplayPage({super.key});

  @override
  State<AdminDisplayPage> createState() => _AdminDisplayPageState();
}

class _AdminDisplayPageState extends State<AdminDisplayPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final Set<String> _selectedProductIds = {};

  @override
  void initState() {
    super.initState();
    context.read<ProductListBloc>().add(FetchAllProducts());
  }

  @override
  void dispose() {
    _judulController.dispose();
    super.dispose();
  }

  void _confirmDelete(String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Display'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus display section ini?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<DisplayMutationBloc>().add(
                DeleteDisplaySubmitted(uid),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DisplayMutationBloc, DisplayMutationState>(
      listener: (context, state) {
        if (state is DisplayMutationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil menyimpan perubahan!'),
              backgroundColor: Colors.green,
            ),
          );
          _judulController.clear();
          setState(() {
            _selectedProductIds.clear();
          });
        } else if (state is DisplayMutationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is DisplayMutationLoading;

        return Stack(
          children: [
            Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48.0,
                  vertical: 32.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Pengaturan Display (Section)',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tambah Display Baru',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _judulController,
                              decoration: InputDecoration(
                                labelText:
                                    'Judul Display (Contoh: Weekly Offers)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Pilih Produk untuk Ditampilkan:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: BlocBuilder<ProductListBloc, ProductListState>(
                                builder: (context, productState) {
                                  if (productState is ProductListLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                      ),
                                    );
                                  } else if (productState
                                      is ProductListLoaded) {
                                    if (productState.products.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'Tidak ada produk tersedia. Tambah produk dulu.',
                                        ),
                                      );
                                    }
                                    return ListView.separated(
                                      itemCount: productState.products.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final product =
                                            productState.products[index];
                                        final isSelected = _selectedProductIds
                                            .contains(product.uid);
                                        final imageUrl =
                                            product.gambar.isNotEmpty
                                            ? product.gambar.first
                                            : null;

                                        return CheckboxListTile(
                                          title: Text(
                                            product.namaBrand,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(product.type),
                                          value: isSelected,
                                          activeColor: Colors.black,
                                          secondary: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4.0,
                                            ),
                                            child: imageUrl != null
                                                ? CachedNetworkImage(
                                                    imageUrl: imageUrl,
                                                    width: 50,
                                                    height: 50,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (_, __, ___) =>
                                                        const Icon(
                                                          Icons.broken_image,
                                                        ),
                                                  )
                                                : Container(
                                                    width: 50,
                                                    height: 50,
                                                    color: Colors.grey.shade200,
                                                    child: const Icon(
                                                      Icons.image,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                          ),
                                          onChanged: (bool? checked) {
                                            setState(() {
                                              if (checked == true) {
                                                _selectedProductIds.add(
                                                  product.uid,
                                                );
                                              } else {
                                                _selectedProductIds.remove(
                                                  product.uid,
                                                );
                                              }
                                            });
                                          },
                                        );
                                      },
                                    );
                                  } else if (productState is ProductListError) {
                                    return Center(
                                      child: Text(productState.message),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    if (_selectedProductIds.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Pilih setidaknya 1 produk!',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    context.read<DisplayMutationBloc>().add(
                                      CreateDisplaySubmitted(
                                        CreateDisplayInput(
                                          judul: _judulController.text,
                                          productId: _selectedProductIds
                                              .toList(),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                ),
                                child: const Text(
                                  'Simpan Display',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      const Text(
                        'Preview Display Saat Ini',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('display_items')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          final docs = snapshot.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.view_carousel_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Belum ada display yang ditambahkan.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final data =
                                  docs[index].data() as Map<String, dynamic>;
                              final uid = data['uid'] ?? docs[index].id;
                              final productIds = List<String>.from(
                                data['product_ids'] ?? [],
                              );

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16.0),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.black,
                                    child: Text(
                                      '${productIds.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      data['judul'] ?? 'Tanpa Judul',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Menampilkan ${productIds.length} Produk',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Hapus Display Section',
                                    onPressed: () => _confirmDelete(uid),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 48), // Spacing bawah untuk scroll
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.black),
                          SizedBox(height: 16),
                          Text(
                            'Memproses...',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
