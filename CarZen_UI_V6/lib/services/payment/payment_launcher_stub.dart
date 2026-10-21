import 'package:flutter/widgets.dart';
import 'payment_models.dart';

PaymentLauncher createPaymentLauncher() => _StubPaymentLauncher();

class _StubPaymentLauncher implements PaymentLauncher {
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
    return const RazorpayFailure('Razorpay is not supported on this platform.');
  }
}
