import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rishtpak/api/notifications_api.dart';
import 'package:rishtpak/constants/constants.dart';
import 'package:rishtpak/dialogs/common_dialogs.dart';
import 'package:rishtpak/dialogs/progress_dialog.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/helpers/app_notifications.dart';
import 'package:rishtpak/widgets/badge.dart';
import 'package:rishtpak/widgets/no_data.dart';
import 'package:rishtpak/widgets/processing.dart';
import 'package:rishtpak/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatelessWidget {
  // Variables
  final _notificationsApi = NotificationsApi();
  final _appNotifications = AppNotifications();

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    final pr = ProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate("notifications")),
        actions: [
          IconButton(
              icon: SvgIcon("assets/icons/trash_icon.svg"),
              onPressed: () async {
                /// Delete all Notifications
                ///
                /// Show confirm dialog
                confirmDialog(context,
                    message:
                        i18n.translate("all_notifications_will_be_deleted"),
                    negativeAction: () => Navigator.of(context).pop(),
                    positiveText: i18n.translate("DELETE"),
                    positiveAction: () async {
                      // Show processing dialog
                      pr.show(i18n.translate("processing"));

                      /// Delete
                      await _notificationsApi.deleteUserNotifications();

                      // Hide progress dialog
                      pr.hide();
                      // Hide confirm dialog
                      Navigator.of(context).pop();
                    });
              })
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _notificationsApi.getNotifications(),
          builder: (context, snapshot) {
            /// Check data
            if (!snapshot.hasData) {
              return Processing(text: i18n.translate("loading"));
            } else if (snapshot.data!.docs.isEmpty) {
              /// No notification
              return NoData(
                  svgName: 'bell_icon',
                  text: i18n.translate("no_notification"));
            } else {
              return ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) => Divider(height: 10),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: ((context, index) {
                  /// Get notification DocumentSnapshot
                  final DocumentSnapshot notification =
                      snapshot.data!.docs[index];
                  final String? nType = notification[N_TYPE];
                  // Handle notification icon
                  late ImageProvider bgImage;
                  if (nType == 'alert') {
                    bgImage = AssetImage('assets/images/app_logo.jpg');
                  } else {
                    bgImage = NetworkImage(notification[N_SENDER_PHOTO_LINK]);
                  }

                  /// Show notification
                  return Container(
                    color: !notification[N_READ]
                        ? Theme.of(context).primaryColor.withAlpha(40)
                        : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage: bgImage
                      ),
                      title: Text(
                          notification[N_TYPE] == 'alert'
                              ? notification[N_SENDER_FULLNAME]
                              : notification[N_SENDER_FULLNAME].split(" ")[0],
                          style: TextStyle(fontSize: 18)),
                      subtitle: Text("${notification[N_MESSAGE]}\n"
                          "${timeago.format(notification[TIMESTAMP].toDate())}"),
                      trailing: !notification[N_READ]
                          ? Badge(text: i18n.translate("new"))
                          : null,
                      onTap: () async {
                        /// Set notification read = true
                        await notification.reference.update({N_READ: true});

                        /// Handle notification click
                        _appNotifications.onNotificationClick(context,
                            nType: notification.data()?[N_TYPE] ?? '',
                            nSenderId: notification.data()?[N_SENDER_ID] ?? '',
                            nMessage: notification.data()?[N_MESSAGE] ?? '');
                      },
                    ),
                  );
                }),
              );
            }
          }),
    );
  }
}
