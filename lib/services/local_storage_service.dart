import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';

class LocalStorageService {
  static const _contactsKey = 'emergency_contacts';

  // Save contacts with translations (name in English and Arabic)
  Future<void> saveContacts(List<EmergencyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();

    // Save the contact list
    final contactsData = contacts.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_contactsKey, contactsData);

    // Save the translated names (if any)
    for (var contact in contacts) {
      if (contact.nameEn != null && contact.nameAr != null) {
        final translationData = {
          'nameEn': contact.nameEn,
          'nameAr': contact.nameAr,
        };
        await prefs.setString(contact.id, jsonEncode(translationData));
      }
    }
  }

  // Load contacts (with translations)
  Future<List<EmergencyContact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_contactsKey);
    if (data == null) return [];

    final contacts = data.map((json) {
      final map = jsonDecode(json);
      return EmergencyContact.fromJson(map);
    }).toList();

    // Load translations (if any)
    for (var contact in contacts) {
      final translationData = prefs.getString(contact.id);
      if (translationData != null) {
        final map = jsonDecode(translationData);
        contact.nameEn = map['nameEn'];
        contact.nameAr = map['nameAr'];
      }
    }

    return contacts;
  }
}
