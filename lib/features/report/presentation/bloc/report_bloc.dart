import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/sale.dart';
import '../../domain/sales_aggregator.dart';
import '../../domain/usecases/sale_usecases.dart';
import '../../../../core/usecase/usecase.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetSalesUseCase getSalesUseCase;

  ReportBloc({required this.getSalesUseCase}) : super(const ReportState()) {
    on<LoadSales>(_onLoadSales);
    on<ChangeGrouping>(_onChangeGrouping);
    on<SelectPeriod>(_onSelectPeriod);
  }

  Future<void> _onLoadSales(
      LoadSales event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading));
    final result = await getSalesUseCase(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportStatus.error, message: failure.message)),
      (sales) => emit(state.copyWith(
        status: ReportStatus.loaded,
        sales: sales,
        periods: SalesAggregator.aggregate(sales, state.grouping),
      )),
    );
  }

  void _onChangeGrouping(
      ChangeGrouping event, Emitter<ReportState> emit) {
    emit(state.copyWith(
      grouping: event.grouping,
      periods: SalesAggregator.aggregate(state.sales, event.grouping),
      selectedPeriod: null,
    ));
  }

  void _onSelectPeriod(SelectPeriod event, Emitter<ReportState> emit) {
    emit(state.copyWith(selectedPeriod: event.period));
  }
}
