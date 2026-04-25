import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:module_core/widget/animation/slider_animation.dart';
import 'package:module_core/widget/footer/footer.dart';
import 'package:module_user/presentation/cubit/about_us_cubit.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  void initState() {
    super.initState();
    context.read<AboutUsCubitUser>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AboutUsCubitUser, AboutUsUserState>(
      builder: (context, state) {
        if (state is AboutUsUserLoading || state is AboutUsUserInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }

        if (state is AboutUsUserError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat konten',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () => context.read<AboutUsCubitUser>().load(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = state as AboutUsUserLoaded;
        final expandedHeight = MediaQuery.of(context).size.height * 0.8;
        final bool isMobile = MediaQuery.of(context).size.width < 900;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Hero header
              SliverAppBar(
                expandedHeight: expandedHeight,
                pinned: false,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hero Image — dynamic dari Firestore
                      data.heroImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: data.heroImage,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: Colors.grey.shade200,
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                    child: Icon(Icons.image, size: 48)),
                              ),
                            )
                          : Container(color: Colors.grey.shade300),

                      // Gradient overlay
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black87, Colors.transparent],
                          ),
                        ),
                      ),

                      // Caption
                      Positioned(
                        bottom: 100,
                        left: 0,
                        child: Container(
                          width: isMobile
                              ? MediaQuery.of(context).size.width * 0.9
                              : MediaQuery.of(context).size.width * 0.6,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 24.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SliderAnimation(
                                direction: SlideDirection.up,
                                child: Text(
                                  data.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SliderAnimation(
                                direction: SlideDirection.up,
                                delay: const Duration(milliseconds: 300),
                                child: Text(
                                  data.subtitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SliderAnimation(
                                direction: SlideDirection.up,
                                delay: const Duration(milliseconds: 500),
                                child: Text(
                                  data.location,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SliderAnimation(
                                direction: SlideDirection.up,
                                delay: const Duration(milliseconds: 700),
                                child: Container(
                                  width: 200,
                                  height: 1,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content body
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24.0 : 48.0,
                    vertical: 48.0,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final Widget leftContent = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SliderAnimation(
                                direction: SlideDirection.up,
                                child: Text(
                                  data.bodyTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              SliderAnimation(
                                direction: SlideDirection.up,
                                delay: const Duration(milliseconds: 400),
                                child: Text(
                                  data.bodyText,
                                  style: const TextStyle(height: 1.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // 2 gallery images bottom-left
                          if (data.galleryImages.length >= 2)
                            SizedBox(
                              height: 200,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SliderAnimation(
                                      direction: SlideDirection.up,
                                      delay: const Duration(milliseconds: 800),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: CachedNetworkImage(
                                          imageUrl: data.galleryImages[0],
                                          fit: BoxFit.cover,
                                          height: double.infinity,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SliderAnimation(
                                      direction: SlideDirection.up,
                                      delay:
                                          const Duration(milliseconds: 1000),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: CachedNetworkImage(
                                          imageUrl: data.galleryImages[1],
                                          fit: BoxFit.cover,
                                          height: double.infinity,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );

                      Widget buildImage(String url, int delayMs) {
                        return SliderAnimation(
                          direction: SlideDirection.up,
                          delay: Duration(milliseconds: delayMs),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                            ),
                          ),
                        );
                      }

                      Widget buildRightRow(
                        String url1,
                        String url2,
                        int baseDelay,
                      ) {
                        return Row(
                          children: [
                            Expanded(child: buildImage(url1, baseDelay)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: buildImage(url2, baseDelay + 200)),
                          ],
                        );
                      }

                      final g = data.galleryImages;
                      final img2 = g.length > 2 ? g[2] : '';
                      final img3 = g.length > 3 ? g[3] : '';
                      final img4 = g.length > 4 ? g[4] : '';
                      final img5 = g.length > 5 ? g[5] : '';

                      final Widget rightContent = Column(
                        children: [
                          if (g.length >= 4)
                            if (isMobile)
                              AspectRatio(
                                aspectRatio: 1.5,
                                child: buildRightRow(img2, img3, 200),
                              )
                            else
                              Expanded(
                                child: buildRightRow(img2, img3, 200),
                              ),
                          if (g.length >= 6) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: buildRightRow(img4, img5, 600),
                            ),
                          ],
                        ],
                      );

                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            leftContent,
                            if (g.length >= 4) ...[
                              const SizedBox(height: 48),
                              rightContent,
                            ],
                          ],
                        );
                      } else {
                        final double columnWidth =
                            (constraints.maxWidth - 48) / 2;
                        return Stack(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: columnWidth, child: leftContent),
                                const SizedBox(width: 48),
                                SizedBox(width: columnWidth),
                              ],
                            ),
                            if (g.length >= 4)
                              Positioned(
                                left: columnWidth + 48,
                                top: 0,
                                bottom: 0,
                                width: columnWidth,
                                child: rightContent,
                              ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: CustomFooter()),
            ],
          ),
        );
      },
    );
  }
}
