import 'package:cloud_firestore/cloud_firestore.dart';

class History {
  final String transactionType;
  final int quantity;
  final DateTime date;

  History({
    required this.transactionType,
    required this.quantity,
    required this.date,
  });

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      transactionType: map['transactionType'],
      quantity: map['quantity'],
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionType': transactionType,
      'quantity': quantity,
      'date': date,
    };
  }
}
