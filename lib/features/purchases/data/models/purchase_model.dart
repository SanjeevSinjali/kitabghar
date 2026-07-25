import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';

class PurchaseModel {
  final String? id;
  final String bookId;
  final String title;
  final String author;
  final String price;
  final String image;
  final String condition;
  final DateTime? createdAt;

  const PurchaseModel({
    this.id,
    required this.bookId,
    required this.title,
    required this.author,
    required this.price,
    required this.image,
    required this.condition,
    this.createdAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['_id'],
      bookId: json['bookId'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      price: json['price']?.toString() ?? '',
      image: json['image'] ?? '',
      condition: json['condition'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toBody() => {
        'bookId': bookId,
        'title': title,
        'author': author,
        'price': price,
        'image': image,
        'condition': condition,
      };

  PurchaseEntity toEntity() => PurchaseEntity(
        id: id,
        bookId: bookId,
        title: title,
        author: author,
        price: price,
        image: image,
        condition: condition,
        createdAt: createdAt,
      );

  factory PurchaseModel.fromEntity(PurchaseEntity entity) => PurchaseModel(
        id: entity.id,
        bookId: entity.bookId,
        title: entity.title,
        author: entity.author,
        price: entity.price,
        image: entity.image,
        condition: entity.condition,
        createdAt: entity.createdAt,
      );
}