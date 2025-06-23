import 'package:cryptopulse/models/candle_data_model.dart';
import 'package:cryptopulse/models/portfolio_item_model.dart';
import 'package:cryptopulse/controllers/charts_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cryptopulse/widgets/common/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:cryptopulse/themes/text_styles.dart';
import 'package:cryptopulse/widgets/common/gradient_card.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = ChartsController(userId: 1);
        controller.fetchPortfolioAndCharts();
        return controller;
      },
      child: const _ChartsScreenBody(),
    );
  }
}

class _ChartsScreenBody extends StatelessWidget {
  const _ChartsScreenBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChartsController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('مخططات الأسعار', style: AppTextStyles.headline),
        centerTitle: true,
      ),
      body: controller.loading
          ? const Center(child: CircularProgressIndicator())
          : controller.error != null
              ? Center(child: Text('حدث خطأ: ${controller.error}', style: AppTextStyles.error))
              : controller.portfolio.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد عملات في محفظتك لعرض الرسوم البيانية.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => controller.fetchPortfolioAndCharts(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.portfolio.length,
                        itemBuilder: (context, index) {
                          final item = controller.portfolio[index];
                          final chartData = controller.chartData[item.id] ?? [];
                          return CryptoChartCard(item: item, chartData: chartData);
                        },
                      ),
                    ),
    );
  }
}

class CryptoChartCard extends StatelessWidget {
  final PortfolioItem item;
  final List<CandleData> chartData;
  const CryptoChartCard({super.key, required this.item, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GradientCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (item.imageUrl.isNotEmpty)
                  Image.network(item.imageUrl, width: 32, height: 32),
                const SizedBox(width: 8),
                Text(
                  '${item.name} (${item.symbol.toUpperCase()})',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: chartData.isEmpty
                  ? const Center(
                      child: Text("No data available.", style: AppTextStyles.white))
                  : SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      primaryXAxis: DateTimeAxis(
                          dateFormat: DateFormat.E(),
                          majorGridLines: const MajorGridLines(width: 0),
                          axisLine: const AxisLine(width: 0),
                          labelStyle: const TextStyle(color: Colors.white54)),
                      primaryYAxis: NumericAxis(
                        opposedPosition: true,
                        labelStyle: const TextStyle(color: Colors.white54),
                        majorGridLines: const MajorGridLines(
                            width: 0.5, color: Colors.white24),
                      ),
                      series: <CartesianSeries<CandleData, DateTime>>[
                        CandleSeries<CandleData, DateTime>(
                          dataSource: chartData,
                          xValueMapper: (CandleData sales, _) => sales.date,
                          lowValueMapper: (CandleData sales, _) => sales.low,
                          highValueMapper: (CandleData sales, _) => sales.high,
                          openValueMapper: (CandleData sales, _) => sales.open,
                          closeValueMapper: (CandleData sales, _) => sales.close,
                          enableSolidCandles: true,
                          bullColor: Colors.green,
                          bearColor: Colors.red,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 