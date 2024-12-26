import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_firebase/models/history.dart';
import 'package:inventory_firebase/models/products.dart';
import 'package:inventory_firebase/models/suppliers.dart';
import 'package:inventory_firebase/screens/history/add_history/add_history_item_screen.dart';
import 'package:inventory_firebase/screens/item/update_product_screen.dart';
import 'package:inventory_firebase/widgets/placeholder/placeholdersmall_history.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Supplier?> _supplierFuture;

  @override
  void initState() {
    super.initState();
    _supplierFuture = _fetchSupplier(widget.product.supplierId);
  }

  String _formatHarga(double harga) {
    if (harga == harga.toInt()) {
      return NumberFormat("#,###", "id_ID").format(harga.toInt());
    } else {
      return NumberFormat("#,###.##", "id_ID").format(harga);
    }
  }

  Future<Supplier?> _fetchSupplier(String supplierId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('suppliers')
          .doc(supplierId)
          .get();
      if (doc.exists) {
        return Supplier.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error fetching supplier: $e');
    }
    return null;
  }

  Future<void> _deleteProduct() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                final historyCollection = FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.product.id)
                    .collection('history');

                final historyDocs = await historyCollection.get();
                for (var doc in historyDocs.docs) {
                  await doc.reference.delete();
                }

                if (widget.product.imageUrl.isNotEmpty) {
                  final ref = FirebaseStorage.instance
                      .refFromURL(widget.product.imageUrl);
                  await ref.delete();
                }

                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.product.id)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context);
                Navigator.pop(context);
              } catch (e) {
                debugPrint('Error deleting product: $e');
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void onSelectedMenu(BuildContext context, int value) {
    switch (value) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateProductScreen(product: widget.product),
          ),
        );
        break;
      case 1:
        _deleteProduct();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<int>(
              color: Colors.white,
              onSelected: (value) => onSelectedMenu(context, value),
              itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 0,
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 1,
                      child: Text('Delete'),
                    ),
                  ])
        ],
        title: Text(
          widget.product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.product.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.product.imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.image_not_supported, size: 200),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 0, 0),
                      Color.fromARGB(255, 0, 22, 69),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Category:', widget.product.category),
                    const SizedBox(height: 12),
                    _buildInfoColumn(
                        'Description:', widget.product.description),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        'Price:', 'Rp${_formatHarga(widget.product.price)}'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Stock:', '${widget.product.stok}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<Supplier?>(
                future: _supplierFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Text(
                      'Supplier information not available',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    );
                  }
                  final supplier = snapshot.data!;
                  return ExpansionTile(
                    initiallyExpanded: false,
                    title: const Text(
                      'Supplier Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    children: [
                      ListTile(
                        title: const Text(
                          'Name:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          supplier.name,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'Contact:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          supplier.contact,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'Lat:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${supplier.latitude}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'Long:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${supplier.longitude}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Item History',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 28, 53),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color.fromARGB(255, 0, 28, 53),
                        ),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddHistoryScreen(product: widget.product),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                            Text(
                              'Add History',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.product.id)
                    .collection('history')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const PlaceholdersmallNoItem();
                  }

                  final histories = snapshot.data!.docs
                      .map((doc) =>
                          History.fromMap(doc.data() as Map<String, dynamic>))
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: histories.length,
                      itemBuilder: (context, index) {
                        final history = histories[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: SizedBox(
                            height: 120,
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/framebackgroundriwayat.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                child: Center(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: Text(
                                      '${DateFormat.yMd().format(history.date)}\nQuantity: ${history.quantity}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      history.transactionType,
                                      style: TextStyle(
                                        color:
                                            history.transactionType == 'Masuk'
                                                ? Colors.green
                                                : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }
}
