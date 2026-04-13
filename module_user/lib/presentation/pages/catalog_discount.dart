import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:module_core/utils/search_notifier.dart';
import 'package:module_core/widget/card/card.dart';
import 'package:module_core/widget/footer/footer.dart';
import 'package:module_user/presentation/bloc/cart_bloc.dart';
import '../cubit/catalog_discount_cubit.dart';
import '../cubit/catalog_discount_state.dart';

class CatalogDiscount extends StatefulWidget {
  const CatalogDiscount({super.key});

  @override
  State<CatalogDiscount> createState() => _CatalogDiscountState();
}

class _CatalogDiscountState extends State<CatalogDiscount> {
  @override
  void initState() {
    super.initState();
    searchNotifier.addListener(_onSearchChanged);
    context.read<CatalogDiscountCubit>().fetchDiscountProducts();
  }

  void _onSearchChanged() {
    if (mounted) {
      context.read<CatalogDiscountCubit>().fetchDiscountProducts(query: searchNotifier.value);
    }
  }

  @override
  void dispose() {
    searchNotifier.removeListener(_onSearchChanged);
    super.dispose();
  }

  Widget _buildDesktopGrid(CatalogDiscountState state) {
    final bool isTablet =
        MediaQuery.of(context).size.width >= 901 &&
        MediaQuery.of(context).size.width < 1600;
    
    if (state is CatalogDiscountLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    } else if (state is CatalogDiscountError) {
      return Center(child: Text(state.message));
    } else if (state is CatalogDiscountLoaded) {
      final products = state.products;
      if (products.isEmpty) {
        return const Center(child: Text("No discount products found"));
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 4 : 6,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.5,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return InkWell(
            onTap: () {
              context.goNamed(
                'productDetail',
                pathParameters: {'id': product.uid},
              );
            },
            child: MyCard(
              isMobile: false,
              imageUrl: product.gambar.isNotEmpty
                  ? product.gambar.first
                  : 'https://picsum.photos/400/600',
              brand: product.namaBrand.isNotEmpty
                  ? product.namaBrand
                  : 'Brand Dummy',
              title: product.deskripsi.isNotEmpty
                  ? product.deskripsi
                  : 'No description',
              price: '\$ ${product.harga.toStringAsFixed(0)}',
              discountPrice: product.hargaDiskon > 0
                  ? '\$ ${product.hargaDiskon.toStringAsFixed(0)}'
                  : '',
              discountPercentage: product.diskon > 0
                  ? '${product.diskon}%'
                  : '',
            ),
          );
        },
      );
    }
    return const Center(child: Text("Initializing..."));
  }

  Widget _buildMobileGrid(CatalogDiscountState state) {
    if (state is CatalogDiscountLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    } else if (state is CatalogDiscountError) {
      return SliverFillRemaining(child: Center(child: Text(state.message)));
    } else if (state is CatalogDiscountLoaded) {
      final products = state.products;
      if (products.isEmpty) {
        return const SliverFillRemaining(
          child: Center(child: Text("No discount products found")),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.5,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = products[index];
            return InkWell(
              onTap: () {
                context.goNamed(
                  'productDetail',
                  pathParameters: {'id': product.uid},
                );
              },
              child: MyCard(
                isMobile: true,
                imageUrl: product.gambar.isNotEmpty
                    ? product.gambar.first
                    : 'https://picsum.photos/400/600',
                brand: product.namaBrand.isNotEmpty
                    ? product.namaBrand
                    : 'Brand Dummy',
                title: product.deskripsi.isNotEmpty
                    ? product.deskripsi
                    : 'No description',
                price: '\$ ${product.harga.toStringAsFixed(0)}',
                discountPrice: product.hargaDiskon > 0
                    ? '\$ ${product.hargaDiskon.toStringAsFixed(0)}'
                    : '',
                discountPercentage: product.diskon > 0
                    ? '${product.diskon}%'
                    : '',
              ),
            );
          }, childCount: products.length),
        ),
      );
    }
    return const SliverFillRemaining(
      child: Center(child: Text("Initializing...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Stack(
      children: [
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                sliver: SliverToBoxAdapter(
                  child: isMobile
                      ? TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: const Icon(Icons.search),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        )
                      : const Row(
                          children: [
                            Text(
                              'Discount Products',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              if (!isMobile)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverToBoxAdapter(
                    child: BlocBuilder<CatalogDiscountCubit, CatalogDiscountState>(
                      builder: (context, state) {
                        return _buildDesktopGrid(state);
                      },
                    ),
                  ),
                )
              else
                BlocBuilder<CatalogDiscountCubit, CatalogDiscountState>(
                  builder: (context, state) {
                    return _buildMobileGrid(state);
                  },
                ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 48.0),
                  child: CustomFooter(),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32.0, right: 24.0),
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state.isEmpty) return const SizedBox.shrink();
                return FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    context.goNamed('cart');
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${state.items.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
        ),
      ],
    );
  }
}
