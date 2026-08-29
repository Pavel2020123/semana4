class Category {
  final String slug;
  final String name;
  final String url;

  Category({required this.slug, required this.name, required this.url});

  factory Category.fromJson(Map<String, dynamic> j) {
    return Category(slug: j['slug'], name: j['name'], url: j['url']);
  }
}
