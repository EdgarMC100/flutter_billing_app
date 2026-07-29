part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final String? error;
  final String? notFoundBarcode;
  final bool isPrinting;
  final bool printSuccess;

  const BillingState({
    this.cartItems = const [],
    this.error,
    this.notFoundBarcode,
    this.isPrinting = false,
    this.printSuccess = false,
  });

  double get totalAmount => cartItems.fold(0, (sum, item) => sum + item.total);

  BillingState copyWith({
    List<CartItem>? cartItems,
    String? error,
    bool clearError = false,
    String? notFoundBarcode,
    bool clearNotFoundBarcode = false,
    bool? isPrinting,
    bool? printSuccess,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      error: clearError ? null : (error ?? this.error),
      notFoundBarcode: clearNotFoundBarcode
          ? null
          : (notFoundBarcode ?? this.notFoundBarcode),
      isPrinting: isPrinting ?? this.isPrinting,
      printSuccess: printSuccess ?? this.printSuccess,
    );
  }

  @override
  List<Object?> get props =>
      [cartItems, error, notFoundBarcode, isPrinting, printSuccess];
}
