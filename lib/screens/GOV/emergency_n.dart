import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/emergency_contact.dart';
import '../../services/firestore_service.dart';
import '../../widgets/contact_card.dart';
import '../AD/ad_approval_screen.dart';

class EmergencyN extends StatefulWidget {
  const EmergencyN({super.key});

  @override
  State<EmergencyN> createState() => _EmergencyNState();
}

class _EmergencyNState extends State<EmergencyN> {
  final FirestoreService firestoreService = FirestoreService();
  final Uuid uuid = Uuid();
  List<EmergencyContact> _offlineContacts = [];

  bool showAds = false; // For the switch

  @override
  void initState() {
    super.initState();
    _loadOfflineContacts();
  }

  void _loadOfflineContacts() async {
    final contacts = await firestoreService.getContactsOffline();
    if (!mounted) return;
    setState(() {
      _offlineContacts = contacts;
    });
  }

  Future<void> _reloadContacts() async {
    final contacts = await firestoreService.getContacts();
    if (!mounted) return;
    setState(() {
      _offlineContacts = contacts;
    });
  }

  void _addEmergencyContact() async {
    String name = '';
    String number = '';
    String iconUrl = '';

    showModalBottomSheet(
      backgroundColor: Color(0xFFE5E0DB),
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name field with Arabic label inside
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Emergency | الطوارئ',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 14),
              // Number field with Arabic label inside
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Number | الرقم',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) => number = value,
              ),
              const SizedBox(height: 14),
              // Icon URL field
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Icon URL | رابط الأيقونة',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                keyboardType: TextInputType.url,
                onChanged: (value) => iconUrl = value,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2c2c2c),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFF2c2c2c)), // Match the background color
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18), // Smaller padding
                  minimumSize: const Size(0, 36), // Reduce min height
                  elevation: 0,
                ),
                onPressed: () async {
                  final newContact = EmergencyContact(
                    id: uuid.v4(),
                    name: name,
                    number: number,
                    iconUrl: iconUrl,
                  );
                  await firestoreService.addContact(newContact);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Save",
                      style: TextStyle(fontSize: 15, color: Colors.white), // Smaller font
                    ),
                    SizedBox(width: 8), // Less space
                    Text(
                      "حفظ",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteEmergencyContact(EmergencyContact contact) async {
    await firestoreService.deleteContact(contact.id);
    if (!mounted) return;
    setState(() {});
  }

  void _toggleView(bool ads) {
    setState(() {
      showAds = ads;
    });
  }

  void _onHorizontalDrag(DragEndDetails details) {
    // Swipe left to go to AdApproval, right to go to Emergency Numbers
    if (details.primaryVelocity != null) {
      if (details.primaryVelocity! < -50) {
        _toggleView(true);
      } else if (details.primaryVelocity! > 50) {
        _toggleView(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFE5E0DB);
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // const GovDashboardHeader(), // Removed persistent header
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: _onHorizontalDrag,
                child: Column(
                  children: [
                    // --- Switch between Emergency Numbers and Ads Approval ---
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Container(
                        width: 240,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              alignment: showAds ? Alignment.centerRight : Alignment.centerLeft,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                width: 120,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 62, 59, 45),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _toggleView(false);
                                    },
                                    child: Center(
                                      child: Icon(
                                        Icons.call,
                                        color: !showAds ? Colors.white : Colors.red,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _toggleView(true);
                                    },
                                    child: Center(
                                      child: Icon(
                                        Icons.check_circle,
                                        color: showAds ? Colors.white : Colors.green,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // --- End Switch ---
                    Expanded(
                      child: showAds
                          ? const AdApprovalScreen()
                          : RefreshIndicator(
                              onRefresh: _reloadContacts,
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

                                  return ListView.builder(
                                    itemCount: contacts.length,
                                    itemBuilder: (context, index) {
                                      final contact = contacts[index];
                                      return Dismissible(
                                        key: Key(contact.id),
                                        confirmDismiss: (direction) async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18),
                                              ),
                                              backgroundColor: Colors.white,
                                              title: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: const [
                                                  Icon(Icons.delete_forever_rounded, color: Colors.red, size: 38),
                                                  SizedBox(height: 10),
                                                  Text('Delete Emergency Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                                ],
                                              ),
                                              content: const Text(
                                                'This will permanently remove the contact. Are you sure?',
                                                style: TextStyle(fontSize: 16, color: Colors.black87),
                                              ),
                                              actions: [
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.black,
                                                    textStyle: const TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          return confirm == true;
                                        },
                                        onDismissed: (direction) {
                                          _deleteEmergencyContact(contact);
                                        },
                                        background: Container(color: Colors.red),
                                        child: ContactCard(contact: contact),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2c2c2c), // Match the background color
        onPressed: _addEmergencyContact,
        child: const Icon(Icons.add, color: Colors.white), // Use black icon for contrast
      ),
    );
  }
}