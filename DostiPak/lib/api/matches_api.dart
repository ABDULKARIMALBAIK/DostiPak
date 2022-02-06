import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rishtpak/constants/constants.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:flutter/material.dart';

class MatchesApi {
  /// Get firestore instance
  ///
  final _firestore = FirebaseFirestore.instance;

  /// Save match
  Future<void> _saveMatch({
    required String docUserId,
    required String matchedWithUserId,
  }) async {
    await _firestore
        .collection(C_CONNECTIONS)
        .doc(docUserId)
        .collection(C_MATCHES)
        .doc(matchedWithUserId)
        .set({TIMESTAMP: FieldValue.serverTimestamp()});
  }

  /// Get current user matches
  Future<List<DocumentSnapshot>> getMatches() async {
    final QuerySnapshot query = await _firestore
        .collection(C_CONNECTIONS)
        .doc(UserModel().user.userId)
        .collection(C_MATCHES)
        .orderBy(TIMESTAMP, descending: true)
        .get();
    return query.docs;
  }

  /// Delete match
  Future<void> deleteMatch(String matchedUserId) async {
    // Delete match for current user
    await _firestore
        .collection(C_CONNECTIONS)
        .doc(UserModel().user.userId)
        .collection(C_MATCHES)
        .doc(matchedUserId)
        .delete();
    // Delete the current user id from matched user list
    await _firestore
        .collection(C_CONNECTIONS)
        .doc(matchedUserId)
        .collection(C_MATCHES)
        .doc(UserModel().user.userId)
        .delete();
  }

  /// Check if It's Match - when onother user already liked current one
  Future<void> checkMatch(
      {required String userId, required Function(bool) onMatchResult}) async {
    _firestore
        .collection(C_LIKES)
        .where(LIKED_USER_ID, isEqualTo: UserModel().user.userId)
        .where(LIKED_BY_USER_ID, isEqualTo: userId)
        .get()
        .then((QuerySnapshot snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        /// It's Match - show dialog
        onMatchResult(true);

        /// Save match for current user
        await _saveMatch(
          docUserId: UserModel().user.userId,
          matchedWithUserId: userId,
        );

        /// Save match copy for matched user
        await _saveMatch(
          docUserId: userId,
          matchedWithUserId: UserModel().user.userId,
        );
        debugPrint('checkMatch() -> true');
      } else {
        onMatchResult(false);
        debugPrint('checkMatch() -> false');
      }
    }).catchError((e) {
      print('checkMatch() -> error: $e');
    });
  }
  
  
  Future<void> addMatchingUser({required String userId}) async {

    _firestore
        .collection(C_CONNECTIONS)
        .doc(UserModel().user.userId)
        .collection(C_MATCHES)
        .doc(userId)
        .get()
        .then((snapshot) async{

      if(snapshot.exists) {
        print('user is exists already !');
      }
      else {

        /// Save match for current user
        await _saveMatch(
          docUserId: UserModel().user.userId,
          matchedWithUserId: userId,
        );

        debugPrint('checkMatch() -> true');
      }


    });
  }


  Future<void> removeMatchingUser({required String userId}) async {

    _firestore
        .collection(C_CONNECTIONS)
        .doc(UserModel().user.userId)
        .collection(C_MATCHES)
        .doc(userId)
        .get()
        .then((snapshot) async{

      if(snapshot.exists) {

        await _firestore
            .collection(C_CONNECTIONS)
            .doc(UserModel().user.userId)
            .collection(C_MATCHES)
            .doc(userId)
            .delete()
        .then((value) => print('matched user is deleted'));

      }
      else {
        print('user is not exists !');
      }


    });
  }

}

