import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_core/module_core.dart'; // Memanggil SliderData & CachedNetworkImage dari module_core
import 'package:module_core/widget/animation/slider_animation.dart';
import 'package:module_core/widget/card/card.dart';
import 'package:module_core/widget/footer/footer.dart';
import 'package:module_user/domain/entities/slider.dart';
import '../cubit/home_cubit.dart';
import '../cubit/display_cubit.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);
  Timer? _timer;
  int _sliderCount = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    // Timer berjalan setiap 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_sliderCount > 0 && _pageController.hasClients) {
        int nextIndex = (_currentPageNotifier.value + 1) % _sliderCount;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung tinggi SliverAppBar dengan rasio 9:16
    final expandedHeight = MediaQuery.of(context).size.height * 0.8;
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: expandedHeight,
            pinned: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is HomeError) {
                    return Center(child: Text(state.message));
                  } else if (state is HomeLoaded) {
                    final sliders = state.sliders;
                    _sliderCount = sliders.length;

                    if (sliders.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada slider terbaru'),
                      );
                    }

                    // Use pre-instantiated widgets mapped to avoid dispose during swipe
                    // Or AutomaticKeepAlive if wrapping them
                    return PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        _currentPageNotifier.value = index;
                      },
                      children: List.generate(sliders.length, (index) {
                        return _SliderItem(
                          slider: sliders[index],
                          index: index,
                          pageNotifier: _currentPageNotifier,
                        );
                      }),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          BlocBuilder<DisplayCubit, DisplayState>(
            builder: (context, state) {
              if (state is DisplayLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is DisplayError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text(state.message)),
                );
              } else if (state is DisplaySuccess) {
                final sections = state.displaySections;
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: SliderAnimation(
                          direction: SlideDirection.up,
                          delay: const Duration(milliseconds: 500),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Welcome",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),

                              Text(
                                "To Our Store",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final section = sections[index - 1];
                    // Use a horizontal ListView for each section's products
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: SliderAnimation(
                              direction: SlideDirection.up,
                              child: Text(
                                section.judul,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: isMobile
                                ? 380
                                : 540, // Memberikan tinggi pasti agar performa tetap ringan (lazy-loading)
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: section.products.length,
                              itemBuilder: (context, pIndex) {
                                final product = section.products[pIndex];
                                final String discountPercentageStr =
                                    product.diskon > 0
                                    ? '${product.diskon}%'
                                    : '';
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: pIndex == 0 ? 16.0 : 8.0,
                                    right: pIndex == section.products.length - 1
                                        ? 16.0
                                        : 0.0,
                                  ),
                                  child: SliderAnimation(
                                    direction: SlideDirection.right,
                                    delay: Duration(
                                      milliseconds:
                                          500 * (pIndex > 5 ? 0 : pIndex),
                                    ), // Cascade effect untuk 5 item pertama
                                    child: MyCard(
                                      isMobile: isMobile,
                                      imageUrl: product.gambar.isNotEmpty
                                          ? product.gambar.first
                                          : 'https://picsum.photos/400/600',
                                      brand: product.namaBrand.isNotEmpty
                                          ? product.namaBrand
                                          : 'Brand Dummy',
                                      title: product.deskripsi.isNotEmpty
                                          ? product.deskripsi
                                          : 'No description',
                                      price:
                                          '\$ ${product.harga.toStringAsFixed(0)}',
                                      discountPrice: product.hargaDiskon > 0
                                          ? '\$ ${product.hargaDiskon.toStringAsFixed(0)}'
                                          : '',
                                      discountPercentage: discountPercentageStr,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }, childCount: sections.length + 1),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          const SliverToBoxAdapter(child: CustomFooter()),
        ],
      ),
    );
  }
}

class _SliderItem extends StatefulWidget {
  final SliderData slider;
  final int index;
  final ValueNotifier<int> pageNotifier;

  const _SliderItem({
    required this.slider,
    required this.index,
    required this.pageNotifier,
  });

  @override
  State<_SliderItem> createState() => _SliderItemState();
}

class _SliderItemState extends State<_SliderItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final slider = widget.slider;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Loading image dengan CachedNetworkImage
        CachedNetworkImage(
          imageUrl: slider.gambar,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              const Center(child: Icon(Icons.error, color: Colors.grey)),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
        ),
        // Overlay gelap di bawah untuk text
        Positioned(
          bottom: 100,
          left: 0,
          child: ValueListenableBuilder<int>(
            valueListenable: widget.pageNotifier,
            builder: (context, currentPage, buildAnim) {
              if (currentPage != widget.index) {
                return const Opacity(opacity: 0.0);
              }
              return Container(
                width: MediaQuery.of(context).size.width * 0.6,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    SliderAnimation(
                      direction: SlideDirection.up,
                      child: Text(
                        slider.judul,
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    if (slider.deskripsi.isNotEmpty) ...[
                      SliderAnimation(
                        direction: SlideDirection.up,
                        delay: const Duration(milliseconds: 500),
                        child: Text(
                          slider.deskripsi,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    SliderAnimation(
                      direction: SlideDirection.up,
                      delay: const Duration(milliseconds: 800),
                      child: Container(
                        width: 200,
                        height: 1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SliderAnimation(
                      direction: SlideDirection.up,
                      delay: const Duration(milliseconds: 1000),
                      child: Row(
                        children: [
                          Text(
                            "Checkout Now",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
