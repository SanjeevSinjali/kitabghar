class BooksEntity {
  final String? id;
  final String title;
  final String author;
  final String price;
  final String description;
  final String category;
  final String condition;
  final String? image;
  final String? sellerId;
  final String? sellerName;
  final String status;
  final String source;

  const BooksEntity({
    this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.description,
    required this.category,
    this.condition = 'Good',
    this.image,
    this.sellerId,
    this.sellerName,
    this.status = 'Active',
    this.source = 'user',
  });
}