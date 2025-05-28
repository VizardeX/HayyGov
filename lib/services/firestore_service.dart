import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/emergency_contact.dart';
import 'local_storage_service.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _localStorage = LocalStorageService();

  // Check if the device is online
  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Fetch contacts either from Firestore or local storage
  Future<List<EmergencyContact>> getContacts() async {
    final online = await _isOnline();

    if (online) {
      try {
        // Get contacts from Firestore
        final snapshot = await _db.collection('emergency_numbers').get();
        final contacts = snapshot.docs
            .map((doc) => EmergencyContact.fromFirestore(doc.data()))
            .toList();

        // Cache the data in local storage
        await _localStorage.saveContacts(contacts);
        return contacts;
      } catch (e) {
        // If there's an error fetching from Firestore, fallback to local storage
        return await _localStorage.loadContacts();
      }
    } else {
      // If offline, load contacts from local storage
      return await _localStorage.loadContacts();
    }
  }

  // Fetch contacts from Firestore as a stream (useful for real-time updates)
  Stream<List<EmergencyContact>> getContactsStream() {
    return _db.collection('emergency_numbers').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => EmergencyContact.fromFirestore(doc.data()))
          .toList();
    });
  }

  // Get contacts from local storage if available
  Future<List<EmergencyContact>> getContactsOffline() async {
    return await _localStorage.loadContacts();
  }

  // Add a new contact
  Future<void> addContact(EmergencyContact contact) async {
    await _db.collection('emergency_numbers').add(contact.toFirestore());
  }

  // Delete a contact by ID
  Future<void> deleteContact(String id) async {
    final snapshot = await _db
        .collection('emergency_numbers')
        .where('id', isEqualTo: id)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
