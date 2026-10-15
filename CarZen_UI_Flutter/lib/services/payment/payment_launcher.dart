import 'payment_launcher_stub.dart'
    if (dart.library.js_interop) 'payment_launcher_web.dart'
    if (dart.library.io) 'payment_launcher_mobile.dart';
import 'payment_models.dart';

export 'payment_models.dart';

/// Returns the platform-appropriate [PaymentLauncher].
PaymentLauncher getPaymentLauncher() => createPaymentLauncher();
