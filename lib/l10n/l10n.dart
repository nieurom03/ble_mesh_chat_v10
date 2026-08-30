// Convenience re-export + BuildContext extension.
// Import only this file anywhere in the app:
//   import '../l10n/l10n.dart';

export 'app_localizations.dart';

import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// Shorthand: context.l10n.someKey
  AppL10n get l10n => AppL10n.of(this);
}
