import 'package:cryptopulse/models/cryptocurrency_model.dart';
import 'package:cryptopulse/services/api_service.dart';
import 'package:cryptopulse/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:cryptopulse/widgets/common/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:cryptopulse/controllers/prices_controller.dart';
import 'package:cryptopulse/themes/text_styles.dart';
import 'package:cryptopulse/widgets/common/gradient_card.dart';

class PricesScreen extends StatelessWidget {
  const PricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = PricesController();
        controller.fetchCryptos();
        return controller;
      },
      child: const _PricesScreenBody(),
    );
  }
}

class _PricesScreenBody extends StatelessWidget {
  const _PricesScreenBody();

  void _showAddPortfolioDialog(BuildContext context, Cryptocurrency crypto) {
    final quantityController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة ${crypto.name} للمحفظة', style: AppTextStyles.headline),
          content: TextField(
            controller: quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'أدخل الكمية',
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                final quantity = double.tryParse(quantityController.text);
                if (quantity != null && quantity > 0) {
                  await DatabaseHelper.instance.addOrUpdatePortfolioItem(1, crypto, quantity);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تمت إضافة ${crypto.name} إلى محفظتك!')),
                    );
                  }
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PricesController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('أسعار العملات', style: AppTextStyles.headline),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: controller.loading
            ? const Center(child: CircularProgressIndicator())
            : controller.error != null
                ? Center(child: Text('حدث خطأ: ${controller.error}', style: AppTextStyles.error))
                : controller.cryptos.isEmpty
                    ? const Center(child: Text('No cryptocurrencies found.'))
                    : RefreshIndicator(
                        onRefresh: () => controller.fetchCryptos(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.cryptos.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final crypto = controller.cryptos[index];
                            return GradientCard(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              child: PricesCryptoListTile(
                                crypto: crypto,
                                onLongPress: () => _showAddPortfolioDialog(context, crypto),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}

class PricesCryptoListTile extends StatelessWidget {
  final Cryptocurrency crypto;
  final VoidCallback? onLongPress;
  const PricesCryptoListTile({super.key, required this.crypto, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final priceChange = crypto.priceChangePercentage24h;
    final color = priceChange >= 0 ? Colors.green : Colors.red;
    return ListTile(
      onLongPress: onLongPress,
      leading: Image.network(crypto.image, width: 40, height: 40),
      title: Text(crypto.name, style: AppTextStyles.cardTitle),
      subtitle: Text(crypto.symbol.toUpperCase(), style: AppTextStyles.cardSubtitle),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${crypto.currentPrice.toStringAsFixed(2)}',
            style: AppTextStyles.cardTitle,
          ),
          Text(
            '${priceChange.toStringAsFixed(2)}%',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
} 