import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rishtpak/constants/constants.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/models/app_model.dart';
import 'package:http/http.dart' as http;

class NotificationsApi {
  /// FINAL VARIABLES
  ///
  /// Firestore instance
  final _firestore = FirebaseFirestore.instance;

  /// Save notification in database
  Future<void> saveNotification({
    required String nReceiverId,
    required String nType,
    required String nMessage,
  }) async {
    _firestore.collection(C_NOTIFICATIONS).add({
      N_SENDER_ID: UserModel().user.userId,
      N_SENDER_FULLNAME: UserModel().user.userFullname,
      N_SENDER_PHOTO_LINK: UserModel().user.userProfilePhoto,
      N_RECEIVER_ID: nReceiverId,
      N_TYPE: nType,
      N_MESSAGE: nMessage,
      N_READ: false,
      TIMESTAMP: FieldValue.serverTimestamp()
    }).then((_) {
      print('saveNotification() -> success');
    });
  }

  /// Notify Current User after purchasing VIP subscription
  Future<void> onPurchaseNotification({
    required String nMessage,
  }) async {
    _firestore.collection(C_NOTIFICATIONS).add({
      N_SENDER_FULLNAME: APP_NAME,
      N_RECEIVER_ID: UserModel().user.userId,
      N_TYPE: 'alert',
      N_MESSAGE: nMessage,
      N_READ: false,
      TIMESTAMP: FieldValue.serverTimestamp()
    }).then((_) {
      print('saveNotification() -> success');
    });
  }

  /// Get stream notifications for current user
  Stream<QuerySnapshot> getNotifications() {
    /// Build query
    return _firestore
        .collection(C_NOTIFICATIONS)
        .where(N_RECEIVER_ID, isEqualTo: UserModel().user.userId)

        /// here
        .orderBy(TIMESTAMP, descending: true)
        .snapshots();
  }

  /// Delete current user notifications
  Future<void> deleteUserNotifications() async {
    await _firestore
        .collection(C_NOTIFICATIONS)
        .where(N_RECEIVER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot snapshot) async {
      // Check result
      if (snapshot.docs.isEmpty) return;

      /// Loop notifications and delete one by one
      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('deleteUserNotifications() -> deleted');
    });
  }

  Future<void> deleteUserSentNotifications() async {
    _firestore
        .collection(C_NOTIFICATIONS)
        .where(N_SENDER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot snapshot) async {
      // Check result
      if (snapshot.docs.isEmpty) return;

      /// Loop notifications
      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('deleteUserSentNotifications() -> deleted');
    });
  }

  /// Send push notification method
  Future<void> sendPushNotification({
    required String nTitle,
    required String nBody,
    required String nType,
    required String nSenderId,
    required String nUserDeviceToken,
    // Call Info Map Data
    Map<String, dynamic>? nCallInfo,
  }) async {
    // Variables
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${AppModel().appInfo.firebaseServerKey}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': nTitle,
            'body': nBody,
            'color': '#987dfa',
            'sound': "default"
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            N_TYPE: nType,
            N_SENDER_ID: nSenderId,
            'call_info': nCallInfo, // Call Info Data
            'status': 'done'
          },
          'to': nUserDeviceToken,
        },
      ),
    ).then((http.Response response) {
      if (response.statusCode == 200) {
        print('sendPushNotification() -> success');
      }
    }).catchError((error) {
      print('sendPushNotification() -> error: $error');
    });
  }
}
