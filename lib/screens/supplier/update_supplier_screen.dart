import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inventory_firebase/models/products.dart';
import 'package:inventory_firebase/models/suppliers.dart';
import 'package:location/location.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpdateSupplierScreen extends StatefulWidget {
  final Supplier supplier;

  const UpdateSupplierScreen({super.key, required this.supplier});

  @override
  State<UpdateSupplierScreen> createState() => _UpdateSupplierScreenState();
}

class _UpdateSupplierScreenState extends State<UpdateSupplierScreen> {
  final TextEditingController controllerTypedSupplierName =
      TextEditingController();
  final TextEditingController controllerTypedSupplierContact =
      TextEditingController();
  final TextEditingController controllerLongitude = TextEditingController();
  final TextEditingController controllerLatitude = TextEditingController();
  bool isEditing = false;
  LatLng? selectedPosition;
  String appBarTitle = 'Detail Supplier';

  @override
  void initState() {
    super.initState();
    controllerTypedSupplierName.text = widget.supplier.name;
    controllerTypedSupplierContact.text = widget.supplier.contact;
    controllerLongitude.text = widget.supplier.longitude.toString();
    controllerLatitude.text = widget.supplier.latitude.toString();
    selectedPosition =
        LatLng(widget.supplier.latitude, widget.supplier.longitude);
  }

  Future<void> _updateSupplier() async {
    if (!isEditing) return;

    if (controllerTypedSupplierName.text.isEmpty ||
        controllerTypedSupplierContact.text.isEmpty ||
        controllerLongitude.text.isEmpty ||
        controllerLatitude.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields must be filled!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedSupplier = Supplier(
      id: widget.supplier.id,
      name: controllerTypedSupplierName.text,
      contact: controllerTypedSupplierContact.text,
      latitude: double.parse(controllerLatitude.text),
      longitude: double.parse(controllerLongitude.text),
    );

    await FirebaseFirestore.instance
        .collection('suppliers')
        .doc(widget.supplier.id)
        .update(updatedSupplier.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Supplier updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {
      isEditing = false;
    });
  }

  Future<void> _deleteSupplierAndProducts() async {
    final productsSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('supplierId', isEqualTo: widget.supplier.id)
        .get();

    for (var doc in productsSnapshot.docs) {
      final product = Product.fromMap(doc.data());
      if (product.imageUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(product.imageUrl).delete();
        } catch (e) {
          print('Error deleting image: $e');
        }
      }
    }

    for (var doc in productsSnapshot.docs) {
      await doc.reference.delete();
    }

    await FirebaseFirestore.instance
        .collection('suppliers')
        .doc(widget.supplier.id)
        .delete();

    Navigator.pop(context);
  }

  Future<void> _openMap() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: MapDialog(
          initialPosition: selectedPosition ??
              LatLng(widget.supplier.latitude, widget.supplier.longitude),
          onLocationSelected: (LatLng location) {
            setState(() {
              selectedPosition = location;
              controllerLongitude.text = location.longitude.toString();
              controllerLatitude.text = location.latitude.toString();
            });
          },
        ),
      ),
    );
  }

  Future<void> _showLocationOnMap() async {
    final currentLat = double.parse(controllerLatitude.text);
    final currentLong = double.parse(controllerLongitude.text);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: MapDialog(
          initialPosition: LatLng(currentLat, currentLong),
          readOnly: true,
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: const Text(
          'Are you sure you want to delete this supplier? This will also delete all associated products and images.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSupplierAndProducts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(appBarTitle),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              if (value == 'edit') {
                setState(() {
                  isEditing = true;
                  appBarTitle = 'Update Supplier';
                });
              } else if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Name'),
              TextField(
                controller: controllerTypedSupplierName,
                enabled: isEditing,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Phone Contact'),
              TextField(
                controller: controllerTypedSupplierContact,
                enabled: isEditing,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Supplier Longitude'),
              TextField(
                controller: controllerLongitude,
                enabled: isEditing,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Supplier Latitude'),
              TextField(
                controller: controllerLatitude,
                enabled: isEditing,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 165,
                    child: MaterialButton(
                      height: 40,
                      onPressed: _showLocationOnMap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.map,
                            size: 16,
                            color: Color.fromARGB(255, 0, 28, 53),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Show Location',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 28, 53),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isEditing)
                    SizedBox(
                      width: 180,
                      child: MaterialButton(
                        height: 40,
                        onPressed: _openMap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.location_city,
                              size: 16,
                              color: Color.fromARGB(255, 0, 28, 53),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Update Location',
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 28, 53),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: MaterialButton(
                    onPressed: _updateSupplier,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: const Color.fromARGB(255, 0, 28, 53),
                    child: const Text(
                      'Update Supplier',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapDialog extends StatefulWidget {
  final LatLng initialPosition;
  final Function(LatLng)? onLocationSelected;
  final bool readOnly;

  const MapDialog({
    super.key,
    required this.initialPosition,
    this.onLocationSelected,
    this.readOnly = false,
  });

  @override
  State<MapDialog> createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  late GoogleMapController mapController;
  late LatLng selectedLocation;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialPosition;
    _updateMarkers();
  }

  void _updateMarkers() {
    markers = {
      Marker(
        markerId: const MarkerId('selected_location'),
        position: selectedLocation,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialPosition,
                zoom: 15,
              ),
              markers: markers,
              onMapCreated: (controller) => mapController = controller,
              onTap: widget.readOnly
                  ? null
                  : (location) {
                      setState(() {
                        selectedLocation = location;
                        _updateMarkers();
                      });
                    },
            ),
          ),
          if (!widget.readOnly)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onLocationSelected?.call(selectedLocation);
                      Navigator.pop(context);
                    },
                    child: const Text('Select'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
