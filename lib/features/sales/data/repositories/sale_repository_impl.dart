import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import '../models/sale_model.dart';

class SaleRepositoryImpl implements SaleRepository {
  @override
  Future<Either<Failure, List<Sale>>> getSales() async {
    try {
      final box = HiveDatabase.salesBox;
      final sales = box.values.map((m) => m.toEntity()).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // newest first
      return Right(sales);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSale(Sale sale) async {
    try {
      final model = SaleModel.fromEntity(sale);
      await HiveDatabase.salesBox.put(model.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
