import 'package:hive/hive.dart';
import 'package:billing_app/features/report/data/models/sale_model.dart';

/// Seeds the local `sales` Hive box with demo sales spanning the last ~6
/// weeks, so the sales report page can be previewed on a host/emulator
/// without a Bluetooth printer. Writes to the directory given as the first
/// argument (defaults to the current directory).
///
/// Usage: dart run tool/seed_sales.dart [directory]
Future<void> main(List<String> args) async {
  final dirPath =
      args.isNotEmpty ? args.first : '.';
  Hive.init(dirPath);
  Hive.registerAdapter(SaleLineItemModelAdapter());
  Hive.registerAdapter(SaleModelAdapter());
  final box = await Hive.openBox<SaleModel>('sales');

  await box.clear();

  final now = DateTime.now();
  // Deterministic pseudo-random totals so re-runs look the same.
  double amount(int seed) => 3.5 + ((seed * 137) % 76) + ((seed * 53) % 100) / 100;

  var id = 0;
  void addSale(DateTime createdAt, int items) {
    id++;
    final total = amount(id) * items;
    box.put(
      'demo-$id',
      SaleModel(
        id: 'demo-$id',
        createdAt: createdAt,
        total: double.parse(total.toStringAsFixed(2)),
        itemsCount: items,
        lineItems: [
          SaleLineItemModel(
            productName: 'Demo Item $id',
            quantity: items,
            unitPrice: double.parse(total.toStringAsFixed(2)),
            total: double.parse(total.toStringAsFixed(2)),
          ),
        ],
      ),
    );
  }

  // ~24 sales over the last 42 days, clumped on some days and quiet on
  // others, so day/biweekly/month groupings all show interesting data.
  final saleDays = <int, int>{
    42: 1, 40: 2, 38: 1, 35: 3, 33: 1, 30: 2, 27: 4, 25: 1, 22: 2,
    20: 1, 17: 3, 15: 2, 13: 1, 11: 2, 9: 1, 8: 3, 6: 1, 5: 2, 4: 1,
    3: 2, 2: 1, 1: 3, 0: 2,
  };
  saleDays.forEach((daysAgo, count) {
    for (var i = 0; i < count; i++) {
      addSale(now.subtract(Duration(days: daysAgo, hours: (i * 3) % 10)), 1 + ((id * 7) % 4));
    }
  });

  print('Seeded ${box.length} sales into $dirPath/sales.hive');
  await box.close();
}
