import 'dart:developer';

import 'package:epassport/config/config.dart';
import 'package:epassport/firebase_options.dart';
import 'package:epassport/pages/user/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  // private constructor
  FirebaseService._privateConstructor();
  // singleton instance
  static final FirebaseService instance = FirebaseService._privateConstructor();
  // firebase
  late FirebaseApp app;
  late FirebaseFirestore firestore;
  late FirebaseAuth firebaseAuth;
  late FirebaseStorage storage;
  // initialize firebase
  Future<void> initialize() async {
    app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseUIAuth.configureProviders(
      [
        EmailAuthProvider(),
        PhoneAuthProvider(),
        GoogleProvider(clientId: GOOGLE_CLIENT_ID),
      ],
      app: app,
    );
    firestore = FirebaseFirestore.instanceFor(app: app);
    firebaseAuth = FirebaseAuth.instanceFor(app: app);
    storage = FirebaseStorage.instanceFor(app: app);
  }

  // get user uid
  String? get uid => firebaseAuth.currentUser?.uid;

  // get user
  User? get user => firebaseAuth.currentUser;

  // signOut
  Future<void> signOut(BuildContext context) async {
    await FirebaseUIAuth.signOut(context: context, auth: firebaseAuth)
        .then((_) {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  // check if user document exists
  Future<bool> userExists(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  // check if user document exists stream
  Stream<bool> userExistsStream(String uid) {
    return firestore.collection('users').doc(uid).snapshots().map((doc) {
      return doc.exists;
    });
  }

  // create user document
  Future<void> createUserDocument(
      {required String uid, required UserData userData}) async {
    return await firestore.collection('users').doc(uid).set(userData.toJson());
  }

  // get user document
  Future<UserData?> getUserDocument(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();
    log('doc: ${doc.data()}', name: 'createUserDocument()', error: 'uid: $uid');

    return data != null ? UserData.fromJson(data) : null;
  }

  // get user document
  Future<UserData?> getUserDataEmail(String email) async {
    final doc = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (doc.docs.isNotEmpty) {
      return UserData.fromJson(doc.docs.first.data());
    } else {
      return null;
    }
  }

  // update user document
  Future<void> updateUserDocument(
      {required String uid, required UserData userData}) async {
    await firestore.collection('users').doc(uid).update(userData.toJson());
  }

  // delete user document
  Future<void> deleteUserDocument(String uid) async {
    await firestore.collection('users').doc(uid).delete();
  }

  //actionCodeSettings
  final actionCodeSettings = ActionCodeSettings(
    url: FIREBASE_HOST,
    handleCodeInApp: true,
    androidMinimumVersion: '1',
    androidPackageName: PACKAGE_NAME,
    iOSBundleId: PACKAGE_NAME,
  );
}
