import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'payment_models.dart';

PaymentLauncher createPaymentLauncher() => MobilePaymentLauncher();

class MobilePaymentLauncher implements PaymentLauncher {
  @override
  Future<RazorpayResult> launchRazorpay({
    required BuildContext context,
    required String keyId,
    required String orderId,
    required int amountPaise,
    String? name,
    String? description,
    PaymentPrefill? prefill,
  }) async {
    final result = await Navigator.of(context).push<RazorpayResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MobileCheckoutScreen(
          keyId: keyId,
          orderId: orderId,
          amountPaise: amountPaise,
          name: name,
          description: description,
          prefill: prefill,
        ),
      ),
    );
    return result ?? const RazorpayDismissed();
  }
}

/// Full-screen in-app WebView hosting Razorpay Checkout for Android and iOS.
class MobileCheckoutScreen extends StatefulWidget {
  final String keyId;
  final String orderId;
  final int amountPaise;
  final String? name;
  final String? description;
  final PaymentPrefill? prefill;

  const MobileCheckoutScreen({
    super.key,
    required this.keyId,
    required this.orderId,
    required this.amountPaise,
    this.name,
    this.description,
    this.prefill,
  });

  @override
  State<MobileCheckoutScreen> createState() => _MobileCheckoutScreenState();
}

class _MobileCheckoutScreenState extends State<MobileCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0B1329))
      ..addJavaScriptChannel(
        'RazorpayBridge',
        onMessageReceived: _onBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            final host = uri.host.toLowerCase();
            // Allow Razorpay, UPI, banks, card schemes and authentication gateways
            if (request.url.startsWith('data:') ||
                request.url.startsWith('about:') ||
                host.contains('razorpay') ||
                host.contains('rzp') ||
                host.contains('bank') ||
                host.contains('upi') ||
                host.contains('card') ||
                host.contains('payment') ||
                host.contains('auth')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _loadCheckoutHtml();
  }

  void _loadCheckoutHtml() {
    final title = widget.name ?? 'CarZen';
    final desc = widget.description ?? '';
    final pName = widget.prefill?.name ?? '';
    final pEmail = widget.prefill?.email ?? '';
    final pContact = widget.prefill?.contact ?? '';

    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: #0b1329;
      color: #ffffff;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100vh;
      text-align: center;
    }
    .spinner {
      border: 3px solid rgba(255, 255, 255, 0.2);
      border-radius: 50%;
      border-top: 3px solid #00d2ff;
      width: 36px;
      height: 36px;
      animation: spin 1s linear infinite;
      margin-bottom: 16px;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    p { font-size: 14px; color: #94a3b8; }
  </style>
  <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
</head>
<body>
  <div class="spinner"></div>
  <p>Connecting to secure Razorpay checkout...</p>

  <script>
    window.onload = function() {
      try {
        var options = {
          "key": "${widget.keyId}",
          "amount": "${widget.amountPaise}",
          "currency": "INR",
          "name": ${jsonEncode(title)},
          "description": ${jsonEncode(desc)},
          "order_id": "${widget.orderId}",
          "prefill": {
            "name": ${jsonEncode(pName)},
            "email": ${jsonEncode(pEmail)},
            "contact": ${jsonEncode(pContact)}
          },
          "theme": {
            "color": "#0b1329"
          },
          "handler": function (response) {
            RazorpayBridge.postMessage(JSON.stringify({
              type: 'success',
              payment_id: response.razorpay_payment_id,
              order_id: response.razorpay_order_id,
              signature: response.razorpay_signature
            }));
          },
          "modal": {
            "ondismiss": function() {
              RazorpayBridge.postMessage(JSON.stringify({ type: 'dismissed' }));
            }
          }
        };

        var rzp = new Razorpay(options);
        rzp.on('payment.failed', function (response) {
          var desc = (response.error && response.error.description) ? response.error.description : 'Payment failed';
          RazorpayBridge.postMessage(JSON.stringify({ type: 'failed', message: desc }));
        });
        rzp.open();
      } catch (err) {
        RazorpayBridge.postMessage(JSON.stringify({ type: 'failed', message: err.toString() }));
      }
    };
  </script>
</body>
</html>
''';

    _controller.loadHtmlString(html);
  }

  void _onBridgeMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final type = data['type'] as String?;
      if (type == 'success') {
        final paymentId = data['payment_id'] as String? ?? '';
        final orderId = data['order_id'] as String? ?? '';
        final signature = data['signature'] as String? ?? '';
        if (mounted) {
          Navigator.of(context).pop(RazorpaySuccess(
            paymentId: paymentId,
            orderId: orderId,
            signature: signature,
          ));
        }
      } else if (type == 'dismissed') {
        if (mounted) {
          Navigator.of(context).pop(const RazorpayDismissed());
        }
      } else if (type == 'failed') {
        final msg = data['message'] as String? ?? 'Payment failed';
        if (mounted) {
          Navigator.of(context).pop(RazorpayFailure(msg));
        }
      }
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop(const RazorpayFailure('Failed to parse checkout response'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1329),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1329),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Razorpay Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cancel payment',
          onPressed: () => Navigator.of(context).pop(const RazorpayDismissed()),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF00D2FF)),
            ),
        ],
      ),
    );
  }
}
