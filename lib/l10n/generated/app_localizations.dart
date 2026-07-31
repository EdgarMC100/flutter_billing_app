import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// App bar title of the settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsAppBarTitle;

  /// Section header grouping Products and Shop Details rows
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get settingsManagementSectionTitle;

  /// Title of the row that navigates to product management
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get settingsProductsTitle;

  /// Subtitle of the Products row
  ///
  /// In en, this message translates to:
  /// **'Manage stock and barcodes'**
  String get settingsProductsSubtitle;

  /// Title of the row that navigates to shop details
  ///
  /// In en, this message translates to:
  /// **'Shop Details'**
  String get settingsShopDetailsTitle;

  /// Subtitle of the Shop Details row
  ///
  /// In en, this message translates to:
  /// **'Edit business info & address'**
  String get settingsShopDetailsSubtitle;

  /// Section header grouping printer settings
  ///
  /// In en, this message translates to:
  /// **'Hardware'**
  String get settingsHardwareSectionTitle;

  /// Snackbar shown when a Bluetooth printer connects successfully
  ///
  /// In en, this message translates to:
  /// **'Connected to printer'**
  String get settingsPrinterConnectedSnackbar;

  /// Title of the printer row in the Hardware section
  ///
  /// In en, this message translates to:
  /// **'Print Device'**
  String get settingsPrintDeviceTitle;

  /// Subtitle shown when a printer is connected but has no reported name
  ///
  /// In en, this message translates to:
  /// **'Printer connected'**
  String get settingsPrinterConnectedFallback;

  /// Subtitle shown when no printer is connected
  ///
  /// In en, this message translates to:
  /// **'No printer connected'**
  String get settingsNoPrinterConnected;

  /// Small badge shown next to the printer name when connected
  ///
  /// In en, this message translates to:
  /// **'CONNECTED'**
  String get settingsConnectedBadge;

  /// Helper text under the printer row explaining how to pair a new device
  ///
  /// In en, this message translates to:
  /// **'To connect a new device, tap on the Settings gear to pair in phone\'s Bluetooth settings, then return and hit Refresh.'**
  String get settingsPrinterHelpText;

  /// Section header in Settings grouping user preferences like language
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferencesSectionTitle;

  /// Title of the Language row in the Settings Preferences section
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// Title of the dialog used to pick the app language
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settingsLanguageDialogTitle;

  /// Display name for the English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEnglish;

  /// Display name for the Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageNameSpanish;

  /// Generic label for a Cancel button/action, reused across dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Title of the dialog shown when a scanned barcode has no matching product
  ///
  /// In en, this message translates to:
  /// **'Product Not Found'**
  String get homeProductNotFoundTitle;

  /// Body of the product-not-found dialog
  ///
  /// In en, this message translates to:
  /// **'No product matches barcode \"{barcode}\".\nWould you like to add it to your inventory?'**
  String homeProductNotFoundMessage(String barcode);

  /// Generic label for adding a product, reused as a dialog action, app bar title, and submit button
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get commonAddProduct;

  /// Bottom sheet button label to proceed to checkout
  ///
  /// In en, this message translates to:
  /// **'Review Order'**
  String get homeReviewOrderButton;

  /// Heading shown in the scanner section when the camera is off
  ///
  /// In en, this message translates to:
  /// **'Camera is turned off'**
  String get homeCameraOffTitle;

  /// Explanatory text shown under homeCameraOffTitle
  ///
  /// In en, this message translates to:
  /// **'Turn on your camera to start scanning barcodes and items automatically.'**
  String get homeCameraOffMessage;

  /// Button label to re-enable the camera
  ///
  /// In en, this message translates to:
  /// **'Turn on Camera'**
  String get homeTurnOnCameraButton;

  /// Header title above the cart list on the home page
  ///
  /// In en, this message translates to:
  /// **'Scanned Items'**
  String get homeScannedItemsTitle;

  /// Subtitle showing total quantity of scanned items
  ///
  /// In en, this message translates to:
  /// **'{count} items total'**
  String homeItemsTotalCount(int count);

  /// Label above the cart total amount
  ///
  /// In en, this message translates to:
  /// **'TOTAL PRICE'**
  String get homeTotalPriceLabel;

  /// Heading shown when the cart has no items
  ///
  /// In en, this message translates to:
  /// **'List is empty'**
  String get homeEmptyCartTitle;

  /// Explanatory text shown under homeEmptyCartTitle
  ///
  /// In en, this message translates to:
  /// **'Scanned items will appear here as you scan them with the camera above.'**
  String get homeEmptyCartMessage;

  /// Generic label for a Delete button/action, reused across dialogs
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// App bar title of the product list/management page
  ///
  /// In en, this message translates to:
  /// **'Product Management'**
  String get productListAppBarTitle;

  /// Hint text of a barcode field, reused on the product list search bar and product form
  ///
  /// In en, this message translates to:
  /// **'Scan or enter barcode'**
  String get productBarcodeHint;

  /// Validation message when a barcode field is submitted empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a barcode'**
  String get productBarcodeRequiredError;

  /// Helper text explaining the scanner icon, reused on the product list and product form
  ///
  /// In en, this message translates to:
  /// **'Tap the icon to open camera scanner'**
  String get productScannerHint;

  /// Prefix shown before a bloc error message on the product list page
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String productListErrorPrefix(String message);

  /// Shown when the product list is empty
  ///
  /// In en, this message translates to:
  /// **'No products found. Add some!'**
  String get productListEmptyTitle;

  /// Shown when a search query filters out all products
  ///
  /// In en, this message translates to:
  /// **'No products match your search.'**
  String get productListNoSearchResults;

  /// Title of the confirm-delete dialog on the product list page
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get productListDeleteDialogTitle;

  /// Body of the confirm-delete dialog on the product list page
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {productName}?'**
  String productListDeleteDialogMessage(String productName);

  /// Field label for the barcode input on the add product form
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get productFormBarcodeLabel;

  /// Field label for the product name input, reused on add and edit product forms
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productFormNameLabel;

  /// Placeholder text for the product name input on the add product form
  ///
  /// In en, this message translates to:
  /// **'e.g. Basmati Rice'**
  String get productFormNameHint;

  /// Validation message when the product name field is submitted empty, reused on add and edit forms
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get productNameRequiredError;

  /// Field label for the price input, reused on add and edit product forms
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productFormPriceLabel;

  /// Placeholder text for the price input on the add product form
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get productFormPriceHint;

  /// Validation message when the price field is submitted empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a price'**
  String get productPriceRequiredError;

  /// Validation message when the price field is not a valid number
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get productPriceInvalidError;

  /// Validation message when the price field is negative
  ///
  /// In en, this message translates to:
  /// **'Price cannot be negative'**
  String get productPriceNegativeError;

  /// Error shown when submitting a new product whose barcode already matches an existing product
  ///
  /// In en, this message translates to:
  /// **'Product with barcode \"{barcode}\" already exists!'**
  String productBarcodeExistsError(String barcode);

  /// App bar title of the edit product page
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProductAppBarTitle;

  /// Small uppercase label above the read-only barcode value on the edit product page
  ///
  /// In en, this message translates to:
  /// **'BARCODE'**
  String get editProductBarcodeFieldLabel;

  /// Submit button label on the edit product page
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editProductSaveButton;

  /// App bar title of the checkout page
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutAppBarTitle;

  /// Snackbar shown after a receipt prints successfully
  ///
  /// In en, this message translates to:
  /// **'Printed successfully'**
  String get checkoutPrintedSuccessfully;

  /// Header of the product name column in the checkout items table
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get checkoutColumnProductName;

  /// Header of the unit price column in the checkout items table
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get checkoutColumnPrice;

  /// Header of the line total column in the checkout items table
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get checkoutColumnTotal;

  /// Heading above the UPI payment QR code
  ///
  /// In en, this message translates to:
  /// **'Scan to Pay'**
  String get checkoutScanToPay;

  /// Label above the final total amount on the checkout bottom bar
  ///
  /// In en, this message translates to:
  /// **'GRAND TOTAL'**
  String get checkoutGrandTotalLabel;

  /// Snackbar shown when trying to print a receipt before shop details have loaded
  ///
  /// In en, this message translates to:
  /// **'Shop details not loaded'**
  String get checkoutShopDetailsNotLoaded;

  /// Button label to print the receipt
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get checkoutPrintReceiptButton;

  /// App bar title of the standalone barcode scanner page
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scannerAppBarTitle;

  /// Instructional text shown under the scan frame
  ///
  /// In en, this message translates to:
  /// **'Align barcode within frame'**
  String get scannerAlignHint;

  /// Generic validation message for a required field, reused across forms
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequiredError;

  /// App bar title of the shop details page
  ///
  /// In en, this message translates to:
  /// **'Shop Details'**
  String get shopDetailsAppBarTitle;

  /// Snackbar shown after shop details are saved successfully
  ///
  /// In en, this message translates to:
  /// **'Shop details saved!'**
  String get shopDetailsSavedSnackbar;

  /// Section header above the shop details form
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get shopDetailsGeneralInfoSectionTitle;

  /// Explanatory text under the General Information section header
  ///
  /// In en, this message translates to:
  /// **'These details will appear on your digital and printed receipts.'**
  String get shopDetailsSectionSubtitle;

  /// Field label for the shop name input
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get shopDetailsNameLabel;

  /// Field label for the first address line input
  ///
  /// In en, this message translates to:
  /// **'Address Line 1'**
  String get shopDetailsAddress1Label;

  /// Field label for the second, optional address line input
  ///
  /// In en, this message translates to:
  /// **'Address Line 2 (Optional)'**
  String get shopDetailsAddress2Label;

  /// Field label for the phone number input
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get shopDetailsPhoneLabel;

  /// Field label for the UPI payment ID input
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get shopDetailsUpiIdLabel;

  /// Field label for the printed receipt footer text input
  ///
  /// In en, this message translates to:
  /// **'Receipt Footer Text'**
  String get shopDetailsFooterTextLabel;

  /// Helper text next to the footer text label noting the character limit
  ///
  /// In en, this message translates to:
  /// **'Max 150 chars'**
  String get shopDetailsFooterMaxChars;

  /// Submit button label on the shop details page
  ///
  /// In en, this message translates to:
  /// **'Save Details'**
  String get shopDetailsSaveButton;

  /// Snackbar shown after a product is added
  ///
  /// In en, this message translates to:
  /// **'Product added successfully'**
  String get productAddedSuccessMessage;

  /// Snackbar shown after a product is updated
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdatedSuccessMessage;

  /// Snackbar shown after a product is deleted
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeletedSuccessMessage;

  /// Printer error shown when no paired Bluetooth devices are found while refreshing
  ///
  /// In en, this message translates to:
  /// **'No paired devices found.'**
  String get settingsPrinterNoPairedDevices;

  /// Printer error shown when none of the paired devices could be connected to
  ///
  /// In en, this message translates to:
  /// **'Could not connect to any paired device.'**
  String get settingsPrinterNoDeviceConnectable;

  /// Printer error shown when connecting to a specific selected device fails
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to printer'**
  String get settingsPrinterConnectionFailed;

  /// Error shown on checkout when auto-connecting to the saved printer fails
  ///
  /// In en, this message translates to:
  /// **'Failed to auto-connect to printer!'**
  String get billingAutoConnectFailed;

  /// Error shown on checkout when no printer is connected and none was previously saved
  ///
  /// In en, this message translates to:
  /// **'Printer not connected & no saved printer found!'**
  String get billingNoPrinterConfigured;

  /// Error shown on checkout when printing throws an exception; error is the raw exception text and is not translated
  ///
  /// In en, this message translates to:
  /// **'Print failed: {error}'**
  String billingPrintFailedError(String error);

  /// Item column header printed on the thermal receipt, resolved by the caller since printer_helper.dart has no BuildContext
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get receiptColumnItem;

  /// Price column header printed on the thermal receipt
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get receiptColumnPrice;

  /// Total column header printed on the thermal receipt
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get receiptColumnTotal;

  /// Label printed before the grand total amount on the thermal receipt, e.g. 'TOTAL: 12.50'
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get receiptTotalPrefix;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
