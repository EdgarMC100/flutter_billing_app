import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/sale.dart';

abstract class SaleRepository {
  /// All recorded sales, most recent first.
  Future<Either<Failure, List<Sale>>> getSales();
  Future<Either<Failure, void>> saveSale(Sale sale);
}
