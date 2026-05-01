import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:module_core/enums/currency_enum.dart';
import 'package:module_core/utils/currency_converter.dart';
import 'package:module_core/shared_domain/shared_entities/product.dart';
import 'package:module_core/widget/card/card.dart';
import 'package:module_core/widget/footer/footer.dart';
import 'package:module_core/widget/snackbar.dart';
import 'package:module_user/presentation/bloc/catalog_bloc.dart';
import 'package:module_user/presentation/cubit/detail_product_cubit.dart';
import 'package:module_user/presentation/bloc/cart_bloc.dart';
import 'package:module_user/domain/entities/cart_item.dart';
import 'package:get_it/get_it.dart';

class DetailProduct extends StatelessWidget {
  final String uid;

  const DetailProduct({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DetailProductCubit>(
      create: (context) => GetIt.instance<DetailProductCubit>(),
      child: DetailProductView(uid: uid),
    );
  }
}

class DetailProductView extends StatefulWidget {
  final String uid;

  const DetailProductView({super.key, required this.uid});

  @override
  State<DetailProductView> createState() => _DetailProductViewState();
}

class _DetailProductViewState extends State<DetailProductView> {
  String? _selectedSize;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Memanggil API dengan Cubit ketika inisialisasi awal
    context.read<DetailProductCubit>().fetchProduct(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('Detail Produk', 'Detail Product'),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.isEmpty) {
                return IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  onPressed: () => context.pushNamed('cart'),
                );
              }
              return IconButton(
                icon: Stack(
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
                          '',
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
                onPressed: () => context.pushNamed('cart'),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<DetailProductCubit, DetailProductState>(
        builder: (context, state) {
          if (state is DetailProductLoading || state is DetailProductInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DetailProductError) {
            return Center(child: Text(state.message));
          } else if (state is DetailProductLoaded) {
            final product = state.product;

            return SingleChildScrollView(
              child: Column(
                children: [
                  isMobile
                      ? _buildMobileLayout(product, context)
                      : _buildDesktopLayout(product, context),
                  _buildRecommendedProducts(context, isMobile, product.uid),
                  const SizedBox(height: 48),
                  const CustomFooter(),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMobileLayout(Product product, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final availableSizes = product.sizes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildImageSlider(product),
          const SizedBox(height: 16),
          _buildImageIndicator(product),
          const SizedBox(height: 16),
          Text(
            product.namaBrand.isNotEmpty ? product.namaBrand : 'Unknown Brand',
            style: textTheme.displayLarge,
          ),
          const SizedBox(height: 16),
          _buildPriceAndCart(product, textTheme, context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('Mata Uang (IDR/USD)', 'Currency (IDR/USD)'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              BlocBuilder<CurrencyCubit, CurrencyState>(
                builder: (context, state) {
                  return Switch(
                    value: state.currencyType == CurrencyType.usd,
                    onChanged: (value) {
                      context.read<CurrencyCubit>().toggleCurrency();
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildDescriptions(product, textTheme),
          const SizedBox(height: 24),
          _buildSizeOptions(product, availableSizes, textTheme),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(Product product, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final availableSizes = product.sizes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Kiri
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildImageSlider(product),
                const SizedBox(height: 16),
                _buildImageIndicator(product),
              ],
            ),
          ),
          const SizedBox(width: 48),
          // Detail Kanan
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.namaBrand.isNotEmpty
                      ? product.namaBrand
                      : 'Unknown Brand',
                  style: textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                BlocBuilder<CurrencyCubit, CurrencyState>(
                  builder: (context, currencyState) {
                    return Text(
                      context.read<CurrencyCubit>().format(product.harga),
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('Mata Uang (IDR/USD)', 'Currency (IDR/USD)'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    BlocBuilder<CurrencyCubit, CurrencyState>(
                      builder: (context, state) {
                        return Switch(
                          value: state.currencyType == CurrencyType.usd,
                          onChanged: (value) {
                            context.read<CurrencyCubit>().toggleCurrency();
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildDescriptions(product, textTheme)),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildSizeOptions(
                        product,
                        availableSizes,
                        textTheme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      // Tombol Keranjang
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          onPressed: () {
                            if (_selectedSize == null) {
                              AppSnackbar.onInfo(
                                context,
                                'Silakan pilih ukuran terlebih dahulu!',
                              );
                            } else {
                              context.read<CartBloc>().add(
                                AddToCart(
                                  CartItem(
                                    id: '-',
                                    productId: product.uid,
                                    productName: product.deskripsi,
                                    brandName: product.namaBrand,
                                    imageUrls: product.gambar,
                                    selectedSize: _selectedSize!,
                                    price: product.hargaDiskon > 0
                                        ? product.hargaDiskon
                                        : product.harga,
                                  ),
                                ),
                              );
                              AppSnackbar.onSuccess(
                                context,
                                'Berhasil ditambahkan ke keranjang',
                              );
                            }
                          },
                          child: Text(
                            context.tr('+ Keranjang', '+ Chart'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Tombol Beli Sekarang
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (_selectedSize == null) {
                              AppSnackbar.onInfo(
                                context,
                                'Silakan pilih ukuran terlebih dahulu!',
                              );
                            } else {
                              context.read<CartBloc>().add(
                                AddToCart(
                                  CartItem(
                                    id: '-',
                                    productId: product.uid,
                                    productName: product.deskripsi,
                                    brandName: product.namaBrand,
                                    imageUrls: product.gambar,
                                    selectedSize: _selectedSize!,
                                    price: product.hargaDiskon > 0
                                        ? product.hargaDiskon
                                        : product.harga,
                                  ),
                                ),
                              );
                              context.pushNamed('checkout');
                            }
                          },
                          child: Text(
                            context.tr('Beli Sekarang', 'Buy Now'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlider(Product product) {
    final ismobile = MediaQuery.of(context).size.width < 900;
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PageView.builder(
          controller: _pageController,
          itemCount: product.gambar.isEmpty ? 1 : product.gambar.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final imageUrl = product.gambar.isNotEmpty
                ? product.gambar[index]
                : 'https://picsum.photos/600/800';
            return CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: ismobile ? 200 : 632,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageIndicator(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            if (_currentImageIndex > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            }
          },
        ),
        Text(
          '${_currentImageIndex + 1}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            if (product.gambar.isNotEmpty &&
                _currentImageIndex < product.gambar.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPriceAndCart(
    Product product,
    TextTheme textTheme,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<CurrencyCubit, CurrencyState>(
          builder: (context, currencyState) {
            return Text(
              context.read<CurrencyCubit>().format(product.harga),
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: Colors.black),
                ),
                onPressed: () {
                  if (_selectedSize == null) {
                    AppSnackbar.onInfo(
                      context,
                      'Silakan pilih ukuran terlebih dahulu!',
                    );
                  } else {
                    context.read<CartBloc>().add(
                      AddToCart(
                        CartItem(
                          id: '-',
                          productId: product.uid,
                          productName: product.deskripsi,
                          brandName: product.namaBrand,
                          imageUrls: product.gambar,
                          selectedSize: _selectedSize!,
                          price: product.hargaDiskon > 0
                              ? product.hargaDiskon
                              : product.harga,
                        ),
                      ),
                    );
                    AppSnackbar.onSuccess(
                      context,
                      'Berhasil ditambahkan ke keranjang',
                    );
                  }
                },
                child: Text(
                  context.tr('+ Keranjang', '+ Chart'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_selectedSize == null) {
                    AppSnackbar.onInfo(
                      context,
                      'Silakan pilih ukuran terlebih dahulu!',
                    );
                  } else {
                    context.read<CartBloc>().add(
                      AddToCart(
                        CartItem(
                          id: '-',
                          productId: product.uid,
                          productName: product.deskripsi,
                          brandName: product.namaBrand,
                          imageUrls: product.gambar,
                          selectedSize: _selectedSize!,
                          price: product.hargaDiskon > 0
                              ? product.hargaDiskon
                              : product.harga,
                        ),
                      ),
                    );
                    context.pushNamed('checkout');
                  }
                },
                child: Text(
                  context.tr('Beli Sekarang', 'Buy Now'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptions(Product product, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('Item', 'Item'), style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          product.deskripsi.isNotEmpty
              ? product.deskripsi
              : 'Tidak ada deskripsi',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        Text(
          context.tr('Description', 'Description'),
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          product.detail.isNotEmpty
              ? product.detail
              : 'Tidak ada detail khusus',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSizeOptions(
    Product product,
    List<MapEntry<String, int>> availableSizes,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('Pilihan Ukuran', 'Size Options'),
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: availableSizes.map((entry) {
            final size = entry.key;
            final stock = entry.value;
            final isAvailable = stock > 0;
            final isSelected = _selectedSize == size;

            return InkWell(
              onTap: isAvailable
                  ? () {
                      setState(() {
                        _selectedSize = size;
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? Colors.black
                        : isAvailable
                        ? Colors.grey
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  color: isSelected
                      ? Colors.black
                      : isAvailable
                      ? Colors.white
                      : Colors.grey.shade200,
                ),
                child: Text(
                  size.toUpperCase(),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isAvailable
                        ? Colors.black
                        : Colors.grey,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (_selectedSize != null)
          Text(
            context.tr(
              'Stok tersedia: ${product.sizes[_selectedSize]}',
              'Stock available: ${product.sizes[_selectedSize]}',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendedProducts(
    BuildContext context,
    bool isMobile,
    String currentUid,
  ) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        if (state is CatalogLoading || state is CatalogInitial) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CatalogLoaded) {
          final allProducts = state.products;
          // Filter out current product
          final recommendations = allProducts
              .where((p) => p.uid != currentUid)
              .toList();

          if (recommendations.isEmpty) return const SizedBox.shrink();

          final displayCount = isMobile ? 2 : 4;
          final items = recommendations.take(displayCount).toList();

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Text(
                  context.tr('Barang yang serupa', 'Similar Items'),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                Row(
                  children: List.generate(items.length, (index) {
                    final p = items[index];
                    final isLast = index == items.length - 1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isLast ? 0 : 16.0),
                        child: AspectRatio(
                          aspectRatio: isMobile ? 0.55 : 0.6,
                          child: GestureDetector(
                            onTap: p.totalStok == 0
                                ? null
                                : () {
                                    context.goNamed(
                                      'productDetail',
                                      pathParameters: {'id': p.uid},
                                    );
                                    // Refresh page for new item
                                    context
                                        .read<DetailProductCubit>()
                                        .fetchProduct(p.uid);
                                  },
                            child: MyCard(
                              isSoldOut: p.totalStok == 0,
                              isMobile: isMobile,
                              imageUrl: p.gambar.isNotEmpty
                                  ? p.gambar.first
                                  : 'https://picsum.photos/400/600',
                              brand: p.namaBrand.isNotEmpty
                                  ? p.namaBrand
                                  : 'Unknown Brand',
                              title: p.deskripsi.isNotEmpty
                                  ? p.deskripsi
                                  : 'No description',
                              price: p.harga,
                              discountPrice: p.hargaDiskon,
                              discountPercentage: p.diskon > 0
                                  ? '${p.diskon}%'
                                  : '',
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
