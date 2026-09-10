part of 'billing_bloc.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();
  @override
  List<Object> get props => [];
}

class ScanBarcodeEvent extends BillingEvent {
  final String barcode;
  const ScanBarcodeEvent(this.barcode);
  @override
  List<Object> get props => [barcode];
}

class AddProductToCartEvent extends BillingEvent {
  final Product product;
  const AddProductToCartEvent(this.product);
  @override
  List<Object> get props => [product];
}

class RemoveProductFromCartEvent extends BillingEvent {
  final String productId;
  const RemoveProductFromCartEvent(this.productId);
  @override
  List<Object> get props => [productId];
}

class UpdateQuantityEvent extends BillingEvent {
  final String productId;
  final int quantity;
  const UpdateQuantityEvent(this.productId, this.quantity);
  @override
  List<Object> get props => [productId, quantity];
}

class ClearCartEvent extends BillingEvent {}

class ClearScanFeedbackEvent extends BillingEvent {}

/// Records the current cart as a [Sale] in history. Always persists the sale;
/// printing a receipt is a separate, optional action (see [PrintReceiptEvent]).
class CompleteSaleEvent extends BillingEvent {
  const CompleteSaleEvent();
}

class PrintReceiptEvent extends BillingEvent {
  /// The sale to print. Passed explicitly so a receipt can be (re)printed for
  /// any past sale from the history detail page, not just the live cart.
  final Sale sale;
  final String shopName;
  final String address1;
  final String address2;
  final String phone;
  final String footer;
  final String itemColumnLabel;
  final String priceColumnLabel;
  final String totalColumnLabel;
  final String totalLinePrefix;
  final String itemsCountLabel;

  const PrintReceiptEvent({
    required this.sale,
    required this.shopName,
    required this.address1,
    required this.address2,
    required this.phone,
    required this.footer,
    required this.itemColumnLabel,
    required this.priceColumnLabel,
    required this.totalColumnLabel,
    required this.totalLinePrefix,
    required this.itemsCountLabel,
  });

  @override
  List<Object> get props => [
        sale,
        shopName,
        address1,
        address2,
        phone,
        footer,
        itemColumnLabel,
        priceColumnLabel,
        totalColumnLabel,
        totalLinePrefix,
        itemsCountLabel,
      ];
}
