import 'package:flutter/material.dart';
import '../../utils/app_assets.dart';

class VocLogo extends StatelessWidget {
  final double imageWidth;
  final double imageHeight;
  final String title;
  final double? fontSize;
  final FontWeight fontWeight;

  const VocLogo({
    super.key,
    this.imageWidth = 40.0,
    this.imageHeight = 40.0,
    this.title = 'voc.archive',
    this.fontSize,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          // child: Image.asset(
          //   AppAssets.logo,
          //   width: imageWidth,
          //   height: imageHeight,
          //   fit: BoxFit.cover,
          // ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: fontWeight,
                fontSize: fontSize,
              ),
        ),
      ],
    );
  }
}
