class WishlistEntity {
  final String? id;
  final String bookId;
  final String title;
  final String author;
  final String price;
  final String image;
  final String condition;

  const WishlistEntity({
    this.id,
    required this.bookId,
    required this.title,
    required this.author,
    required this.price,
    required this.image,
    required this.condition,
  });
}