import 'package:rishtpak/datas/user.dart';
import 'package:rishtpak/dialogs/common_dialogs.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/screens/profile_likes_screen.dart';
import 'package:rishtpak/screens/profile_screen.dart';
import 'package:rishtpak/screens/profile_visits_screen.dart';
import 'package:flutter/material.dart';

class AppNotifications {
  /// Handle notification click for push
  /// and database notifications
  Future<void> onNotificationClick(
    BuildContext context, {
    required String nType,
    required String nSenderId,
    required String nMessage,
    // Call Info object
    String? nCallInfo,
  }) async {
    /// Control notification type
    switch (nType) {
      case 'like':

        /// Check user VIP account
        if (UserModel().userIsVip) {
          /// Go direct to user profile
          _goToProfileScreen(context, nSenderId);
        } else {
          /// Go Profile Likes Screen
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ProfileLikesScreen()));
        }
        break;
      case 'visit':

        /// Check user VIP account
        if (UserModel().userIsVip) {
          /// Go direct to user profile
          _goToProfileScreen(context, nSenderId);
        } else {
          /// Go Profile Visits Screen
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ProfileVisitsScreen()));
        }
        break;

      case 'alert':

        /// Show dialog info
        Future(() {
          infoDialog(context, message: nMessage);
        });

        break;

    }
  }

  /// Navigate to profile screen
  void _goToProfileScreen(BuildContext context, userSenderId) async {
    /// Get updated user info
    final User user = await UserModel().getUserObject(userSenderId);

    /// Go direct to profile
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ProfileScreen(user: user)));
  }
}
