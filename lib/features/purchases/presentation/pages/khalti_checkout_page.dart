import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens Khalti's hosted checkout page inside an in-app WebView. When the
/// page tries to navigate to our return_url, we intercept it (so it never
/// actually tries to load it) and pop this screen with the resulting
/// status string ("Completed", "User canceled", etc.), or "Cancelled" if
/// the user backs out manually.
///
/// IMPORTANT: this must match the backend's actual return_url — which is
/// `${FRONTEND_URL}/purchases/callback` (the web app's real callback page,
/// set in purchase.service.ts's initiateKhaltiPurchase). It doesn't need
/// to be reachable from the phone — we only pattern-match the URL before
/// the WebView tries to load it.
class KhaltiCheckoutPage extends StatefulWidget {
  final String paymentUrl;
  final String returnUrlPrefix;

  const KhaltiCheckoutPage({
    super.key,
    required this.paymentUrl,
    this.returnUrlPrefix = 'http://localhost:3000/purchases/callback',
  });

  @override
  State<KhaltiCheckoutPage> createState() => _KhaltiCheckoutPageState();
}

class _KhaltiCheckoutPageState extends State<KhaltiCheckoutPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            if (request.url.startsWith(widget.returnUrlPrefix)) {
              final uri = Uri.parse(request.url);
              final status = uri.queryParameters['status'];
              Navigator.pop(context, status);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khalti Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: () => Navigator.pop(context, 'Cancelled'),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}