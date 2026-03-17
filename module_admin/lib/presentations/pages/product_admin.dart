import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_core/module_core.dart' as module_core;
import '../bloc/product_list_bloc.dart';

class ProductAdmin extends StatefulWidget {
  final Function(String?)? onDetailTap;
  const ProductAdmin({super.key, this.onDetailTap});

  @override
  State<ProductAdmin> createState() => _ProductAdminState();
}

class _ProductAdminState extends State<ProductAdmin> {
  @override
  void initState() {
    super.initState();
    context.read<ProductListBloc>().add(FetchAllProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onDetailTap?.call(null);
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          if (state is ProductListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductListLoaded) {
            if (state.products.isEmpty) {
              return const Center(child: Text('Tidak ada produk.'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                final imageUrl = (product.gambar.isNotEmpty) ? product.gambar.first : null;

                return InkWell(
                  onTap: (){
                    widget.onDetailTap?.call(product.uid);
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                                )
                              : Container(
                                  width: double.infinity,
                                  color: Colors.grey,
                                  child: Icon(Icons.image, size: 50),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.namaBrand,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              BlocBuilder<module_core.CurrencyCubit, module_core.CurrencyType>(
                                builder: (context, currencyState) {
                                  final formattedPrice = context.read<module_core.CurrencyCubit>().format(product.harga);
                                  return Text(
                                    formattedPrice,
                                    style: const TextStyle(color: Colors.green),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is ProductListError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}