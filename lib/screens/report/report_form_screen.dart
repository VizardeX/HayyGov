import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Import for userId

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController(); // Add image URL controller
  LatLng? _selectedPoint;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  Future<void> _submitReport() async {
    final desc = _descController.text.trim();
    final imageUrl = _imageUrlController.text.trim(); // Get image URL

    if (desc.isEmpty || _selectedPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a location and add a description")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser; // ✅ Get current user

    await FirebaseFirestore.instance.collection('reports').add({
      'description': desc,
      'timestamp': Timestamp.now(),
      'location': {
        'lat': _selectedPoint!.latitude,
        'lng': _selectedPoint!.longitude,
      },
      'userId': user?.uid ?? 'anonymous', // ✅ Save userId
      'imageUrl': imageUrl, // Save image URL
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Report submitted successfully")),
    );

    _descController.clear();
    _imageUrlController.clear(); // Clear image URL
    setState(() => _selectedPoint = null);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }

    Position pos = await Geolocator.getCurrentPosition();
    LatLng userLatLng = LatLng(pos.latitude, pos.longitude);

    _mapController.move(userLatLng, 15);
    setState(() => _selectedPoint = userLatLng);
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(30.033333, 31.233334); // Default: Cairo
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      // appBar: AppBar(title: const Text("Report an Issue")),
      backgroundColor: const Color(0xFFE5E0DB),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height - kToolbarHeight - MediaQuery.of(context).padding.top),
          child: Column(
            children: [
              SizedBox(
                height: height * 0.3,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 13,
                    onTap: (tapPosition, point) {
                      setState(() => _selectedPoint = point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.hayygov',
                    ),
                    if (_selectedPoint != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: _selectedPoint!,
                            child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.my_location, color: Colors.black),
                      label: const Text("Use My Location", style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Describe the problem",
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _imageUrlController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Image URL (optional)",
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: _submitReport,
                      icon: const Icon(Icons.send, color: Colors.black),
                      label: const Text("Submit Report", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
