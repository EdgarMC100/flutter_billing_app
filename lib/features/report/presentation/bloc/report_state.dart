part of 'report_bloc.dart';

enum ReportStatus { initial, loading, loaded, error }

class ReportState extends Equatable {
  final ReportStatus status;
  final List<Sale> sales;
  final SalesGrouping grouping;
  final List<SalesPeriod> periods;
  final SalesPeriod? selectedPeriod;
  final String? message;

  const ReportState({
    this.status = ReportStatus.initial,
    this.sales = const [],
    this.grouping = SalesGrouping.day,
    this.periods = const [],
    this.selectedPeriod,
    this.message,
  });

  /// Grand total of every recorded sale, regardless of grouping.
  double get totalAmount => sales.fold(0, (sum, sale) => sum + sale.total);

  /// Sales belonging to [selectedPeriod], newest first. Empty when no
  /// period is selected.
  List<Sale> get selectedSales {
    final period = selectedPeriod;
    if (period == null) return const [];
    return sales
        .where((sale) =>
            SalesAggregator.periodStart(sale.createdAt, grouping) ==
            period.start)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  ReportState copyWith({
    ReportStatus? status,
    List<Sale>? sales,
    SalesGrouping? grouping,
    List<SalesPeriod>? periods,
    SalesPeriod? selectedPeriod,
    String? message,
  }) {
    return ReportState(
      status: status ?? this.status,
      sales: sales ?? this.sales,
      grouping: grouping ?? this.grouping,
      periods: periods ?? this.periods,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      message: message, // Transient message, reset unless passed.
    );
  }

  @override
  List<Object?> get props =>
      [status, sales, grouping, periods, selectedPeriod, message];
}
