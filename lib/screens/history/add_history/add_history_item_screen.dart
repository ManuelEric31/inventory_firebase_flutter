import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_firebase/models/history.dart';
import 'package:inventory_firebase/models/products.dart';
import 'package:inventory_firebase/widgets/textfields/history/date_textfield.dart';
import 'package:inventory_firebase/widgets/textfields/history/item_quantity_textfield.dart';

class AddHistoryScreen extends StatefulWidget {
  final Product product;
  const AddHistoryScreen({super.key, required this.product});

  @override
  State<AddHistoryScreen> createState() => _AddHistoryScreenState();
}

class _AddHistoryScreenState extends State<AddHistoryScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _selectedTransactionType = 'Masuk';
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _addHistory() async {
    if (_quantityController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields must be filled!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final int quantity = int.parse(_quantityController.text);
      final DateTime date = DateFormat.yMd().parse(_dateController.text);

      if (_selectedTransactionType == 'Keluar' &&
          widget.product.stok < quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock is not enough!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final history = History(
        transactionType: _selectedTransactionType,
        quantity: quantity,
        date: date,
      );

      final historyRef = FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .collection('history')
          .doc();

      await historyRef.set(history.toMap());
      final newStock = widget.product.stok +
          (_selectedTransactionType == 'Masuk' ? quantity : -quantity);

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .update({'stok': newStock});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('History added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Tambah Riwayat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quantity'),
                ItemQuantityTextfield(controllerTyped: _quantityController),
                const SizedBox(height: 16),
                const Text('Date'),
                DateTextfield(
                  controllerDate: _dateController,
                ),
                const SizedBox(height: 16),
                const Text('Transaction Type'),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: DropdownButton<String>(
                      menuWidth: double.infinity,
                      value: _selectedTransactionType,
                      items: ['Masuk', 'Keluar'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTransactionType = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: MaterialButton(
                    height: 48,
                    onPressed: _addHistory,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: const Color.fromARGB(255, 0, 28, 53),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
