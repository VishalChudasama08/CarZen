import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/widgets.dart';
import 'payment_models.dart';

PaymentLauncher createPaymentLauncher() => WebPaymentLauncher();

@JS('Razorpay')
extension type RazorpayJs._(JSObject _) implements JSObject {
  external RazorpayJs(JSObject options);
  external void open();
  external void on(JSString event, JSFunction handler);
}

class WebPaymentLauncher implements PaymentLauncher {
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
    if (!globalContext.has('Razorpay')) {
      return const RazorpayFailure(
        'Razorpay checkout script is not loaded. Please refresh the page.',
      );
    }

    final completer = Completer<RazorpayResult>();

    final options = JSObject();
    options['key'] = keyId.toJS;
    options['order_id'] = orderId.toJS;
    options['amount'] = amountPaise.toJS;
    options['currency'] = 'INR'.toJS;
    options['name'] = (name ?? 'CarZen').toJS;
    if (description != null && description.isNotEmpty) {
      options['description'] = description.toJS;
    }

    final prefillObj = JSObject();
    if (prefill?.name != null && prefill!.name!.isNotEmpty) {
      prefillObj['name'] = prefill.name!.toJS;
    }
    if (prefill?.email != null && prefill!.email!.isNotEmpty) {
      prefillObj['email'] = prefill.email!.toJS;
    }
    if (prefill?.contact != null && prefill!.contact!.isNotEmpty) {
      prefillObj['contact'] = prefill.contact!.toJS;
    }
    options['prefill'] = prefillObj;

    // Success handler
    options['handler'] = ((JSObject resp) {
      final pId = (resp['razorpay_payment_id'] as JSString?)?.toDart ?? '';
      final oId = (resp['razorpay_order_id'] as JSString?)?.toDart ?? '';
      final sig = (resp['razorpay_signature'] as JSString?)?.toDart ?? '';
      if (!completer.isCompleted) {
        completer.complete(RazorpaySuccess(
          paymentId: pId,
          orderId: oId,
          signature: sig,
        ));
      }
    }).toJS;

    // Modal dismiss handler
    final modal = JSObject();
    modal['ondismiss'] = (() {
      if (!completer.isCompleted) {
        completer.complete(const RazorpayDismissed());
      }
    }).toJS;
    options['modal'] = modal;

    try {
      final rzp = RazorpayJs(options);
      rzp.on('payment.failed'.toJS, ((JSObject err) {
        final errObj = err['error'] as JSObject?;
        final desc = (errObj?['description'] as JSString?)?.toDart ?? 'Payment failed';
        if (!completer.isCompleted) {
          completer.complete(RazorpayFailure(desc));
        }
      }).toJS);
      rzp.open();
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(RazorpayFailure(e.toString()));
      }
    }

    return completer.future;
  }
}
