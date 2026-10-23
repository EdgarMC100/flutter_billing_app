// Reads a `sales` Hive box using custom adapters that capture the RAW stored
// field map (key -> value -> runtimeType), instead of casting to the current
// model. This reveals the on-disk field layout of an older build so a correct
// migration can be written without destroying data.
//
// Usage: dart run tool/inspect_sales_schema.dart [directory]
import 'package:hive/hive.dart';

/// Generic adapter: stores the raw field map keyed by field index.
class RawMapAdapter extends TypeAdapter<Map<int, dynamic>> {
  RawMapAdapter(this.typeId);
  @override
  final int typeId;

  @override
  Map<int, dynamic> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    return <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
  }

  @override
  void write(BinaryWriter writer, Map<int, dynamic> obj) {
    throw UnimplementedError('read-only inspector');
  }
}

Future<void> main(List<String> args) async {
  final dirPath = args.isNotEmpty ? args.first : '.';
  Hive.init(dirPath);
  // Register raw adapters for the typeIds the models use.
  Hive.registerAdapter(RawMapAdapter(2)); // SaleLineItemModel
  Hive.registerAdapter(RawMapAdapter(3)); // SaleModel

  final box = await Hive.openBox<Map<int, dynamic>>('sales');
  print('Total sales: ${box.length}\n');

  for (var i = 0; i < box.length; i++) {
    final sale = box.getAt(i) as Map<int, dynamic>;
    print('== Sale #$i ==');
    for (final entry in sale.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key))) {
      final v = entry.value;
      if (v is List) {
        print('  field[${entry.key}] List(${v.length}):');
        for (final item in v) {
          if (item is Map) {
            final inner = item.entries.toList()
              ..sort((a, b) => (a.key as int).compareTo(b.key as int));
            print('    {');
            for (final e in inner) {
              print(
                  '      [${e.key}] ${e.value.runtimeType} = ${e.value}');
            }
            print('    }');
          } else {
            print('      ${item.runtimeType} = $item');
          }
        }
      } else {
        print('  field[${entry.key}] ${v.runtimeType} = $v');
      }
    }
    print('');
  }
  await box.close();
}
