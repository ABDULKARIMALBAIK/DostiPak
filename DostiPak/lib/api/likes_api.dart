import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rishtpak/api/dislikes_api.dart';
import 'package:rishtpak/api/notifications_api.dart';
import 'package:rishtpak/constants/constants.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:flutter/material.dart';

class LikesApi {
  /// FINAL VARIABLES
  ///
  final _firestore = FirebaseFirestore.instance;
  final _notificationsApi = NotificationsApi();

  /// Save liked user
  Future<void> _saveLike({
    required String likedUserId,
    required String userDeviceToken,
    required String nMessage,
  }) async {
    _firestore.collection(C_LIKES).add({
      LIKED_USER_ID: likedUserId,
      LIKED_BY_USER_ID: UserModel().user.userId,
      TIMESTAMP: FieldValue.serverTimestamp()
    }).then((_) async {
      /// Update user total likes
      await UserModel().updateUserData(
          userId: likedUserId,
          data: {USER_TOTAL_LIKES: FieldValue.increment(1)});

      /// Save notification in database
      await _notificationsApi.saveNotification(
        nReceiverId: likedUserId,
        nType: 'like',
        nMessage: nMessage,
      );

      /// Send push notification
      await _notificationsApi.sendPushNotification(
          nTitle: APP_NAME,
          nBody: nMessage,
          nType: 'like',
          nSenderId: UserModel().user.userId,
          nUserDeviceToken: userDeviceToken);
    });
  }

  /// Like user profile
  Future<void> likeUser(
      {required String likedUserId,
      required String userDeviceToken,
      required String nMessage,
      required Function(bool) onLikeResult}) async {
    /// Check if current user already liked profile
    _firestore
        .collection(C_LIKES)
        .where(LIKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
        .where(LIKED_USER_ID, isEqualTo: likedUserId)
        .get()
        .then((QuerySnapshot snapshot) async {
      if (snapshot.docs.isEmpty) {
        onLikeResult(true);

        // Like user
        await _saveLike(
            likedUserId: likedUserId,
            nMessage: nMessage,
            userDeviceToken: userDeviceToken);
        debugPrint('likeUser() -> success');
      } else {
        onLikeResult(false);
        debugPrint('You already liked the user');
      }
    }).catchError((e) {
      print('likeUser() -> error: $e');
    });
  }



  /// Get Liked Profiles
  Future<List<DocumentSnapshot>> getLikedProfiles() async{
    List<DocumentSnapshot> likedProfiles = (await _firestore
        .collection(C_LIKES)
        .where(LIKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
        .get()).docs;

    return likedProfiles;
  }



  /// Get users who liked current user profile
  Future<List<DocumentSnapshot>> getLikedMeUsers(
      {bool loadMore = false, 
      DocumentSnapshot? userLastDoc}) async {
    /// Build Users query
    Query usersQuery = _firestore
        .collection(C_LIKES)
        .where(LIKED_USER_ID, isEqualTo: UserModel().user.userId);

    /// Check load more
    if (loadMore) {
      usersQuery = usersQuery.startAfterDocument(userLastDoc!);
    }

    /// Finalize query and Limit data
    usersQuery = usersQuery.orderBy(TIMESTAMP, descending: true);
    usersQuery = usersQuery.limit(20);

    final QuerySnapshot querySnapshot = await usersQuery.get().catchError((e) {
      print('getLikedMeUsers() -> error: $e');
    });

    return querySnapshot.docs;
  }

  /// Delete liked profile: when current user decides to dislike it
  Future<void> deleteLike(String likedUserId) async {
    _firestore
        .collection(C_LIKES)
        .where(LIKED_USER_ID, isEqualTo: likedUserId)
        .where(LIKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot snapshot) async {
      final ref = snapshot.docs.first;
      await ref.reference.delete().then((value) => print('liked user is remove it'));

    }).catchError((e) {
      print('deleteLike() -> error: $e');
    });
  }

  // Delete liked profile ids by current user
  Future<void> deleteLikedUsers() async {
    _firestore
        .collection(C_LIKES)
        .where(LIKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot snapshot) async {
      /// Check docs
      if (snapshot.docs.isNotEmpty) {
        // Loop docs to be deleted
        snapshot.docs.forEach((doc) async {
          await doc.reference.delete();
        });
        debugPrint('deleteLikedUsers() -> deleted');
      }
    });
  }

  // Delete user id from profiles who liked the current user
  Future<void> deleteLikedMeUsers() async {
    _firestore
        .collection(C_LIKES)
        .where(LIKED_USER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot snapshot) async {
      /// Check docs
      if (snapshot.docs.isNotEmpty) {
        // Loop docs to be deleted
        snapshot.docs.forEach((doc) async {
          await doc.reference.delete();
        });
        debugPrint('deleteLikedMeUsers() -> deleted');
      }
    });
  }
}
