part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final String? error;
  final String? notFoundBarcode;
  final bool isPrinting;
  final bool printSuccess;

  /// Whether the current cart contents were already persisted as a [Sale].
  /// Prevents recording the same cart twice on reprint; resets whenever the
  /// cart changes.
  final bool saleRecorded;

  const BillingState({
    this.cartItems = const [],
    this.error,
    this.notFoundBarcode,
    this.isPrinting = false,
    this.printSuccess = false,
    this.saleRecorded = false,
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
    bool? saleRecorded,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      error: clearError ? null : (error ?? this.error),
      notFoundBarcode: clearNotFoundBarcode
          ? null
          : (notFoundBarcode ?? this.notFoundBarcode),
      isPrinting: isPrinting ?? this.isPrinting,
      printSuccess: printSuccess ?? this.printSuccess,
      saleRecorded: saleRecorded ?? this.saleRecorded,
    );
  }

  @override
  List<Object?> get props =>
      [cartItems, error, notFoundBarcode, isPrinting, printSuccess, saleRecorded];
}
