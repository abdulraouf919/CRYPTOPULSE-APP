class NewsArticle {
  final String title;
  final String url;
  final String source;
  final String imageUrl;

  NewsArticle({
    required this.title,
    required this.url,
    required this.source,
    required this.imageUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      url: json['url'] ?? '',
      source: json['source_info']?['name'] ?? 'Unknown Source',
      imageUrl: json['imageurl'] ?? '',
    );
  }
}

 