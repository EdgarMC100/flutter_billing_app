part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final String? error;
  final String? notFoundBarcode;
  final bool isPrinting;
  final bool printSuccess;
  final bool isSavingSale;
  final bool saleCompleted;

  const BillingState({
    this.cartItems = const [],
    this.error,
    this.notFoundBarcode,
    this.isPrinting = false,
    this.printSuccess = false,
    this.isSavingSale = false,
    this.saleCompleted = false,
  });

  double get totalAmount => cartItems.fold(0, (sum, item) => sum + item.total);

  int get itemsCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  BillingState copyWith({
    List<CartItem>? cartItems,
    String? error,
    bool clearError = false,
    String? notFoundBarcode,
    bool clearNotFoundBarcode = false,
    bool? isPrinting,
    bool? printSuccess,
    bool? isSavingSale,
    bool? saleCompleted,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      error: clearError ? null : (error ?? this.error),
      notFoundBarcode: clearNotFoundBarcode
          ? null
          : (notFoundBarcode ?? this.notFoundBarcode),
      isPrinting: isPrinting ?? this.isPrinting,
      printSuccess: printSuccess ?? this.printSuccess,
      isSavingSale: isSavingSale ?? this.isSavingSale,
      saleCompleted: saleCompleted ?? this.saleCompleted,
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        error,
        notFoundBarcode,
        isPrinting,
        printSuccess,
        isSavingSale,
        saleCompleted,
      ];
}
