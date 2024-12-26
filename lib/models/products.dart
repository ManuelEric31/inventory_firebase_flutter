class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String description;
  final int stok;
  final String imageUrl;
  final String supplierId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.stok,
    required this.imageUrl,
    required this.supplierId,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      category: map['category'] ?? '',
      description: map['description'],
      stok: map['stok'] ?? 0,
      imageUrl: map['imageUrl'],
      supplierId: map['supplierId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'stok': stok,
      'imageUrl': imageUrl,
      'supplierId': supplierId,
    };
  }
}
