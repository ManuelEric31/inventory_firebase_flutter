class Supplier {
  final String id;
  final String name;
  final String contact;
  final double latitude;
  final double longitude;

  Supplier({
    required this.id,
    required this.name,
    required this.contact,
    required this.latitude,
    required this.longitude,
  });

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
