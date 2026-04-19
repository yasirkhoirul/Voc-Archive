import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_core/module_core.dart' as module_core;
import 'package:module_core/widget/card/card.dart';
import '../bloc/product_list_bloc.dart';

class CatalogAdminSoldOut extends StatefulWidget {
  const CatalogAdminSoldOut({super.key});

  @override
  State<CatalogAdminSoldOut> createState() => _CatalogAdminSoldOutState();
}

class _CatalogAdminSoldOutState extends State<CatalogAdminSoldOut> {
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
      appBar: AppBar(
        title: const Text(
          'Sold Out Produk',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          if (state is ProductListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductListLoaded) {
            final soldOutProducts = state.products
                .where((p) => p.totalStok == 0)
                .toList();
            if (soldOutProducts.isEmpty) {
              return const Center(
                child: Text('Tidak ada produk yang sold out.'),
              );
            }

            return GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: paddingHorizontal,
                vertical: 24.0,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 4,
                crossAxisSpacing: isMobile ? 16 : 32,
                mainAxisSpacing: isMobile ? 16 : 32,
                childAspectRatio: isMobile ? 0.55 : 0.65,
              ),
              itemCount: soldOutProducts.length,
              itemBuilder: (context, index) {
                final product = soldOutProducts[index];
                final imageUrl = (product.gambar.isNotEmpty)
                    ? product.gambar.first
                    : '';

                return MyCard(
                  isMobile: isMobile,
                  imageUrl: imageUrl,
                  brand: product.namaBrand,
                  title: product.deskripsi.isNotEmpty
                      ? product.deskripsi
                      : 'No description',
                  price: product.harga,
                  discountPrice: product.hargaDiskon > 0
                      ? product.hargaDiskon
                      : null,
                  discountPercentage: '%',
                  isSoldOut: true,
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
