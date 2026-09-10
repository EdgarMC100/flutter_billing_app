import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_display.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../billing/presentation/billing_error_messages.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../domain/entities/sale.dart';

class SaleDetailPage extends StatelessWidget {
  final Sale sale;

  const SaleDetailPage({super.key, required this.sale});

  /// Amber: the sale record is safe, only the (optional) receipt print failed —
  /// distinct from a red "something actually failed" error.
  static const _printWarningColor = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E5EA);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.saleDetailAppBarTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<BillingBloc, BillingState>(
        // Only react to transitions, so a value left over from an earlier
        // checkout/print doesn't fire a snackbar when this page opens.
        listenWhen: (prev, curr) =>
            (!prev.printSuccess && curr.printSuccess) ||
            (prev.error != curr.error && curr.error != null),
        listener: (context, state) {
          if (state.printSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.checkoutPrintedSuccessfully),
                backgroundColor: Colors.green));
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(billingErrorMessage(l10n, state.error!)),
                backgroundColor: _printWarningColor));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateDisplay.dateLabel(sale.dateTime, l10n.commonToday),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateDisplay.timeLabel(sale.dateTime),
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.salesHistoryItemsCount(sale.itemsCount),
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Table(
                            border: const TableBorder(
                              horizontalInside: BorderSide(color: borderColor),
                              bottom: BorderSide(color: borderColor),
                            ),
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF8FAFC),
                                  border: Border(
                                      bottom: BorderSide(color: borderColor)),
                                ),
                                children: [
                                  _buildHeaderCell(
                                      l10n.checkoutColumnProductName,
                                      TextAlign.left),
                                  _buildHeaderCell(
                                      l10n.checkoutColumnPrice, TextAlign.right),
                                  _buildHeaderCell(
                                      l10n.checkoutColumnTotal, TextAlign.right),
                                ],
                              ),
                              ...sale.items.map((item) {
                                return TableRow(
                                  children: [
                                    _buildDataCell(
                                      '${item.quantity} x ${item.productName}',
                                      TextAlign.left,
                                    ),
                                    _buildDataCell(
                                        '\$${item.unitPrice.toStringAsFixed(2)}',
                                        TextAlign.right,
                                        isSubtitle: true),
                                    _buildDataCell(
                                        '\$${item.total.toStringAsFixed(2)}',
                                        TextAlign.right,
                                        isBold: true),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.checkoutGrandTotalLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[400],
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '\$${sale.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                onPressed: () => _printReceipt(context, l10n),
                label: l10n.checkoutPrintReceiptButton,
                icon: Icons.print,
                isLoading: state.isPrinting,
              ),
            ],
          );
        },
      ),
    );
  }

  void _printReceipt(BuildContext context, AppLocalizations l10n) {
    final shopState = context.read<ShopBloc>().state;
    if (shopState is ShopLoaded) {
      context.read<BillingBloc>().add(PrintReceiptEvent(
            sale: sale,
            shopName: shopState.shop.name,
            address1: shopState.shop.addressLine1,
            address2: shopState.shop.addressLine2,
            phone: shopState.shop.phoneNumber,
            footer: shopState.shop.footerText,
            itemColumnLabel: l10n.receiptColumnItem,
            priceColumnLabel: l10n.receiptColumnPrice,
            totalColumnLabel: l10n.receiptColumnTotal,
            totalLinePrefix: l10n.receiptTotalPrefix,
            itemsCountLabel: l10n.receiptItemsCountLabel,
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.checkoutShopDetailsNotLoaded),
          backgroundColor: Colors.red));
    }
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text.toUpperCase(),
        textAlign: align,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextAlign align,
      {bool isBold = false, bool isSubtitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isSubtitle ? 12 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: isSubtitle ? Colors.grey[500] : Colors.black87,
        ),
      ),
    );
  }
}
