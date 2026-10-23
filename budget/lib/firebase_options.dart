// Yubai local-only edition: upstream production credentials are not bundled.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
      'Yubai is local-only. Cloud services have not been configured.');
}
