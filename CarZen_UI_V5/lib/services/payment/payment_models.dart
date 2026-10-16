import 'package:flutter/widgets.dart';

/// Customer prefill details for Razorpay checkout.
class PaymentPrefill {
  final String? name;
  final String? email;
  final String? contact;

  const PaymentPrefill({
    this.name,
    this.email,
    this.contact,
  });
}

/// Result from launching Razorpay checkout on any platform.
sealed class RazorpayResult {
  const RazorpayResult();
}

/// Successful checkout returning Razorpay payment verification tokens.
class RazorpaySuccess extends RazorpayResult {
  final String paymentId;
  final String orderId;
  final String signature;

  const RazorpaySuccess({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  @override
  String toString() => 'RazorpaySuccess(paymentId: $paymentId, orderId: $orderId)';
}

/// Checkout failed or returned an error.
class RazorpayFailure extends RazorpayResult {
  final String message;

  const RazorpayFailure(this.message);

  @override
  String toString() => 'RazorpayFailure($message)';
}

/// User dismissed / closed the checkout modal without paying.
class RazorpayDismissed extends RazorpayResult {
  const RazorpayDismissed();

  @override
  String toString() => 'RazorpayDismissed()';
}

/// Unified interface for launching Razorpay Checkout across Web, Android, and iOS.
abstract class PaymentLauncher {
  Future<RazorpayResult> launchRazorpay({
    required BuildContext context,
    required String keyId,
    required String orderId,
    required int amountPaise,
    String? name,
    String? description,
    PaymentPrefill? prefill,
  });
}
