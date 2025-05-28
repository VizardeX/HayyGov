import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../GOV/announcement_feed_screen.dart';
import '../GOV/polls_section.dart';
import '../GOV/emergency_n.dart';
import '../report/report_list_screen.dart';

class AdApprovalScreen extends StatefulWidget {
  const AdApprovalScreen({super.key});

  @override
  State<AdApprovalScreen> createState() => _AdApprovalScreenState();
}

class _AdApprovalScreenState extends State<AdApprovalScreen> {
  String? approvedAdId;
  String? rejectedAdId;

  bool showAds = true; // For the switch

  Future<void> _approveAd(String adId) async {
    await FirebaseFirestore.instance.collection('ads').doc(adId).update({
      'approved': true,
    });
    setState(() {
      approvedAdId = adId;
      rejectedAdId = null;
    });
  }

  Future<void> _deleteAd(String adId) async {
    await FirebaseFirestore.instance.collection('ads').doc(adId).delete();
    setState(() {
      rejectedAdId = adId;
      approvedAdId = null;
    });
  }

  void _navigateToEmergencyN(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => const EmergencyN(),
        transitionsBuilder: (_, animation, __, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(-1.0, 0.0), // Slide from left
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _onHorizontalDrag(DragEndDetails details) {
    // Swipe right to go to EmergencyN
    if (details.primaryVelocity != null && details.primaryVelocity! > 200) {
      _navigateToEmergencyN(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unapprovedAdsRef = FirebaseFirestore.instance
        .collection('ads')
        .where('approved', isEqualTo: false)
        .orderBy('timestamp', descending: true);

    final Color bgColor = const Color(0xFFE5E0DB);

    return Scaffold(
      backgroundColor: const Color(0xFFE5E0DB),
      body: Column(
        children: [
          // const SizedBox(height: 30), // for status bar space
          // --- Switch between Ads and Emergency Numbers ---
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 18.0),
          //   child: Container(
          //     width: 240,
          //     height: 48,
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(24),
          //     ),
          //     child: Stack(
          //       children: [
          //         AnimatedAlign(
          //           alignment: showAds ? Alignment.centerRight : Alignment.centerLeft,
          //           duration: const Duration(milliseconds: 200),
          //           child: Container(
          //             width: 120,
          //             height: 48,
          //             decoration: BoxDecoration(
          //               color: const Color(0xFFBDBDBD),
          //               borderRadius: BorderRadius.circular(24),
          //             ),
          //           ),
          //         ),
          //         Row(
          //           children: [
          //             Expanded(
          //               child: GestureDetector(
          //                 onTap: () {
          //                   if (showAds) {
          //                     setState(() {
          //                       showAds = false;
          //                     });
          //                     _navigateToEmergencyN(context);
          //                   }
          //                 },
          //                 child: Center(
          //                   child: Icon(
          //                     Icons.call,
          //                     color: showAds ? Colors.black : Colors.white,
          //                     size: 28,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //             Expanded(
          //               child: GestureDetector(
          //                 onTap: () {
          //                   // Already on Ads page, do nothing
          //                 },
          //                 child: Center(
          //                   child: Icon(
          //                     Icons.check_circle,
          //                     color: showAds ? Colors.white : Colors.black,
          //                     size: 28,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // // --- End Switch ---
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: _onHorizontalDrag,
              child: StreamBuilder<QuerySnapshot>(
                stream: unapprovedAdsRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text("No ads awaiting approval."));

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final adId = docs[index].id;
                      final title = data['title'];
                      final desc = data['description'];
                      final imageUrl = data['imageUrl'];
                      final location = data['location'] ?? '';
                      final advertiserId = data['advertiserId'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(advertiserId).get(),
                        builder: (context, userSnapshot) {
                          String advertiserEmail = advertiserId;
                          if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData) {
                            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                            if (userData != null && userData.containsKey('email')) {
                              advertiserEmail = userData['email'];
                            }
                          }

                          final isApproved = approvedAdId == adId;
                          final isRejected = rejectedAdId == adId;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFD6CFC7), width: 2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top row: status icon, title, image
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Status icon
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0, right: 4.0),
                                        child: isApproved
                                            ? const Icon(Icons.check_circle, color: Colors.green, size: 26)
                                            : isRejected
                                                ? const Icon(Icons.cancel, color: Colors.red, size: 26)
                                                : const SizedBox(width: 26),
                                      ),
                                      const SizedBox(width: 2),
                                      // Title and desc
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              desc ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 15),
                                            ),
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
                                            Text(
                                              'Advertiser: $advertiserEmail',
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Image
                                      if (imageUrl != null && imageUrl.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            imageUrl,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const SizedBox(width: 80, height: 80),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Approve/Reject buttons row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Approve button
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isApproved ? Colors.green : Colors.white,
                                          foregroundColor: isApproved ? Colors.white : Colors.green,
                                          side: BorderSide(color: Colors.green, width: 2),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                          elevation: isApproved ? 4 : 0,
                                        ),
                                        icon: const Icon(Icons.thumb_up, size: 24),
                                        label: Text(
                                          isApproved ? 'Approved' : 'Approve',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isApproved ? Colors.white : Colors.green,
                                          ),
                                        ),
                                        onPressed: () => _approveAd(adId),
                                      ),
                                      const SizedBox(width: 18),
                                      // Reject button
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isRejected ? Colors.red : Colors.white,
                                          foregroundColor: isRejected ? Colors.white : Colors.red,
                                          side: BorderSide(color: Colors.red, width: 2),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                          elevation: isRejected ? 4 : 0,
                                        ),
                                        icon: const Icon(Icons.thumb_down, size: 24),
                                        label: Text(
                                          isRejected ? 'Rejected' : 'Reject',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isRejected ? Colors.white : Colors.red,
                                          ),
                                        ),
                                        onPressed: () => _deleteAd(adId),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}