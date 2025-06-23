class PortfolioItem {
  final String id;
  final String name;
  final String symbol;
  final double quantity;
  double currentPrice;
  String imageUrl;

  PortfolioItem({
    required this.id,
    required this.name,
    required this.symbol,
    required this.quantity,
    this.currentPrice = 0.0,
    this.imageUrl = '',
  });

  double get totalValue => quantity * currentPrice;
} 