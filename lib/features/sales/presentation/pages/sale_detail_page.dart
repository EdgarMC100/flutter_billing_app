import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/sale.dart';

class SaleDetailPage extends StatelessWidget {
  final Sale sale;

  const SaleDetailPage({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E5EA);
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd-MM-yyyy hh:mm a');

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormat.format(sale.dateTime),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                            l10n.checkoutColumnProductName, TextAlign.left),
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
    );
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
