part of 'sale_bloc.dart';

enum SaleStatus { initial, loading, loaded, error }

class SaleState extends Equatable {
  final SaleStatus status;
  final List<Sale> sales;
  final String? message;

  const SaleState({
    this.status = SaleStatus.initial,
    this.sales = const [],
    this.message,
  });

  SaleState copyWith({
    SaleStatus? status,
    List<Sale>? sales,
    String? message,
  }) {
    return SaleState(
      status: status ?? this.status,
      sales: sales ?? this.sales,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, sales, message];
}
