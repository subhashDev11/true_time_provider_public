import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

class FirebaseCloudProvider {
  FirebaseApp? _firebaseApp;
  FirebaseFirestore? _firebaseFirestore;

  FirebaseCloudProvider._();

  /// Factory-style singleton initializer
  static final FirebaseCloudProvider _instance = FirebaseCloudProvider._();

  static FirebaseCloudProvider get instance => _instance;

  /// Initialize based on provider mode
  Future<void> init({required FirebaseOptions options}) async {
    _firebaseApp = await Firebase.initializeApp(options: options);
    _firebaseFirestore = FirebaseFirestore.instanceFor(app: _firebaseApp!);
  }

  /// Main function to return secure DateTime
  Future<DateTime?> now() async {
    try {
      if (_firebaseApp == null || _firebaseFirestore == null) {
        throw ("Before using Firebase time, you need to call init().");
      }
      DocumentReference ref = _firebaseFirestore!.collection("_time").doc();
      await ref.set({"timestamp": FieldValue.serverTimestamp()});
      DocumentSnapshot snap = await ref.get(GetOptions(source: Source.server));
      return (snap["timestamp"] as Timestamp?)?.toDate();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  bool get initialized => _firebaseApp != null && _firebaseFirestore != null;
}
