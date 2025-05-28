import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';

class ContactCard extends StatefulWidget {
  final EmergencyContact contact;

  const ContactCard({super.key, required this.contact});

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  String? nameEn;
  String? nameAr;

  @override
  void initState() {
    super.initState();
    _loadOrTranslateNames();
  }

  Future<void> _loadOrTranslateNames() async {
    final prefs = await SharedPreferences.getInstance();

    // Keys for caching
    final keyEn = '${widget.contact.name}_en';
    final keyAr = '${widget.contact.name}_ar';

    // Try loading from cache
    final cachedEn = prefs.getString(keyEn);
    final cachedAr = prefs.getString(keyAr);

    if (cachedEn != null && cachedAr != null) {
      setState(() {
        nameEn = cachedEn;
        nameAr = cachedAr;
      });
      return;
    }

    // Otherwise, translate
    final translator = GoogleTranslator();

    try {
      final enTranslation = await translator.translate(widget.contact.name, to: 'en');
      final arTranslation = await translator.translate(widget.contact.name, to: 'ar');

      await prefs.setString(keyEn, enTranslation.text);
      await prefs.setString(keyAr, arTranslation.text);

      setState(() {
        nameEn = enTranslation.text;
        nameAr = arTranslation.text;
      });
    } catch (e) {
      debugPrint('Translation failed: $e');
      setState(() {
        nameEn = widget.contact.name;
        nameAr = widget.contact.name;
      });
    }
  }

  String convertToEasternArabic(String number) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < western.length; i++) {
      number = number.replaceAll(western[i], eastern[i]);
    }
    return number;
  }

  String convertToEng(String number) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < eastern.length; i++) {
      number = number.replaceAll(eastern[i], western[i]);
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        trailing: widget.contact.iconUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: widget.contact.iconUrl,
                width: 50,
                height: 50,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            : const Icon(Icons.error),
        title: nameEn == null || nameAr == null
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$nameEn: ${convertToEng(widget.contact.number)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$nameAr: ${convertToEasternArabic(widget.contact.number)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
