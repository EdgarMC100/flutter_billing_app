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
      final box = HiveDatabase.saleBox;
      final sales = box.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(sales);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSale(Sale sale) async {
    try {
      final box = HiveDatabase.saleBox;
      final model = SaleModel.fromEntity(sale);
      await box.put(model.id, model); // Using ID as key
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
