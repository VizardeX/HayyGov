import 'package:flutter/material.dart';
import '../../models/emergency_contact.dart';
import '../../services/firestore_service.dart';
import '../../widgets/contact_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firestoreService = FirestoreService();
  List<EmergencyContact> _offlineContacts = [];

  @override
  void initState() {
    super.initState();
    _loadOfflineContacts();
  }

  void _loadOfflineContacts() async {
    final contacts = await firestoreService.getContactsOffline();
    setState(() {
      _offlineContacts = contacts;
    });
  }

  Future<void> _reloadContacts() async {
    // Reload contacts from Firestore and update UI
    final contacts = await firestoreService.getContacts();
    setState(() {
      _offlineContacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E0DB),
      // appBar: AppBar(
      //   title: const Text('Emergency Numbers'),
      //   backgroundColor: Colors.brown,
      //   foregroundColor: Colors.white,
      // ),
      body: RefreshIndicator(
        onRefresh: _reloadContacts, // trigger reload when pulled
        child: StreamBuilder<List<EmergencyContact>>(
          stream: firestoreService.getContactsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _offlineContacts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final contacts = snapshot.data ?? _offlineContacts;

            if (contacts.isEmpty) {
              return const Center(child: Text('No contacts available.'));
            }

            return ListView(
              children: contacts
                  .map((contact) => ContactCard(contact: contact))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
