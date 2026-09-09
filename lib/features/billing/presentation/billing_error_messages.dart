import '../../../l10n/generated/app_localizations.dart';
import 'bloc/billing_bloc.dart';

/// Resolves a stable [BillingErrorCode] (emitted by [BillingBloc], which has no
/// `BuildContext`) into a localized, user-facing string. Shared by every page
/// that surfaces billing errors (checkout via HomePage, and the sale detail
/// page's reprint action).
String billingErrorMessage(AppLocalizations l10n, String code) {
  if (code == BillingErrorCode.autoConnectFailed) {
    return l10n.billingAutoConnectFailed;
  }
  if (code == BillingErrorCode.noPrinterConfigured) {
    return l10n.billingNoPrinterConfigured;
  }
  if (code == BillingErrorCode.saleSaveFailed) {
    return l10n.checkoutSaleSaveFailed;
  }
  if (code.startsWith(BillingErrorCode.printFailedPrefix)) {
    final rawError = code.substring(BillingErrorCode.printFailedPrefix.length);
    return l10n.billingPrintFailedError(rawError);
  }
  return code;
}
