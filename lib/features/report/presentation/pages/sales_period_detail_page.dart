import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/sale.dart';
import '../../domain/sales_aggregator.dart';
import '../bloc/report_bloc.dart';
import '../period_label.dart';

/// Drill-down view listing every sale inside one period of the sales report
/// (a day, a semi-monthly window, or a month), newest first, with each
/// sale's product line items.
class SalesPeriodDetailPage extends StatefulWidget {
  final SalesPeriod period;

  const SalesPeriodDetailPage({super.key, required this.period});

  @override
  State<SalesPeriodDetailPage> createState() => _SalesPeriodDetailPageState();
}

class _SalesPeriodDetailPageState extends State<SalesPeriodDetailPage> {
  @override
  void initState() {
    super.initState();
    // Select the period this page was opened for, then refresh so the
    // detail view reflects anything recorded since the report was loaded.
    context.read<ReportBloc>().add(SelectPeriod(widget.period));
    context.read<ReportBloc>().add(const LoadSales());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final grouping = context.read<ReportBloc>().state.grouping;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            periodLabel(widget.period.start, grouping, locale),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state.status == ReportStatus.error && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.reportErrorPrefix(state.message!)),
                backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          // The report is still loading, or the page was opened without a
          // valid period (e.g. a cold deep link).
          if (state.status == ReportStatus.loading && state.sales.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.selectedPeriod == null) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(l10n.reportDetailMissingPeriod,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ));
          }

          final sales = state.selectedSales;
          if (sales.isEmpty) {
            return _buildEmptyState(l10n);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(
                left: 16, right: 16, top: 8, bottom: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCard(l10n, state, locale),
                const SizedBox(height: 16),
                ...sales.map((sale) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSaleCard(
                          l10n, sale, locale, state.grouping),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(l10n.reportDetailEmptyTitle,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.reportDetailEmptyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  /// Repeats the period's roll-up: label, total, sale count, item count.
  Widget _buildSummaryCard(
      AppLocalizations l10n, ReportState state, String locale) {
    final period = state.selectedPeriod!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            periodLabel(period.start, state.grouping, locale),
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.reportTotalLabel.toUpperCase(),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                            letterSpacing: 1.1)),
                    const SizedBox(height: 2),
                    Text('\$${period.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: AppTheme.primaryColor)),
                  ],
                ),
              ),
              _buildStat(
                  l10n.reportDetailSalesLabel, period.saleCount.toString()),
              const SizedBox(width: 16),
              _buildStat(
                  l10n.reportDetailItemsLabel, period.itemsCount.toString()),
            ],
          ),
        ],
      ),
    );
  }

  /// Small labeled figure inside the summary card.
  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A))),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildSaleCard(
      AppLocalizations l10n, Sale sale, String locale, SalesGrouping grouping) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt,
                    color: AppTheme.primaryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                    saleTimeLabel(sale.createdAt, grouping, locale),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              Text('\$${sale.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0F172A))),
            ],
          ),
          if (sale.lineItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[100]),
            const SizedBox(height: 12),
            ...sale.lineItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildLineItem(l10n, item),
                )),
            Divider(height: 1, color: Colors.grey[100]),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.reportDetailProductCount(sale.lineItems.length),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
                Text('\$${sale.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLineItem(AppLocalizations l10n, SaleLineItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.productName,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                l10n.reportDetailLineItemSummary(
                    item.quantity, '\$${item.unitPrice.toStringAsFixed(2)}'),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text('\$${item.total.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A))),
      ],
    );
  }
}
