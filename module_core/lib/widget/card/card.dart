import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_core/module_core.dart';
import '../../utils/currency_converter.dart';

class MyCard extends StatefulWidget {
  final bool isMobile;
  final String imageUrl;
  final String brand;
  final String title;
  final num price;
  final num? discountPrice;
  final String? discountPercentage;
  const MyCard({
    super.key,
    required this.imageUrl,
    required this.brand,
    required this.title,
    required this.price,
    required this.isMobile,
    this.discountPrice,
    this.discountPercentage,
  });

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  bool _isHovering = false;

  bool get _hasDiscount {
    if (widget.discountPercentage == null ||
        widget.discountPercentage == '0' ||
        widget.discountPercentage == '0%') {
      return false;
    }
    if (widget.discountPrice == null ||
        widget.discountPrice! <= 0 ||
        widget.price == widget.discountPrice) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0.0,
          _isHovering ? -8.0 : 0.0,
          0.0,
        ),
        child: SizedBox(
          width: widget.isMobile ? 200 : 300,
          height: widget.isMobile ? 400 : 540,
          child: Stack(
            children: [
              Card(
                elevation: _isHovering ? 8 : 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    spacing: 14,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: CachedNetworkImage(
                            imageUrl: widget.imageUrl,
                            memCacheWidth: 200,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 200),
                            placeholder: (context, url) => Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.error, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: widget.isMobile ? 0 : 14,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.brand,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(color: Colors.black),
                                    ),
                                    Text(
                                      widget.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w100,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Render formatted price based on CurrencyCubit
                            Builder(
                              builder: (context) {
                                // context.select memastikan rebuild hanya terjadi jika nilai ini berubah
                                final _ = context.select<CurrencyCubit, String>(
                                  (cubit) => cubit.state.toString(),
                                );
                                final cubit = context.read<CurrencyCubit>();
                                final formattedPrice = cubit.format(
                                  widget.price,
                                );
                                final formattedDiscount =
                                    widget.discountPrice != null
                                    ? cubit.format(widget.discountPrice!)
                                    : null;

                                if (_hasDiscount) {
                                  return Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        formattedPrice,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                      ),
                                      const Icon(
                                        Icons.arrow_right_alt,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                      Text(
                                        formattedDiscount!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  );
                                }
                                return Text(
                                  formattedPrice,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_hasDiscount)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      widget.discountPercentage!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
