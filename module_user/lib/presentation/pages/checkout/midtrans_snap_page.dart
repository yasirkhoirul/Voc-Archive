import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/checkout_bloc.dart';

class MidtransSnapPage extends StatefulWidget {
  final String redirectUrl;
  final String orderId;

  const MidtransSnapPage({
    super.key,
    required this.redirectUrl,
    required this.orderId,
  });

  @override
  State<MidtransSnapPage> createState() => _MidtransSnapPageState();
}

class _MidtransSnapPageState extends State<MidtransSnapPage> {
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
            onPageStarted: (_) {
              setState(() => _isLoading = true);
            },
            onPageFinished: (_) {
              setState(() => _isLoading = false);
            },
            onNavigationRequest: (request) {
              final url = request.url;
              // Detect when Midtrans redirects to finish/unfinish/error
              if (url.contains('transaction_status=settlement') ||
                  url.contains('transaction_status=capture') ||
                  url.contains('status_code=200')) {
                _onPaymentFinished('settlement');
                return NavigationDecision.prevent;
              }
              if (url.contains('transaction_status=pending') ||
                  url.contains('status_code=201')) {
                _onPaymentFinished('pending');
                return NavigationDecision.prevent;
              }
              if (url.contains('transaction_status=deny') ||
                  url.contains('transaction_status=cancel') ||
                  url.contains('transaction_status=expire') ||
                  url.contains('status_code=202')) {
                _onPaymentFinished('failed');
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.redirectUrl));
    } else {
      _launchInWeb();
    }
  }

  Future<void> _launchInWeb() async {
    final uri = Uri.parse(widget.redirectUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch ${widget.redirectUrl}');
    }
  }

  void _onPaymentFinished(String status) {
    // Check actual status from server
    context.read<CheckoutBloc>().add(
          CheckPaymentStatusEvent(widget.orderId),
        );
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
          'Payment',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // User cancelled — check status anyway
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
                    'Please complete the payment in the new tab.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _launchInWeb,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Open Payment Page'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      _onPaymentFinished('pending');
                    },
                    child: const Text(
                      'I have completed the payment',
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
