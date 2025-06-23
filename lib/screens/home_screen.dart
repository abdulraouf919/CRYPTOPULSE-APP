import 'package:cryptopulse/models/cryptocurrency_model.dart';
import 'package:cryptopulse/models/news_article_model.dart';
import 'package:cryptopulse/models/portfolio_item_model.dart';
import 'package:cryptopulse/screens/prices_screen.dart';
import 'package:cryptopulse/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:cryptopulse/themes/text_styles.dart';
import 'package:cryptopulse/widgets/common/gradient_card.dart';

class HomeScreen extends StatelessWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = HomeController(userId: userId);
        controller.fetchDashboardData();
        return controller;
      },
      child: const _HomeScreenBody(),
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة التحكم', style: AppTextStyles.headline),
        centerTitle: true,
      ),
      body: controller.loading
          ? const Center(child: CircularProgressIndicator())
          : controller.error != null
              ? Center(child: Text('حدث خطأ: ${controller.error}', style: AppTextStyles.error))
              : RefreshIndicator(
                  onRefresh: () => controller.fetchDashboardData(),
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildTopHoldingCard(controller.topHolding, currencyFormat),
                      const SizedBox(height: 24),
                      _buildMoversSection(controller.topGainers, controller.topLosers),
                      const SizedBox(height: 24),
                      _buildNewsSection(context, controller.news),
                      const SizedBox(height: 24),
                      _buildViewPricesButton(context),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTopHoldingCard(PortfolioItem? topHolding, NumberFormat formatter) {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أهم عملة في محفظتك',
            style: AppTextStyles.cardSubtitle,
          ),
          const SizedBox(height: 16),
          if (topHolding == null)
            Center(child: Text('محفظتك فارغة.', style: AppTextStyles.white))
          else
            Row(
              children: [
                Image.network(topHolding.imageUrl, width: 40, height: 40),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topHolding.name, style: AppTextStyles.cardTitle.copyWith(fontSize: 20)),
                    Text('${topHolding.quantity} ${topHolding.symbol.toUpperCase()}', style: AppTextStyles.cardSubtitle),
                  ],
                ),
                const Spacer(),
                Text(
                  formatter.format(topHolding.totalValue),
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 22),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMoversSection(List<Cryptocurrency> gainers, List<Cryptocurrency> losers) {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أبرز تحركات السوق',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMoversList(gainers, 'أبرز الرابحين'),
              const SizedBox(width: 16),
              _buildMoversList(losers, 'أبرز الخاسرين'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoversList(List<Cryptocurrency> movers, String title) {
    final bool isGainer = title == 'أبرز الرابحين';
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.cardSubtitle.copyWith(fontSize: 16),
          ),
          const Divider(color: Colors.white24),
          ...movers.map((crypto) => HomeMoverListItem(
                crypto: crypto,
                isGainer: isGainer,
              )),
        ],
      ),
    );
  }

  Widget _buildNewsSection(BuildContext context, List<NewsArticle> articles) {
    if (articles.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if there's no news
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'آخر الأخبار',
          style: AppTextStyles.headline,
        ),
        const SizedBox(height: 12),
        GradientCard(
          color: Colors.black,
          child: Column(
            children: articles.map((article) => HomeNewsListTile(article: article)).toList(),
          ),
          borderRadius: 12.0,
        ),
      ],
    );
  }

  Widget _buildViewPricesButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PricesScreen()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.query_stats, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'استكشف أسعار السوق',
                  style: AppTextStyles.button,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeMoverListItem extends StatelessWidget {
  final Cryptocurrency crypto;
  final bool isGainer;
  const HomeMoverListItem({super.key, required this.crypto, required this.isGainer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Image.network(crypto.image, width: 24, height: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              crypto.symbol.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '${(crypto.priceChangePercentage24h ?? 0.0).toStringAsFixed(2)}%',
            style: TextStyle(color: isGainer ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class HomeNewsListTile extends StatelessWidget {
  final NewsArticle article;
  const HomeNewsListTile({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: article.imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                article.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            )
          : const Icon(Icons.article),
      title: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(article.source, style: AppTextStyles.caption),
      onTap: () async {
        final urlStr = article.url.trim();
        print('Trying to launch: $urlStr');
        if (urlStr.startsWith('http://') || urlStr.startsWith('https://')) {
          final Uri url = Uri.parse(urlStr);
          try {
            final canLaunch = await canLaunchUrl(url);
            print('canLaunch: $canLaunch');
            if (canLaunch) {
              await launchUrl(url);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('لا يمكن فتح الرابط: $urlStr')),
              );
            }
          } catch (e) {
            print('Launch error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('حدث خطأ أثناء محاولة فتح الرابط.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('الرابط غير صالح: $urlStr')),
          );
        }
      },
    );
  }
} 