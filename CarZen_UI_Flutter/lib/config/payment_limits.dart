/// Payment limits and rules for CarZen V4.
class PaymentLimits {
  PaymentLimits._();

  /// Ayush's Razorpay account limit per order is ₹50,000 (5,000,000 paise).
  /// Razorpay orders exceeding this threshold fail at creation or checkout.
  static const num maxOnlineInr = 50000;

  /// Whether an amount is eligible for online payment via Razorpay.
  static bool canPayOnline(num amount) => amount > 0 && amount <= maxOnlineInr;

  /// Helper message displayed when an order/request exceeds ₹50,000.
  static const String serviceLimitExceededMessage =
      'Online payment is available up to ₹50,000. For this amount please choose "Pay cash" at the service center.';

  static const String carOrderLimitExceededMessage =
      'Online payment is available up to ₹50,000. For this amount please pay by cash / bank transfer arranged with the seller.';
}
