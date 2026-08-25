import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';

class EscPos {
  static const List<int> init = [0x1B, 0x40];
  // ESC t 16: select character code table 16 (WPC1252/Windows-1252), the
  // one candidate that renders Spanish accents correctly on this printer
  // hardware (confirmed via a physical code-page probe print) instead of
  // garbling them under the printer's PC437-like default table.
  static const List<int> selectCodePageLatin1 = [0x1B, 0x74, 16];
  static const List<int> alignCenter = [0x1B, 0x61, 0x01];
  static const List<int> alignLeft = [0x1B, 0x61, 0x00];
  static const List<int> alignRight = [0x1B, 0x61, 0x02];
  static const List<int> boldOn = [0x1B, 0x45, 0x01];
  static const List<int> boldOff = [0x1B, 0x45, 0x00];
  static const List<int> textNormal = [0x1D, 0x21, 0x00];
  static const List<int> textLarge = [0x1D, 0x21, 0x11];
  static const List<int> lineFeed = [0x0A];
}

class PrinterHelper {
  // Singleton
  static final PrinterHelper _instance = PrinterHelper._internal();
  factory PrinterHelper() => _instance;
  PrinterHelper._internal();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<bool> checkPermission() async {
    // Request Bluetooth and Location permissions
    // Android 12+ needs BLUETOOTH_SCAN, BLUETOOTH_CONNECT
    // Older Android needs BLUETOOTH, BLUETOOTH_ADMIN, ACCESS_FINE_LOCATION

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<List<BluetoothInfo>> getBondedDevices() async {
    try {
      final List<BluetoothInfo> list =
          await PrintBluetoothThermal.pairedBluetooths;
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<bool> connect(String macAddress) async {
    try {
      final bool result =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
      _isConnected = result;
      return result;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  /// Queries the plugin for the live Bluetooth connection state, as opposed
  /// to [isConnected] which only reflects the last connect/disconnect call
  /// result and doesn't notice the printer going unreachable (e.g. powered
  /// off) in between.
  Future<bool> checkLiveConnection() async {
    try {
      final bool result = await PrintBluetoothThermal.connectionStatus;
      _isConnected = result;
      return result;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      final bool result = await PrintBluetoothThermal.disconnect;
      _isConnected =
          !result; // If disconnected successfully, isConnected is false
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<void> printText(String text) async {
    if (!_isConnected) return;

    // Simple text printing
    // We can use bytes for advanced formatting
    // But plugin supports basic text or bytes

    // Checking battery or connection status
    final bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      // Plugin allows sending bytes. We need ESC/POS commands for text.
      // However, the plugin might have helper.
      // Looking at doc, `writeBytes` or `writeString`?
      // The plugin `print_bluetooth_thermal` mainly exposes `writeBytes`.
      // We need a generator. `esc_pos_utils` is common but not requested.
      // But wait, `print_bluetooth_thermal` example often uses `capability_profile` and `generator`.
      // I don't have `esc_pos_utils` or similar in my pubspec.
      // The user requested `print_bluetooth_thermal`.
      // Let's assume we can send raw string bytes or use a simple helper.
      // Actually without `esc_pos_utils`, formatting is hard.
      // I will try to use `esc_pos_utils_plus` or similar if I can add it, but user gave specific packages.
      // Wait, user allowed "use required plugins".
      // "suggest barcode scanner ... and use required plugins".
      // So I can add `esc_pos_utils_plus`.

      // For now, I'll assume simple text printing by converting string to bytes.
      // ASCII bytes.
      List<int> bytes = text.codeUnits;
      await PrintBluetoothThermal.writeBytes(bytes);
    }
  }

  Future<void> printReceipt({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required List<Map<String, dynamic>> items, // Name, Qty, Price, Total
    required double total,
    required String footer,
    required String itemColumnLabel,
    required String priceColumnLabel,
    required String totalColumnLabel,
    required String totalLinePrefix,
    required int itemsCount,
    required String itemsCountLabel,
  }) async {
    if (!_isConnected) return;

    // Construct ESC/POS bytes manually or using helper
    List<int> bytes = [];

    // Init
    bytes += EscPos.init;
    bytes += EscPos.selectCodePageLatin1;

    // Shop Name (Center, Bold, Large)
    bytes += EscPos.alignCenter;
    bytes += EscPos.boldOn;
    bytes += EscPos.textLarge;
    bytes += _textToBytes(shopName);
    bytes += EscPos.lineFeed;

    // Address & Phone (Normal, Center)
    bytes += EscPos.textNormal;
    bytes += EscPos.boldOff;
    if (address1.isNotEmpty) {
      bytes += _textToBytes(address1);
      bytes += EscPos.lineFeed;
    }
    if (address2.isNotEmpty) {
      bytes += _textToBytes(address2);
      bytes += EscPos.lineFeed;
    }
    bytes += _textToBytes(phone);
    bytes += EscPos.lineFeed;

    // Date and Time
    String formattedDate =
        DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
    bytes += _textToBytes(formattedDate);
    bytes += EscPos.lineFeed;

    bytes += _textToBytes('--------------------------------');
    bytes += EscPos.lineFeed;

    // Header (Align Left)
    bytes += EscPos.alignLeft;
    bytes += _textToBytes(
        itemColumnLabel.padRight(16) +
            priceColumnLabel.padRight(8) +
            totalColumnLabel);
    bytes += EscPos.lineFeed;
    bytes += _textToBytes('--------------------------------');
    bytes += EscPos.lineFeed;

    // Items
    for (var item in items) {
      String name = item['name'].toString();
      String qty = item['qty'].toString();
      String price = '\$${item['price']}';
      String totalItem = '\$${item['total']}';

      String prefix = '${qty}x $name';

      if (prefix.length <= 16) {
        String line = prefix.padRight(16) + price.padRight(8) + totalItem;
        bytes += _textToBytes(line);
        bytes += EscPos.lineFeed;
      } else {
        // Description doesn't fit the item column: give it up to 2 lines
        // at full receipt width instead of truncating it into the price,
        // then align price/total on the line below.
        for (final descLine in _wrapDescription(prefix, 32, 2)) {
          bytes += _textToBytes(descLine);
          bytes += EscPos.lineFeed;
        }
        String line = ''.padRight(16) + price.padRight(8) + totalItem;
        bytes += _textToBytes(line);
        bytes += EscPos.lineFeed;
      }
    }

    bytes += _textToBytes('--------------------------------');
    bytes += EscPos.lineFeed;

    // Items count (Align Right)
    bytes += EscPos.alignRight;
    bytes += _textToBytes('$itemsCountLabel: $itemsCount');
    bytes += EscPos.lineFeed;

    // Total (Align Right)
    bytes += EscPos.boldOn;
    bytes += _textToBytes('$totalLinePrefix: \$$total');
    bytes += EscPos.lineFeed;
    bytes += EscPos.boldOff;
    bytes += EscPos.lineFeed;

    // Footer (Center)
    bytes += EscPos.alignCenter;
    bytes += _textToBytes(footer);
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed; // One line space after footer
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed; // Additional Feed

    await PrintBluetoothThermal.writeBytes(bytes);
  }

  /// Encodes as Windows-1252/Latin-1 byte values, matching the printer's
  /// active code table (see [EscPos.selectCodePageLatin1]) so accented
  /// Spanish characters print correctly instead of being stripped/garbled.
  /// Dart's codeUnits already equal those byte values for U+0000-U+00FF;
  /// anything outside that range (e.g. emoji) falls back to '?'.
  List<int> _textToBytes(String text) {
    return text.codeUnits.map((c) => c > 255 ? 0x3F : c).toList();
  }

  /// Word-wraps [text] into at most [maxLines] lines of [width] characters,
  /// breaking at word boundaries where possible. If [text] still doesn't
  /// fit after [maxLines], the last line is truncated with an ellipsis.
  List<String> _wrapDescription(String text, int width, int maxLines) {
    final lines = <String>[];
    String remaining = text.trim();

    while (remaining.isNotEmpty && lines.length < maxLines) {
      if (remaining.length <= width) {
        lines.add(remaining);
        remaining = '';
        break;
      }
      int breakAt = remaining.lastIndexOf(' ', width);
      if (breakAt <= 0) breakAt = width;
      lines.add(remaining.substring(0, breakAt).trim());
      remaining = remaining.substring(breakAt).trim();
    }

    if (remaining.isNotEmpty && lines.isNotEmpty) {
      // ASCII "..." rather than a Unicode ellipsis: _textToBytes sends raw
      // codeUnits as single printer bytes, and U+2026 doesn't fit in one.
      String last = lines.last;
      if (last.length > width - 3) last = last.substring(0, width - 3);
      lines[lines.length - 1] = '$last...';
    }

    return lines;
  }
}
