import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDialog extends StatefulWidget {
  final LatLng initialPosition;
  final ValueChanged<LatLng> onLocationSelected;

  const MapDialog({
    required this.initialPosition,
    required this.onLocationSelected,
    super.key,
  });

  @override
  State<MapDialog> createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  late GoogleMapController _mapController;
  LatLng? _pickedLocation;
  String? _placeName;

  void _onMapTap(LatLng location) async {
    setState(() {
      _pickedLocation = location;
    });

    _placeName = await _getPlaceName(location);
  }

  Future<String> _getPlaceName(LatLng location) async {
    return 'Selected Place';
  }

  void _saveLocation() {
    if (_pickedLocation != null) {
      widget.onLocationSelected(_pickedLocation!);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick a location first.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition,
              zoom: 16,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onMapTap,
            onLongPress: _onMapTap,
            markers: _pickedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('picked-location'),
                      position: _pickedLocation!,
                      infoWindow: InfoWindow(
                        title: _placeName ?? 'Unknown Place',
                        snippet:
                            'Lat: ${_pickedLocation!.latitude}, Lng: ${_pickedLocation!.longitude}',
                      ),
                    )
                  }
                : {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 28, 53),
            ),
            onPressed: _saveLocation,
            child: const Text(
              'Save Location',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
