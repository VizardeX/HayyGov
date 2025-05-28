import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // ✅ NEW

class AuthProvider with ChangeNotifier {
  String _token = "";
  String _userId = "";
  bool _authenticated = false;
  DateTime? _expiryDate;

  bool get isAuthenticated => _authenticated;

  String get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token.isNotEmpty) {
      return _token;
    }
    return "";
  }

  String get userId => _userId;

  // ✅ NEW: Save FCM token to Firestore
  Future<void> _saveFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'fcmToken': token,
        },
        SetOptions(merge: true),
      );
    }
  }

  Future<String> signup({required String email, required String password}) async {
    final apiKey = dotenv.env['FIREBASE_API_KEY'];
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey');
    try {
      final response = await http.post(url, body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        return responseData['error']['message'];
      }
      _authenticated = true;
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();
      return "success";
    } catch (err) {
      return err.toString();
    }
  }

  Future<void> signUpCitizen(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('users').doc(uid).set({
        'email': email,
        'role': 'citizen',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _saveFcmToken(); // ✅ ADDED
    } catch (e) {
      // print("Error signing up: $e");
    }
  }

  Future<String> signUpWithRole({required String email, required String password, required String role}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _saveFcmToken(); // ✅ ADDED
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> login(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': email,
          'role': 'citizen',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      await _saveFcmToken(); // ✅ ADDED

      if (!context.mounted) return;

      if (userDoc.exists) {
        String role = userDoc['role'];

        if (role == 'citizen') {
          Navigator.pushReplacementNamed(context, '/citizenHome');
        } else if (role == 'government') {
          Navigator.pushReplacementNamed(context, '/govHome');
        } else if (role == 'advertiser') {
          Navigator.pushReplacementNamed(context, '/advertiserDashboard');
        }
      }
    } catch (e) {
      // print("Login failed: $e");
    }
  }

  void logout() {
    _authenticated = false;
    _token = "";
    _userId = "";
    _expiryDate = null;
    notifyListeners();
  }
}
