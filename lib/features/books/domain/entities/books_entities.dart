class BooksEntity {
  final String? id;
  final String title;
  final String author;
  final String price;
  final String description;
  final String category;
  final String? coverImage;
  final String? sellerId;
  final String? sellerName;

  const BooksEntity({
    this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.description,
    required this.category,
    this.coverImage,
    this.sellerId,
    this.sellerName,
  });
}