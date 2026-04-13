import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:module_core/widget/animation/slider_animation.dart';
import 'package:module_core/widget/footer/footer.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    final expandedHeight = MediaQuery.of(context).size.height * 0.8;
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // "App Bar" berupa static header 1 gambar
          SliverAppBar(
            expandedHeight: expandedHeight,
            pinned: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Image
                  CachedNetworkImage(
                    imageUrl:
                        'https://picsum.photos/1920/1080', // Ganti dengan URL/Asset image asli toko
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error, color: Colors.grey),
                    ),
                  ),
                  // Gradient Overlay agar text putih terbaca jelas
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
                              "About Us",
                              style: Theme.of(context).textTheme.displayLarge
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
                              "voc.archive",
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SliderAnimation(
                            direction: SlideDirection.up,
                            delay: const Duration(milliseconds: 500),
                            child: Text(
                              "BASED IN INDONESIA",
                              style: Theme.of(context).textTheme.bodySmall
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

          // Content section di bawah header
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
                          Text(
                            "voc.archive",
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            "WORLDWIDE SHIPPING\n6-17 days arrive with tracking number",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "NO REFUND / NO RETRUN\nPlease carefully check the description and the measurements posted for the item you're interested in Take a look at all the photos (defects, tags, etc).\nif you have doubts please don't buy.\n\nDon't worry about customs tax or fees. We always declare as \"GIFT\" and put the value item \$ 10 - 40 \$",
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "ALL SALES ARE FINAL",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // 2 gambar kecil di kiri bawah teks
                        SizedBox(
                          height: 200, // Beri ukuran tetap untuk memastikan sama tinggi dengan Row gambar di kanannya
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: 'https://picsum.photos/400/300?1', // Placeholder
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: 'https://picsum.photos/400/300?2', // Placeholder
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    Widget buildImage(String url) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                      );
                    }

                    Widget buildRightRow(String url1, String url2) {
                      return Row(
                        children: [
                          Expanded(child: buildImage(url1)),
                          const SizedBox(width: 16),
                          Expanded(child: buildImage(url2)),
                        ],
                      );
                    }

                    final Widget rightContent = Column(
                      children: [
                        if (isMobile)
                          AspectRatio(
                            aspectRatio: 1.5, // Menentukan tinggi secara proporsional untuk mobile
                            child: buildRightRow(
                              'https://picsum.photos/400/600?3',
                              'https://picsum.photos/400/600?4',
                            ),
                          )
                        else
                          Expanded(
                            child: buildRightRow(
                              'https://picsum.photos/400/600?3',
                              'https://picsum.photos/400/600?4',
                            ),
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200, // Tinggi dipastikan sama persis dengan yang di kiri bawah
                          child: buildRightRow(
                            'https://picsum.photos/400/300?5',
                            'https://picsum.photos/400/300?6',
                          ),
                        ),
                      ],
                    );
                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        leftContent,
                        const SizedBox(height: 48),
                        rightContent,
                      ],
                    );
                  } else {
                    final double columnWidth = (constraints.maxWidth - 48) / 2;
                    return Stack(
                      children: [
                        // Left content is the basis for height calculation
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: columnWidth, child: leftContent),
                            const SizedBox(width: 48),
                            SizedBox(width: columnWidth), // empty space for layout logic
                          ],
                        ),
                        // Right content forcibly stretching/squeezing completely to match left height
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

          // Panggil footer yg telah dibuat di paling bawah
          const SliverToBoxAdapter(child: CustomFooter()),
        ],
      ),
    );
  }
}
