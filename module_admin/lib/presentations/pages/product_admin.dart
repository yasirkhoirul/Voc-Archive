import 'package:cached_network_image/cached_network_image.dart';
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
    final isMobile = MediaQuery.of(context).size.width < 900;
    final paddingHorizontal = isMobile ? 16.0 : 48.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 48.0, bottom: 24.0),
                      child: Center(
                        child: Text(
                          'Pengaturan Produk',
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 32,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onDetailTap?.call(null);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Tambah Produk'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Search Bar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                      child: Center(
                        child: SizedBox(
                          width: isMobile ? double.infinity : 500,
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari Produk',
                              suffixIcon: const Icon(Icons.search, size: 20),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.grey.shade400)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(color: Colors.black)
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              if (state is ProductListLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (state is ProductListLoaded && state.products.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('Tidak ada produk.')),
                ),
              if (state is ProductListLoaded && state.products.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 24.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 2 : 4,
                      crossAxisSpacing: isMobile ? 16 : 32,
                      mainAxisSpacing: isMobile ? 16 : 32,
                      childAspectRatio: isMobile ? 0.55 : 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = state.products[index];
                        final imageUrl = (product.gambar.isNotEmpty)
                            ? product.gambar.first
                            : null;

                        return InkWell(
                          onTap: () {
                            widget.onDetailTap?.call(product.uid);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: imageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              const Icon(Icons.broken_image, size: 50),
                                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        )
                                      : Container(
                                          width: double.infinity,
                                          color: Colors.grey,
                                          child: const Icon(Icons.image, size: 50),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.namaBrand.isNotEmpty ? product.namaBrand : 'Brand Dummy',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        product.deskripsi.isNotEmpty ? product.deskripsi : 'No description',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      BlocBuilder<
                                        module_core.CurrencyCubit,
                                        module_core.CurrencyState
                                      >(
                                        builder: (context, currencyState) {
                                          final formattedPrice = context
                                              .read<module_core.CurrencyCubit>()
                                              .format(product.harga);
                                          
                                          Widget priceWidget;
                                          if (product.hargaDiskon > 0) {
                                            final formattedDiscountPrice = context
                                              .read<module_core.CurrencyCubit>()
                                              .format(product.hargaDiskon);
                                              
                                            priceWidget = Wrap(
                                              alignment: WrapAlignment.center,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                Text(
                                                  formattedPrice,
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration.lineThrough,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(Icons.arrow_forward, size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  formattedDiscountPrice,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else {
                                            priceWidget = Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  formattedPrice,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          
                                          return priceWidget;
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
                      childCount: state.products.length,
                    ),
                  ),
                ),
              if (state is ProductListError)
                SliverFillRemaining(
                  child: Center(child: Text(state.message)),
                ),
            ],
          );
        },
      ),
    );
  }
}
