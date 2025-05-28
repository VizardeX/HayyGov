import 'package:uuid/uuid.dart';

final Uuid uuid = Uuid();

final EmergencyContact contact = EmergencyContact(
  id: uuid.v4(), // Generate a unique ID
  name: 'Ambulance',
  number: '12345',
  iconUrl: 'https://example.com/icon.png',
);

class EmergencyContact {
  final String id; // Add a unique id
  final String name;
  final String number;
  final String iconUrl;

  String? nameEn;
  String? nameAr;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.number,
    required this.iconUrl,
    this.nameEn,
    this.nameAr,
  });

  // Save to SharedPreferences and Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include the id
      'name': name,
      'number': number,
      'iconUrl': iconUrl,
    };
  }

  // Load from SharedPreferences
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] ?? '',  // Ensure to parse the id
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
    );
  }

  // Load from Firestore
  factory EmergencyContact.fromFirestore(Map<String, dynamic> data) {
    return EmergencyContact(
      id: data['id'] ?? '',  // Ensure to parse the id
      name: data['name'] ?? '',
      number: data['number'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
    );
  }

  // Save to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'iconUrl': iconUrl,
    };
  }
}
