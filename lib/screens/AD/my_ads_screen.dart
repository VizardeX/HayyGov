import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAdsScreen extends StatelessWidget {
  const MyAdsScreen({super.key});

  Future<void> _deleteAd(BuildContext context, String adId) async {
    try {
      await FirebaseFirestore.instance.collection('ads').doc(adId).delete();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ad deleted successfully")));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
    }
  }

  void _editAd(BuildContext context, String adId, Map<String, dynamic> currentData) {
    final titleController = TextEditingController(text: currentData['title']);
    final descController = TextEditingController(text: currentData['description']);
    final imageUrlController = TextEditingController(text: currentData['imageUrl'] ?? '');
    final locationController = TextEditingController(text: currentData['location'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.edit_note, color: Colors.brown, size: 28),
            SizedBox(width: 8),
            Text("Edit Ad", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  filled: true,
                  fillColor: Colors.brown.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  filled: true,
                  fillColor: Colors.brown.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(
                  labelText: "Image URL (optional)",
                  filled: true,
                  fillColor: Colors.brown.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: "Location (optional)",
                  filled: true,
                  fillColor: Colors.brown.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('ads').doc(adId).update({
                  'title': titleController.text.trim(),
                  'description': descController.text.trim(),
                  'imageUrl': imageUrlController.text.trim(),
                  'location': locationController.text.trim(),
                  'approved': false, // Needs re-approval
                  'disapproved': false, // Reset disapproval if any
                  'timestamp': Timestamp.now(),
                });
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ad updated. Awaiting re-approval.")));
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed: $e")));
              }
            },
            icon: const Icon(Icons.save, size: 20),
            label: const Text("Save"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text("❌ Not logged in."));
    }

    final adQuery = FirebaseFirestore.instance
        .collection('ads')
        .where('advertiserId', isEqualTo: uid)
        .orderBy('timestamp', descending: true);

    return Scaffold(
      backgroundColor: const Color(0xFFE5E0DB),
      body: StreamBuilder<QuerySnapshot>(
        stream: adQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("🔥 Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("📭 You haven't posted any ads yet."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final ad = doc.data() as Map<String, dynamic>;
              final title = ad['title'] ?? '';
              final description = ad['description'] ?? '';
              final imageUrl = ad['imageUrl'];
              final location = ad['location'] ?? '';
              final approved = ad['approved'] ?? false;
              final disapproved = ad['disapproved'] ?? false;

              String status = approved
                  ? "✅ Approved"
                  : disapproved
                      ? "❌ Disapproved"
                      : "⏳ Awaiting approval";

              Color statusColor = approved
                  ? Colors.green
                  : disapproved
                      ? Colors.red
                      : Colors.orange;

              return Card(
                margin: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(description),
                          if (location.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(location, style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      trailing: Text(status, style: TextStyle(color: statusColor)),
                    ),
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                height: 200,
                                fit: BoxFit.contain, // No stretching, keep original aspect ratio
                              ),
                            ),
                          ],
                        ),
                      ),
                    OverflowBar(
                      alignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () => _editAd(context, doc.id, ad),
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Ad', style: TextStyle(fontWeight: FontWeight.bold)),
                                content: const Text('Are you sure you want to delete this ad? This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              _deleteAd(context, doc.id);
                            }
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text("Delete"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
