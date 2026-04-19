import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_core/utils/currency_converter.dart';
import 'package:go_router/go_router.dart';
import 'package:module_core/utils/search_notifier.dart';
import 'package:module_core/widget/animation/slider_animation.dart';
import 'package:module_core/widget/card/card.dart';
import 'package:module_core/widget/footer/footer.dart';
import 'package:module_user/presentation/bloc/cart_bloc.dart';
import '../bloc/catalog_bloc.dart';
import '../widget/filter.dart';

class SoldOutUser extends StatefulWidget {
  const SoldOutUser({super.key});

  @override
  State<SoldOutUser> createState() => _SoldOutUserState();
}

class _SoldOutUserState extends State<SoldOutUser>
    with SingleTickerProviderStateMixin {
  bool _isFilterOpen = true; // For desktop

  Timer? _debounce;

  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _marginAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    searchNotifier.addListener(_onSearchChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _widthAnimation = Tween<double>(begin: 0, end: 250).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _marginAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
          ),
        );

    _animationController.value = 1.0;
  }

  List<String> _selectedTypes = [];
  double? _minPrice;
  double? _maxPrice;

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<CatalogBloc>().add(
          FetchCatalogProducts(
            query: searchNotifier.value,
            types: _selectedTypes,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
          ),
        );
      }
    });
  }

  void _onFilterSet(List<String> types, double? minPrice, double? maxPrice) {
    setState(() {
      _selectedTypes = types;
      _minPrice = minPrice;
      _maxPrice = maxPrice;
    });
    _onSearchChanged();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchNotifier.removeListener(_onSearchChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFilter() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
    });
    if (_isFilterOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _showMobileFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                controller: scrollController,
                child: MobileFilterContent(onSet: _onFilterSet),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopGrid(CatalogState state) {
    final bool isTablet =
        MediaQuery.of(context).size.width >= 901 &&
        MediaQuery.of(context).size.width < 1600;
    if (state is CatalogLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (state is CatalogError) {
      return SliverFillRemaining(child: Center(child: Text(state.message)));
    } else if (state is CatalogLoaded) {
      final products = state.products;
      if (products.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Text(context.tr("Tidak ada produk", "No products found")),
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 4 : 6,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.5,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = products[index];
            return SliderAnimation(
              direction: SlideDirection.up,
              delay: Duration(milliseconds: 100 * (index % (isTablet ? 4 : 6))),
              child: InkWell(
                onTap: product.totalStok == 0
                    ? null
                    : () {
                        context.goNamed(
                          'productDetail',
                          pathParameters: {'id': product.uid},
                        );
                      },
                child: MyCard(
                  isSoldOut: product.totalStok == 0,
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
                  price: product.harga,
                  discountPrice: product.hargaDiskon,
                  discountPercentage: product.diskon > 0
                      ? '${product.diskon}%'
                      : '',
                ),
              ),
            );
          }, childCount: products.length),
        ),
      );
    }
    return SliverFillRemaining(
      child: Center(child: Text(context.tr("Memuat...", "Initializing..."))),
    );
  }

  Widget _buildMobileGrid(CatalogState state) {
    if (state is CatalogLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (state is CatalogError) {
      return SliverFillRemaining(child: Center(child: Text(state.message)));
    } else if (state is CatalogLoaded) {
      final products = state.products;
      if (products.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Text(context.tr("Tidak ada produk", "No products found")),
          ),
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
            return SliderAnimation(
              direction: SlideDirection.up,
              delay: Duration(milliseconds: 100 * (index % 2)),
              child: InkWell(
                onTap: product.totalStok == 0
                    ? null
                    : () {
                        context.goNamed(
                          'productDetail',
                          pathParameters: {'id': product.uid},
                        );
                      },
                child: MyCard(
                  isSoldOut: product.totalStok == 0,
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
                  price: product.harga,
                  discountPrice: product.hargaDiskon,
                  discountPercentage: product.diskon > 0
                      ? '${product.diskon}%'
                      : '',
                ),
              ),
            );
          }, childCount: products.length),
        ),
      );
    }
    return SliverFillRemaining(
      child: Center(child: Text(context.tr("Memuat...", "Initializing..."))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    final headerSliver = SliverPadding(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
      sliver: SliverToBoxAdapter(
        child: isMobile
            ? TextField(
                onSubmitted: (value) {
                  searchNotifier.value = value;
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_alt),
                    onPressed: () => _showMobileFilter(context),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              )
            : Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: !_isFilterOpen
                        ? Row(
                            key: const ValueKey('filter_btn'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.filter_alt),
                                onPressed: _toggleFilter,
                              ),
                              const SizedBox(width: 8),
                            ],
                          )
                        : const SizedBox.shrink(key: ValueKey('empty_btn')),
                  ),
                  const Text(
                    'Catalog & Filtip',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );

    final footerSliver = const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 48.0),
        child: CustomFooter(),
      ),
    );

    return Stack(
      children: [
        Scaffold(
          body: isMobile
              ? CustomScrollView(
                  slivers: [
                    headerSliver,
                    BlocBuilder<CatalogBloc, CatalogState>(
                      builder: (context, state) {
                        return _buildMobileGrid(state);
                      },
                    ),
                    footerSliver,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Desktop filter side panel with auto-fit smooth animation
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Container(
                          width: _widthAnimation.value,
                          margin: EdgeInsets.only(
                            right: _marginAnimation.value,
                          ),
                          child: ClipRect(
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                child: SizedBox(width: 250, child: child),
                              ),
                            ),
                          ),
                        );
                      },
                      child: DesktopFilter(
                        onToggle: _toggleFilter,
                        animation: _animationController,
                        onSet: _onFilterSet,
                      ),
                    ),
                    // Grid
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          headerSliver,
                          BlocBuilder<CatalogBloc, CatalogState>(
                            builder: (context, state) {
                              return _buildDesktopGrid(state);
                            },
                          ),
                          footerSliver,
                        ],
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
