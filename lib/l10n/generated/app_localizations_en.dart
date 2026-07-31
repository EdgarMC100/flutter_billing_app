// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsAppBarTitle => 'Settings';

  @override
  String get settingsManagementSectionTitle => 'Management';

  @override
  String get settingsProductsTitle => 'Products';

  @override
  String get settingsProductsSubtitle => 'Manage stock and barcodes';

  @override
  String get settingsShopDetailsTitle => 'Shop Details';

  @override
  String get settingsShopDetailsSubtitle => 'Edit business info & address';

  @override
  String get settingsHardwareSectionTitle => 'Hardware';

  @override
  String get settingsPrinterConnectedSnackbar => 'Connected to printer';

  @override
  String get settingsPrintDeviceTitle => 'Print Device';

  @override
  String get settingsPrinterConnectedFallback => 'Printer connected';

  @override
  String get settingsNoPrinterConnected => 'No printer connected';

  @override
  String get settingsConnectedBadge => 'CONNECTED';

  @override
  String get settingsPrinterHelpText =>
      'To connect a new device, tap on the Settings gear to pair in phone\'s Bluetooth settings, then return and hit Refresh.';

  @override
  String get settingsPreferencesSectionTitle => 'Preferences';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageDialogTitle => 'Select Language';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get homeProductNotFoundTitle => 'Product Not Found';

  @override
  String homeProductNotFoundMessage(String barcode) {
    return 'No product matches barcode \"$barcode\".\nWould you like to add it to your inventory?';
  }

  @override
  String get commonAddProduct => 'Add Product';

  @override
  String get homeReviewOrderButton => 'Review Order';

  @override
  String get homeCameraOffTitle => 'Camera is turned off';

  @override
  String get homeCameraOffMessage =>
      'Turn on your camera to start scanning barcodes and items automatically.';

  @override
  String get homeTurnOnCameraButton => 'Turn on Camera';

  @override
  String get homeScannedItemsTitle => 'Scanned Items';

  @override
  String homeItemsTotalCount(int count) {
    return '$count items total';
  }

  @override
  String get homeTotalPriceLabel => 'TOTAL PRICE';

  @override
  String get homeEmptyCartTitle => 'List is empty';

  @override
  String get homeEmptyCartMessage =>
      'Scanned items will appear here as you scan them with the camera above.';

  @override
  String get commonDelete => 'Delete';

  @override
  String get productListAppBarTitle => 'Product Management';

  @override
  String get productBarcodeHint => 'Scan or enter barcode';

  @override
  String get productBarcodeRequiredError => 'Please enter a barcode';

  @override
  String get productScannerHint => 'Tap the icon to open camera scanner';

  @override
  String productListErrorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get productListEmptyTitle => 'No products found. Add some!';

  @override
  String get productListNoSearchResults => 'No products match your search.';

  @override
  String get productListDeleteDialogTitle => 'Delete Product';

  @override
  String productListDeleteDialogMessage(String productName) {
    return 'Are you sure you want to delete $productName?';
  }

  @override
  String get productFormBarcodeLabel => 'Barcode';

  @override
  String get productFormNameLabel => 'Product Name';

  @override
  String get productFormNameHint => 'e.g. Basmati Rice';

  @override
  String get productNameRequiredError => 'Please enter a name';

  @override
  String get productFormPriceLabel => 'Price';

  @override
  String get productFormPriceHint => '0.00';

  @override
  String get productPriceRequiredError => 'Please enter a price';

  @override
  String get productPriceInvalidError => 'Please enter a valid number';

  @override
  String get productPriceNegativeError => 'Price cannot be negative';

  @override
  String productBarcodeExistsError(String barcode) {
    return 'Product with barcode \"$barcode\" already exists!';
  }

  @override
  String get editProductAppBarTitle => 'Edit Product';

  @override
  String get editProductBarcodeFieldLabel => 'BARCODE';

  @override
  String get editProductSaveButton => 'Save Changes';

  @override
  String get checkoutAppBarTitle => 'Checkout';

  @override
  String get checkoutPrintedSuccessfully => 'Printed successfully';

  @override
  String get checkoutColumnProductName => 'Product Name';

  @override
  String get checkoutColumnPrice => 'Price';

  @override
  String get checkoutColumnTotal => 'Total';

  @override
  String get checkoutScanToPay => 'Scan to Pay';

  @override
  String get checkoutGrandTotalLabel => 'GRAND TOTAL';

  @override
  String get checkoutShopDetailsNotLoaded => 'Shop details not loaded';

  @override
  String get checkoutPrintReceiptButton => 'Print Receipt';

  @override
  String get scannerAppBarTitle => 'Scan Barcode';

  @override
  String get scannerAlignHint => 'Align barcode within frame';

  @override
  String get commonRequiredError => 'Required';

  @override
  String get shopDetailsAppBarTitle => 'Shop Details';

  @override
  String get shopDetailsSavedSnackbar => 'Shop details saved!';

  @override
  String get shopDetailsGeneralInfoSectionTitle => 'General Information';

  @override
  String get shopDetailsSectionSubtitle =>
      'These details will appear on your digital and printed receipts.';

  @override
  String get shopDetailsNameLabel => 'Shop Name';

  @override
  String get shopDetailsAddress1Label => 'Address Line 1';

  @override
  String get shopDetailsAddress2Label => 'Address Line 2 (Optional)';

  @override
  String get shopDetailsPhoneLabel => 'Phone Number';

  @override
  String get shopDetailsUpiIdLabel => 'UPI ID';

  @override
  String get shopDetailsFooterTextLabel => 'Receipt Footer Text';

  @override
  String get shopDetailsFooterMaxChars => 'Max 150 chars';

  @override
  String get shopDetailsSaveButton => 'Save Details';

  @override
  String get productAddedSuccessMessage => 'Product added successfully';

  @override
  String get productUpdatedSuccessMessage => 'Product updated successfully';

  @override
  String get productDeletedSuccessMessage => 'Product deleted successfully';

  @override
  String get settingsPrinterNoPairedDevices => 'No paired devices found.';

  @override
  String get settingsPrinterNoDeviceConnectable =>
      'Could not connect to any paired device.';

  @override
  String get settingsPrinterConnectionFailed => 'Failed to connect to printer';

  @override
  String get billingAutoConnectFailed => 'Failed to auto-connect to printer!';

  @override
  String get billingNoPrinterConfigured =>
      'Printer not connected & no saved printer found!';

  @override
  String billingPrintFailedError(String error) {
    return 'Print failed: $error';
  }

  @override
  String get receiptColumnItem => 'Item';

  @override
  String get receiptColumnPrice => 'Price';

  @override
  String get receiptColumnTotal => 'Total';

  @override
  String get receiptTotalPrefix => 'TOTAL';
}
