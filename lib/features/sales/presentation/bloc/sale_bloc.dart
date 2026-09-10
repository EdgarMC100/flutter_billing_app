import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/sale.dart';
import '../../domain/usecases/sale_usecases.dart';

part 'sale_event.dart';
part 'sale_state.dart';

class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final GetSalesUseCase getSalesUseCase;

  SaleBloc({required this.getSalesUseCase}) : super(const SaleState()) {
    on<LoadSales>(_onLoadSales);
  }

  Future<void> _onLoadSales(LoadSales event, Emitter<SaleState> emit) async {
    emit(state.copyWith(status: SaleStatus.loading));
    final result = await getSalesUseCase(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
          status: SaleStatus.error, message: failure.message)),
      (sales) =>
          emit(state.copyWith(status: SaleStatus.loaded, sales: sales)),
    );
  }
}
