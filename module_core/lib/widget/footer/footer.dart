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

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _TermsDialog(),
    );
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

    final Widget contactUs = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Contact Us',
          style: TextStyle(
            fontSize: isMobile ? 13.0 : 14.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _launchUrl('mailto:vocarchive2004@gmail.com'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mail_outline_rounded,
                size: isMobile ? 14.0 : 16.0,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                'vocarchive2004@gmail.com',
                style: TextStyle(
                  fontSize: isMobile ? 12.0 : 13.0,
                  color: Colors.black54,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final Widget bottomBar = Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          const Divider(color: Colors.black12, thickness: 1.0, height: 1.0),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                '© ${DateTime.now().year} voc.archive. All rights reserved.',
                style: TextStyle(
                  fontSize: isMobile ? 10.0 : 11.0,
                  color: Colors.black38,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '·',
                style: TextStyle(
                  fontSize: isMobile ? 10.0 : 11.0,
                  color: Colors.black26,
                ),
              ),
              GestureDetector(
                onTap: () => _showTermsDialog(context),
                child: Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontSize: isMobile ? 10.0 : 11.0,
                    color: Colors.black54,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black38,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Divider(color: Colors.black12, thickness: 1.0, height: 1.0),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: isMobile
                ? Column(
                    children: [
                      socialIcons,
                      const SizedBox(height: 24.0),
                      logo,
                      const SizedBox(height: 24.0),
                      contactUs,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [logo, contactUs, socialIcons],
                  ),
          ),
          bottomBar,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Terms & Conditions Dialog
// ─────────────────────────────────────────────

class _TermsDialog extends StatelessWidget {
  const _TermsDialog();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double dialogWidth =
        isMobile ? double.infinity : MediaQuery.of(context).size.width * 0.6;
    const double maxHeight = 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 80,
        vertical: 40,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'TERMS & CONDITIONS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _TermsTitle('voc.archive'),
                    SizedBox(height: 20),
                    _TermsSection(
                      number: '1',
                      title: 'CONDITIONS OF USE',
                      body:
                          'voc.archive is offered to you, the user, conditioned on your acceptance of the terms, conditions and notices contained or incorporated by reference herein. Your use of this Site constitutes your agreement to all such terms. If you do not agree, you must exit the Site immediately.',
                    ),
                    _TermsSection(
                      number: '2',
                      title: 'MODIFICATION OF THE SITE AND PRICES',
                      body:
                          'We reserve the right to change, modify, or update prices and content at any time without prior notice. voc.archive has the right to adjust prices from time to time and refuse any order if a pricing mistake occurs.',
                    ),
                    _TermsSection(
                      number: '3',
                      title: 'SIGN UP & ACCOUNT SECURITY',
                      body:
                          'You are required to sign up to make a purchase by inserting your username and password. You are solely responsible for maintaining the confidentiality of your account details and any activity that occurs under your account.',
                    ),
                    _TermsSection(
                      number: '4',
                      title: 'PAYMENTS (IDR & USD)',
                      body:
                          'We provide two distinct payment methods to accommodate our customers:',
                      bullets: [
                        'Domestic (IDR): All Indonesian Rupiah transactions are processed automatically via Midtrans. Orders are confirmed instantly after a successful payment.',
                        'International (USD): Payments in US Dollars are processed via PayPal. For these transactions, users are required to upload a transfer receipt/screenshot within the app for manual verification before the order is processed.',
                      ],
                    ),
                    _TermsSection(
                      number: '5',
                      title: 'PRODUCT DESCRIPTIONS',
                      body:
                          'We always try our best to display the information and colors of our products as accurately as possible. However, we cannot guarantee that your monitor\'s display of any color will be 100% accurate, as it depends on your monitor quality.',
                    ),
                    _TermsSection(
                      number: '6',
                      title: 'CONDITIONS OF RETURNS & REFUNDS',
                      body:
                          'In accordance with our commitment to quality, returns are governed by the following rules:',
                      bullets: [
                        'Eligibility: Returns are only accepted if the item received does not match the provided photos and descriptions on our platform.',
                        'Mandatory Proof: Users must provide an uninterrupted unboxing video as primary evidence. Without a clear unboxing video, the return request cannot be processed.',
                        'Time Limit: Items must be reported and returned within 2×24 hours from the date it is received.',
                        'Condition: Items must be in original condition with all tags attached.',
                        'Non-Returnable: Sale items are not eligible for returns.',
                        'Shipping: Shipping and handling charges are non-refundable.',
                      ],
                    ),
                    _TermsSection(
                      number: '7',
                      title: 'PRIVACY POLICY',
                      body:
                          'Your information is safe with us. Any information you submit will not be misused, abused, or sold to third parties; we only use your personal information to complete your order.',
                    ),
                    _TermsSection(
                      number: '8',
                      title: 'DISPUTE RESOLUTION',
                      body:
                          'In the event of a dispute, parties agree to engage in informal negotiations for a period of at least 30 days before initiating any formal proceedings. If unresolved, the dispute shall be settled through arbitration in Yogyakarta/Jakarta, Indonesia, using the Indonesian language.',
                    ),
                    _TermsSection(
                      number: '9',
                      title: 'APPLICABLE LAWS',
                      body:
                          'These Terms and Conditions are governed by the law in force in Indonesia.',
                    ),
                  ],
                ),
              ),
            ),
            // Footer button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('I Understand'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsTitle extends StatelessWidget {
  final String text;
  const _TermsTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final List<String> bullets;

  const _TermsSection({
    required this.number,
    required this.title,
    required this.body,
    this.bullets = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. $title',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
          if (bullets.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(fontSize: 13, height: 1.6),
                    ),
                    Expanded(
                      child: Text(
                        b,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
