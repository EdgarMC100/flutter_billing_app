// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settingsAppBarTitle => 'Ajustes';

  @override
  String get settingsManagementSectionTitle => 'Gestión';

  @override
  String get settingsProductsTitle => 'Productos';

  @override
  String get settingsProductsSubtitle =>
      'Gestiona el inventario y los códigos de barras';

  @override
  String get settingsShopDetailsTitle => 'Datos del negocio';

  @override
  String get settingsShopDetailsSubtitle =>
      'Edita la información y dirección del negocio';

  @override
  String get settingsHardwareSectionTitle => 'Hardware';

  @override
  String get settingsPrinterConnectedSnackbar => 'Conectado a la impresora';

  @override
  String get settingsPrintDeviceTitle => 'Dispositivo de impresión';

  @override
  String get settingsPrinterConnectedFallback => 'Impresora conectada';

  @override
  String get settingsNoPrinterConnected => 'Ninguna impresora conectada';

  @override
  String get settingsConnectedBadge => 'CONECTADO';

  @override
  String get settingsPrinterHelpText =>
      'Para conectar un nuevo dispositivo, toca el ícono de ajustes para emparejar en la configuración de Bluetooth del teléfono, luego regresa y presiona Actualizar.';

  @override
  String get settingsPreferencesSectionTitle => 'Preferencias';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageDialogTitle => 'Seleccionar idioma';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get homeProductNotFoundTitle => 'Producto no encontrado';

  @override
  String homeProductNotFoundMessage(String barcode) {
    return 'Ningún producto coincide con el código de barras \"$barcode\".\n¿Deseas agregarlo a tu inventario?';
  }

  @override
  String get commonAddProduct => 'Agregar producto';

  @override
  String get homeReviewOrderButton => 'Revisar pedido';

  @override
  String get homeCameraOffTitle => 'La cámara está apagada';

  @override
  String get homeCameraOffMessage =>
      'Enciende tu cámara para comenzar a escanear códigos de barras y artículos automáticamente.';

  @override
  String get homeTurnOnCameraButton => 'Encender cámara';

  @override
  String get homeScannedItemsTitle => 'Artículos escaneados';

  @override
  String homeItemsTotalCount(int count) {
    return '$count artículos en total';
  }

  @override
  String get homeTotalPriceLabel => 'PRECIO TOTAL';

  @override
  String get homeEmptyCartTitle => 'La lista está vacía';

  @override
  String get homeEmptyCartMessage =>
      'Los artículos escaneados aparecerán aquí a medida que los escanees con la cámara de arriba.';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get productListAppBarTitle => 'Gestión de productos';

  @override
  String get productBarcodeHint => 'Escanea o ingresa el código de barras';

  @override
  String get productBarcodeRequiredError =>
      'Por favor ingresa un código de barras';

  @override
  String get productScannerHint =>
      'Toca el icono para abrir el escáner de cámara';

  @override
  String productListErrorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get productListEmptyTitle =>
      'No se encontraron productos. ¡Agrega alguno!';

  @override
  String get productListNoSearchResults =>
      'Ningún producto coincide con tu búsqueda.';

  @override
  String get productListDeleteDialogTitle => 'Eliminar producto';

  @override
  String productListDeleteDialogMessage(String productName) {
    return '¿Estás seguro de que deseas eliminar $productName?';
  }

  @override
  String get productFormBarcodeLabel => 'Código de barras';

  @override
  String get productFormNameLabel => 'Nombre del producto';

  @override
  String get productFormNameHint => 'ej. Arroz Basmati';

  @override
  String get productNameRequiredError => 'Por favor ingresa un nombre';

  @override
  String get productFormPriceLabel => 'Precio';

  @override
  String get productFormPriceHint => '0.00';

  @override
  String get productPriceRequiredError => 'Por favor ingresa un precio';

  @override
  String get productPriceInvalidError => 'Por favor ingresa un número válido';

  @override
  String get productPriceNegativeError => 'El precio no puede ser negativo';

  @override
  String productBarcodeExistsError(String barcode) {
    return '¡Ya existe un producto con el código de barras \"$barcode\"!';
  }

  @override
  String get editProductAppBarTitle => 'Editar producto';

  @override
  String get editProductBarcodeFieldLabel => 'CÓDIGO DE BARRAS';

  @override
  String get editProductSaveButton => 'Guardar cambios';

  @override
  String get checkoutAppBarTitle => 'Pagar';

  @override
  String get checkoutPrintedSuccessfully => 'Impreso correctamente';

  @override
  String get checkoutColumnProductName => 'Producto';

  @override
  String get checkoutColumnPrice => 'Precio';

  @override
  String get checkoutColumnTotal => 'Total';

  @override
  String get checkoutScanToPay => 'Escanea para pagar';

  @override
  String get checkoutGrandTotalLabel => 'TOTAL GENERAL';

  @override
  String get checkoutShopDetailsNotLoaded =>
      'No se cargaron los datos del negocio';

  @override
  String get checkoutPrintReceiptButton => 'Imprimir recibo';

  @override
  String get scannerAppBarTitle => 'Escanear código';

  @override
  String get scannerAlignHint => 'Alinea el código de barras dentro del marco';

  @override
  String get commonRequiredError => 'Obligatorio';

  @override
  String get shopDetailsAppBarTitle => 'Datos del negocio';

  @override
  String get shopDetailsSavedSnackbar => '¡Datos del negocio guardados!';

  @override
  String get shopDetailsGeneralInfoSectionTitle => 'Información general';

  @override
  String get shopDetailsSectionSubtitle =>
      'Estos datos aparecerán en tus recibos digitales e impresos.';

  @override
  String get shopDetailsNameLabel => 'Nombre del negocio';

  @override
  String get shopDetailsAddress1Label => 'Dirección línea 1';

  @override
  String get shopDetailsAddress2Label => 'Dirección línea 2 (opcional)';

  @override
  String get shopDetailsPhoneLabel => 'Número de teléfono';

  @override
  String get shopDetailsUpiIdLabel => 'ID de UPI';

  @override
  String get shopDetailsFooterTextLabel => 'Texto de pie del recibo';

  @override
  String get shopDetailsFooterMaxChars => 'Máximo 150 caracteres';

  @override
  String get shopDetailsSaveButton => 'Guardar datos';

  @override
  String get productAddedSuccessMessage => 'Producto agregado exitosamente';

  @override
  String get productUpdatedSuccessMessage =>
      'Producto actualizado exitosamente';

  @override
  String get productDeletedSuccessMessage => 'Producto eliminado exitosamente';

  @override
  String get settingsPrinterNoPairedDevices =>
      'No se encontraron dispositivos emparejados.';

  @override
  String get settingsPrinterNoDeviceConnectable =>
      'No se pudo conectar a ningún dispositivo emparejado.';

  @override
  String get settingsPrinterConnectionFailed =>
      'Error al conectar con la impresora';

  @override
  String get billingAutoConnectFailed =>
      '¡Error al conectar automáticamente con la impresora!';

  @override
  String get billingNoPrinterConfigured =>
      '¡Impresora no conectada y no se encontró ninguna impresora guardada!';

  @override
  String billingPrintFailedError(String error) {
    return 'Error al imprimir: $error';
  }

  @override
  String get receiptColumnItem => 'Artículo';

  @override
  String get receiptColumnPrice => 'Precio';

  @override
  String get receiptColumnTotal => 'Total';

  @override
  String get receiptTotalPrefix => 'TOTAL';
}
