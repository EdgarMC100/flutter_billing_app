part of 'sale_bloc.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object> get props => [];
}

class LoadSales extends SaleEvent {}
