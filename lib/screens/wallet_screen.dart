import 'package:cryptopulse/models/cryptocurrency_model.dart';
import 'package:cryptopulse/models/portfolio_item_model.dart';
import 'package:cryptopulse/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cryptopulse/widgets/common/gradient_app_bar.dart';
import 'package:cryptopulse/themes/text_styles.dart';
import 'package:cryptopulse/widgets/common/gradient_card.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = WalletController(userId: 1);
        controller.loadPortfolio();
        return controller;
      },
      child: const _WalletScreenBody(),
    );
  }
}

class _WalletScreenBody extends StatelessWidget {
  const _WalletScreenBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WalletController>();
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text('محفظتي', style: AppTextStyles.headline),
        centerTitle: true,
      ),
      body: controller.loading
          ? const Center(child: CircularProgressIndicator())
          : controller.error != null
              ? Center(child: Text('حدث خطأ: ${controller.error}', style: AppTextStyles.error))
              : controller.portfolio.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'محفظتك فارغة. اضغط مطولاً على أي عملة في شاشة الأسعار لإضافتها.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => controller.loadPortfolio(),
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          _buildBalanceCard(controller, currencyFormat),
                          const SizedBox(height: 24),
                          const Text(
                            'العملات الرقمية',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...controller.portfolio.map((item) => _buildCryptoCard(context, controller, item, currencyFormat)).toList(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildBalanceCard(WalletController controller, NumberFormat currencyFormat) {
    final totalValue = controller.portfolio.fold(0.0, (sum, item) => sum + item.totalValue);
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الرصيد الإجمالي',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(totalValue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoCard(BuildContext context, WalletController controller, PortfolioItem item, NumberFormat formatter) {
    return WalletCryptoCard(
      item: item,
      formatter: formatter,
      onDoubleTap: () => _showEditQuantityDialog(context, controller, item),
    );
  }

  void _showEditQuantityDialog(BuildContext context, WalletController controller, PortfolioItem item) {
    final quantityController = TextEditingController(text: item.quantity.toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل كمية ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الكمية الحالية: ${item.quantity}'),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'الكمية الجديدة',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                final newQuantity = double.tryParse(quantityController.text);
                if (newQuantity != null && newQuantity >= 0) {
                  await controller.updateQuantity(item, newQuantity);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم تحديث كمية ${item.name}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى إدخال كمية صحيحة'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}

class WalletCryptoCard extends StatelessWidget {
  final PortfolioItem item;
  final NumberFormat formatter;
  final VoidCallback? onDoubleTap;
  const WalletCryptoCard({super.key, required this.item, required this.formatter, this.onDoubleTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: GradientCard(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: ListTile(
          leading: Image.network(item.imageUrl, width: 32, height: 32),
          title: Text(
            item.name,
            style: AppTextStyles.cardTitle,
          ),
          subtitle: Text(
            '${item.quantity} ${item.symbol.toUpperCase()}',
            style: AppTextStyles.cardSubtitle,
          ),
          trailing: Text(
            formatter.format(item.totalValue),
            style: AppTextStyles.cardTitle,
          ),
        ),
      ),
    );
  }
} 