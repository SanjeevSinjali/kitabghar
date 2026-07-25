import 'package:kitabghar/features/books/domain/entities/books_entities.dart';

class BooksHiveModel {
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

  const BooksHiveModel({
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

  factory BooksHiveModel.fromJson(Map<String, dynamic> json) {
    return BooksHiveModel(
      id: json['_id'],
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      price: json['price'].toString(),
      description: json['description'] ?? '',
      category: json['category'] ?? 'Other',
      condition: json['condition'] ?? 'Good',
      image: json['image'],
      sellerId: json['seller'] is Map
          ? json['seller']['_id']
          : json['seller'],
      sellerName: json['seller'] is Map
          ? json['seller']['name']
          : null,
      status: json['status'] ?? 'Active',
      source: json['source'] ?? 'user',
    );
  }

  Map<String, String> toFields() {
    return {
      'title': title,
      'author': author,
      'price': price,
      'description': description,
      'category': category,
      'condition': condition,
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
      condition: condition,
      image: image,
      sellerId: sellerId,
      sellerName: sellerName,
      status: status,
      source: source,
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
      condition: entity.condition,
      image: entity.image,
      sellerId: entity.sellerId,
      sellerName: entity.sellerName,
      status: entity.status,
      source: entity.source,
    );
  }
}