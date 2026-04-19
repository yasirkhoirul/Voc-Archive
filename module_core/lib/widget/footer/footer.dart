import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../logo/voc_logo.dart';
import '../../utils/app_assets.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    final Widget logo = VocLogo(
      imageWidth: isMobile ? 57.0 : 114.0,
      imageHeight: isMobile ? 70.0 : 140.0,
      title: 'Voc Archive',
      fontWeight: FontWeight.w600,
      fontSize: 16.0,
    );

    final Widget socialIcons = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: SvgPicture.asset(AppAssets.ig, width: 36.0, height: 36.0),
          onPressed: () => _launchUrl(
            'https://www.instagram.com/voc.archive?igsh=MWVyZGJzdWQwOHA2Nw%3D%3D&utm_source=qr',
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: SvgPicture.asset(AppAssets.tiktok, width: 36.0, height: 36.0),
          onPressed: () => _launchUrl(
            'https://www.tiktok.com/@voc.archive_?_r=1&_t=ZS-94MHph06kyb',
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Garis pemisah atas
          const Divider(color: Colors.black12, thickness: 1.0, height: 1.0),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: isMobile
                ? Column(
                    children: [socialIcons, const SizedBox(height: 24.0), logo],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [logo, socialIcons],
                  ),
          ),
        ],
      ),
    );
  }
}
