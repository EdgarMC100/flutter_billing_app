part of 'report_bloc.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object> get props => [];
}

class LoadSales extends ReportEvent {
  const LoadSales();
}

class ChangeGrouping extends ReportEvent {
  final SalesGrouping grouping;
  const ChangeGrouping(this.grouping);
  @override
  List<Object> get props => [grouping];
}

class SelectPeriod extends ReportEvent {
  final SalesPeriod period;
  const SelectPeriod(this.period);
  @override
  List<Object> get props => [period];
}
