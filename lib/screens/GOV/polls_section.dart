import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_poll_screen.dart';
import '../../services/poll_service.dart';

class PollsSection extends StatelessWidget {
  const PollsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFE5E0DB);
    final Color cardColor = Colors.white;
    final Color borderColor = const Color(0xFFD6CFC7);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // const SizedBox(height: 30), // for status bar space
          // const GovDashboardHeader(), // Removed persistent header
          // --- Polls List ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Polls').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No polls yet.'));
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final pollId = docs[index].id;
                    final title = data['Title'] ?? '';
                    final options = data.entries
                        .where((e) => e.key != 'Title' && e.key != 'Voters')
                        .toList();
                    final totalVotes = options.fold<int>(0, (prev, e) => prev + (e.value as int? ?? 0));

                    return Dismissible(
                      key: Key(pollId),
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 24),
                        child: const Icon(Icons.delete, color: Colors.white, size: 32),
                      ),
                      secondaryBackground: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.edit, color: Colors.white, size: 32),
                            const SizedBox(width: 8),
                            const Text('Edit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          // Delete
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              title: Row(
                                children: const [
                                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                                  SizedBox(width: 8),
                                  Text('Delete Poll'),
                                ],
                              ),
                              content: const Text(
                                'Are you sure you want to delete this poll? This action cannot be undone.',
                                style: TextStyle(fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await PollService().deletePoll(pollId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Poll deleted'), backgroundColor: Colors.red),
                            );
                          }
                          return confirm == true;
                        } else {
                          // Edit
                          final optionKeys = options.map((e) => e.key).toList();
                          final List<String> originalOptions = optionKeys;
                          final List<TextEditingController> optionControllers = optionKeys.map((k) => TextEditingController(text: k)).toList();
                          final titleController = TextEditingController(text: title);
                          await showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                title: Row(
                                  children: const [
                                    Icon(Icons.edit, color: Colors.blue, size: 28),
                                    SizedBox(width: 8),
                                    Text('Edit Poll', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Poll Title', style: TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: titleController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter poll title',
                                          filled: true,
                                          fillColor: const Color(0xFFEADCC8),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      const Text('Options', style: TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      ...optionControllers.asMap().entries.map((entry) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: TextField(
                                          controller: entry.value,
                                          decoration: InputDecoration(
                                            hintText: 'Option ${entry.key + 1}',
                                            filled: true,
                                            fillColor: const Color(0xFFEADCC8),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                    ),
                                    onPressed: () async {
                                      final newTitle = titleController.text.trim();
                                      final newOptions = optionControllers.map((c) => c.text.trim()).where((o) => o.isNotEmpty).toList();
                                      if (newTitle.isEmpty || newOptions.length < 2) return;
                                      final Map<String, dynamic> updateData = {'Title': newTitle};
                                      // Only keep the original options, update their keys if changed
                                      for (int i = 0; i < originalOptions.length; i++) {
                                        final oldKey = originalOptions[i];
                                        final newKey = optionControllers[i].text.trim();
                                        if (newKey.isNotEmpty) {
                                          // If the key changed, move the value
                                          if (oldKey != newKey) {
                                            updateData[newKey] = data[oldKey] ?? 0;
                                            updateData[oldKey] = FieldValue.delete();
                                          } else {
                                            updateData[oldKey] = data[oldKey] ?? 0;
                                          }
                                        }
                                      }
                                      await PollService().updatePoll(pollId, updateData);
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Poll updated'), backgroundColor: Colors.blue));
                                    },
                                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              );
                            },
                          );
                          return false;
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title row
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Choices
                              ...options.asMap().entries.map((entry) {
                                final label = entry.value.key;
                                final count = entry.value.value ?? 0;
                                final percent = totalVotes > 0 ? ((count / totalVotes) * 100).toStringAsFixed(0) : '0';
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEADCC8),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: borderColor, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: Color(0xFF7C7672),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "$percent%",
                                        style: const TextStyle(
                                          color: Color(0xFF7C7672),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2c2c2c),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePollScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Create Poll',
      ),
    );
  }
}