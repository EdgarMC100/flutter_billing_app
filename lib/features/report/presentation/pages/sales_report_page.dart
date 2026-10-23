import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/sales_aggregator.dart';
import '../bloc/report_bloc.dart';
import '../period_label.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  @override
  void initState() {
    super.initState();
    // Refresh so sales recorded since app start (or by a concurrent
    // checkout) show up when the page is opened.
    context.read<ReportBloc>().add(const LoadSales());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportAppBarTitle,
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
          if (state.status == ReportStatus.loading && state.sales.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ReportStatus.error && state.sales.isEmpty) {
            return Center(
                child: Text(l10n.reportErrorPrefix(state.message ?? '')));
          }
          if (state.sales.isEmpty) {
            return _buildEmptyState(l10n);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(
                left: 16, right: 16, top: 8, bottom: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGroupingSelector(l10n, state.grouping),
                const SizedBox(height: 16),
                _buildTotalCard(l10n, state),
                const SizedBox(height: 16),
                _buildChartCard(l10n, state.periods, state.grouping),
                const SizedBox(height: 16),
                ...state.periods.reversed.map((period) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPeriodCard(l10n, period, state.grouping),
                    )),              ],
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
            Text(l10n.reportEmptyTitle,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.reportEmptyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  /// Hand-rolled segmented control (Day / Biweekly / Month) matching the
  /// app's Container + InkWell habit instead of Material selection widgets.
  Widget _buildGroupingSelector(
      AppLocalizations l10n, SalesGrouping current) {
    final options = [
      (SalesGrouping.day, l10n.reportGroupDay),
      (SalesGrouping.biweekly, l10n.reportGroupBiweekly),
      (SalesGrouping.month, l10n.reportGroupMonth),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: options.map((option) {
          final (grouping, label) = option;
          final selected = grouping == current;
          return Expanded(
            child: InkWell(
              onTap: () => context
                  .read<ReportBloc>()
                  .add(ChangeGrouping(grouping)),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalCard(AppLocalizations l10n, ReportState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.reportTotalLabel.toUpperCase(),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                  letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(
            '\$${state.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.reportAllTimeSalesCount(state.sales.length),
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(
      AppLocalizations l10n, List<SalesPeriod> periods, SalesGrouping grouping) {
    if (periods.isEmpty) {
      return const SizedBox.shrink();
    }
    // Cap the chart to the most recent 12 periods to stay readable; the
    // list below always shows everything.
    final chartPeriods = periods.length > 12
        ? periods.sublist(periods.length - 12)
        : periods;
    final maxTotal = chartPeriods
        .map((p) => p.total)
        .fold<double>(0, (max, total) => total > max ? total : max);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.reportChartTitle.toUpperCase(),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                  letterSpacing: 1.2)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxTotal > 0 ? maxTotal * 1.2 : 1,
                barGroups: [
                  for (var i = 0; i < chartPeriods.length; i++)
                    BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: chartPeriods[i].total,
                        width: 18,
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      )
                    ]),
                ],
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF0F172A),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                            '\$${rod.toY.toStringAsFixed(2)}',
                            const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= chartPeriods.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            periodLabel(
                                chartPeriods[index].start,
                                grouping,
                                Localizations.localeOf(context)
                                    .languageCode,
                                short: true),
                            style: TextStyle(
                                fontSize: 9, color: Colors.grey[500]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(
      AppLocalizations l10n, SalesPeriod period, SalesGrouping grouping) {
    final locale = Localizations.localeOf(context).languageCode;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/sales/period', extra: period),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_groupingIcon(grouping),
                    color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      periodLabel(period.start, grouping, locale),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.reportPeriodSummary(
                          period.saleCount, period.itemsCount),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${period.total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F172A)),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _groupingIcon(SalesGrouping grouping) {
    switch (grouping) {
      case SalesGrouping.day:
        return Icons.today;
      case SalesGrouping.biweekly:
        return Icons.calendar_view_month;
      case SalesGrouping.month:
        return Icons.calendar_month;
    }
  }
}
