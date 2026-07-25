import 'package:kitabghar/features/wishlist/domain/entities/wishlist_entity.dart';

class WishlistModel {
  final String? id;
  final String bookId;
  final String title;
  final String author;
  final String price;
  final String image;
  final String condition;

  const WishlistModel({
    this.id,
    required this.bookId,
    required this.title,
    required this.author,
    required this.price,
    required this.image,
    required this.condition,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['_id'],
      bookId: json['bookId'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      price: json['price']?.toString() ?? '',
      image: json['image'] ?? '',
      condition: json['condition'] ?? '',
    );
  }

  /// Body sent to POST /wishlist/toggle — the backend stores a denormalized
  /// snapshot of the book's details at the time it was wishlisted.
  Map<String, dynamic> toBody() => {
        'bookId': bookId,
        'title': title,
        'author': author,
        'price': price,
        'image': image,
        'condition': condition,
      };

  WishlistEntity toEntity() => WishlistEntity(
        id: id,
        bookId: bookId,
        title: title,
        author: author,
        price: price,
        image: image,
        condition: condition,
      );

  factory WishlistModel.fromEntity(WishlistEntity entity) => WishlistModel(
        id: entity.id,
        bookId: entity.bookId,
        title: entity.title,
        author: entity.author,
        price: entity.price,
        image: entity.image,
        condition: entity.condition,
      );
}