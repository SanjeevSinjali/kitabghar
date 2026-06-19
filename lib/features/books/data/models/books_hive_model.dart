import 'package:kitabghar/features/books/domain/entities/books_entities.dart';

class BooksHiveModel {
  final String? id;
  final String title;
  final String author;
  final String price;
  final String description;
  final String category;
  final String? coverImage;
  final String? sellerId;
  final String? sellerName;

  const BooksHiveModel({
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

  factory BooksHiveModel.fromJson(Map<String, dynamic> json) {
    return BooksHiveModel(
      id: json['_id'],
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      price: json['price'].toString(),
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      coverImage: json['coverImage'],
      sellerId: json['seller'] is Map
          ? json['seller']['_id']
          : json['seller'],
      sellerName: json['seller'] is Map
          ? json['seller']['name']
          : null,
    );
  }

  Map<String, String> toFields() {
    return {
      'title': title,
      'author': author,
      'price': price,
      'description': description,
      'category': category,
    };
  }

  BooksEntity toEntity() {
    return BooksEntity(
      id: id,
      title: title,
      author: author,
      price: price,
      description: description,
      category: category,
      coverImage: coverImage,
      sellerId: sellerId,
      sellerName: sellerName,
    );
  }

  factory BooksHiveModel.fromEntity(BooksEntity entity) {
    return BooksHiveModel(
      id: entity.id,
      title: entity.title,
      author: entity.author,
      price: entity.price,
      description: entity.description,
      category: entity.category,
      coverImage: entity.coverImage,
      sellerId: entity.sellerId,
      sellerName: entity.sellerName,
    );
  }
}