import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_firebase/models/products.dart';
import 'package:inventory_firebase/widgets/chips/category_chip.dart';
import 'package:inventory_firebase/widgets/textfields/item/item_description_textfield.dart';
import 'package:inventory_firebase/widgets/textfields/item/item_name_textfield.dart';
import 'package:inventory_firebase/widgets/textfields/item/item_price_textfield.dart';

class UpdateProductScreen extends StatefulWidget {
  final Product product;

  const UpdateProductScreen({super.key, required this.product});

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  File? selectedImage;
  late TextEditingController controllerTypedItemName;
  late TextEditingController controllerTypedPriceName;
  late TextEditingController controllerTypedDescriptionName;
  late String selectedCategory;
  String? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    controllerTypedItemName = TextEditingController(text: widget.product.name);
    controllerTypedPriceName =
        TextEditingController(text: widget.product.price.toString());
    controllerTypedDescriptionName =
        TextEditingController(text: widget.product.description);
    selectedCategory = widget.product.category;
    _selectedSupplierId = widget.product.supplierId;
  }

  Future<void> _updateProduct() async {
    if (controllerTypedItemName.text.isEmpty ||
        controllerTypedPriceName.text.isEmpty ||
        controllerTypedDescriptionName.text.isEmpty ||
        selectedCategory.isEmpty ||
        _selectedSupplierId == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields must be filled!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      String? imageUrl = widget.product.imageUrl;
      if (selectedImage != null) {
        final ref =
            FirebaseStorage.instance.ref('products/${widget.product.id}.jpg');
        await ref.putFile(selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      final updatedProduct = {
        'name': controllerTypedItemName.text,
        'price': double.parse(controllerTypedPriceName.text),
        'category': selectedCategory,
        'description': controllerTypedDescriptionName.text,
        'imageUrl': imageUrl,
        'supplierId': _selectedSupplierId,
      };

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .update(updatedProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product: $e'),
        ),
      );
    }
  }

  Future<void> _pickImageOption() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final returnedImage = await ImagePicker().pickImage(source: source);
      if (returnedImage != null) {
        setState(() {
          selectedImage = File(returnedImage.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image'),
        ),
      );
    }
  }

  @override
  void dispose() {
    controllerTypedItemName.dispose();
    controllerTypedPriceName.dispose();
    controllerTypedDescriptionName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 0, 28, 53),
            Color.fromARGB(255, 0, 0, 0),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                'Update Product',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _pickImageOption,
                  child: selectedImage == null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.product.imageUrl,
                            width: 320,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(selectedImage!.path),
                            width: 320,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Name'),
                          ItemNameTextfield(
                              controllerTyped: controllerTypedItemName),
                          const Text('Price'),
                          ItemPriceTextfield(
                              controllerTyped: controllerTypedPriceName),
                          const Text('Category'),
                          CategoryChipWidget(
                              selectedCategory: selectedCategory,
                              onCategorySelected: (category) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              }),
                          const Text('Description'),
                          ItemDescriptionTextfield(
                              controllerTyped: controllerTypedDescriptionName),
                          const SizedBox(height: 16),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('suppliers')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              final suppliers = snapshot.data!.docs;
                              if (suppliers.isEmpty) {
                                return const Text(
                                  'No suppliers available',
                                  style: TextStyle(color: Colors.grey),
                                );
                              }
                              return DropdownButton<String>(
                                value: _selectedSupplierId,
                                hint: const Text('Select Supplier'),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSupplierId = value;
                                  });
                                },
                                items: suppliers.map((doc) {
                                  return DropdownMenuItem<String>(
                                    value: doc.id,
                                    child: Text(doc['name']),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: MaterialButton(
                              height: 48,
                              onPressed: _updateProduct,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: const Color.fromARGB(255, 0, 28, 53),
                              child: const Text(
                                'Update',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
