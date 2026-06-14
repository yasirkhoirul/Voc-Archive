import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/checkout_bloc.dart';

class XenditPaymentPage extends StatefulWidget {
  final String invoiceUrl;
  final String orderId;

  const XenditPaymentPage({
    super.key,
    required this.invoiceUrl,
    required this.orderId,
  });

  @override
  State<XenditPaymentPage> createState() => _XenditPaymentPageState();
}

class _XenditPaymentPageState extends State<XenditPaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => setState(() => _isLoading = true),
            onPageFinished: (_) => setState(() => _isLoading = false),
            onNavigationRequest: (request) {
              final url = request.url;
              // Detect Xendit success redirect
              if (url.contains('payment-success') ||
                  url.contains('status=PAID') ||
                  url.contains('status=paid')) {
                _onPaymentFinished('settlement');
                return NavigationDecision.prevent;
              }
              // Detect Xendit failure/cancel redirect
              if (url.contains('payment-failed') ||
                  url.contains('status=EXPIRED') ||
                  url.contains('status=expired') ||
                  url.contains('status=FAILED')) {
                _onPaymentFinished('expire');
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.invoiceUrl));
    } else {
      _launchInWeb();
    }
  }

  Future<void> _launchInWeb() async {
    final uri = Uri.parse(widget.invoiceUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch ${widget.invoiceUrl}');
    }
  }

  void _onPaymentFinished(String status) {
    context.read<CheckoutBloc>().add(CheckPaymentStatusEvent(widget.orderId));
    Navigator.of(context).pop(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Pembayaran Xendit',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<CheckoutBloc>().add(
              CheckPaymentStatusEvent(widget.orderId),
            );
            Navigator.of(context).pop('pending');
          },
        ),
      ),
      body: kIsWeb
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Selesaikan pembayaran di tab baru.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _launchInWeb,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Buka Halaman Pembayaran'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _onPaymentFinished('pending'),
                    child: const Text(
                      'Saya sudah menyelesaikan pembayaran',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
              ],
            ),
    );
  }
}
