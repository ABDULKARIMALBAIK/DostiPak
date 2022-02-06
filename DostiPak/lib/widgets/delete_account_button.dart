import 'package:flutter/material.dart';
import 'package:rishtpak/dialogs/common_dialogs.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/screens/delete_account_screen.dart';
import 'package:rishtpak/widgets/default_button.dart';

class DeleteAccountButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Center(
      child: DefaultButton(
        child: Text(i18n.translate("delete_account"),
            style: TextStyle(fontSize: 18)),
        onPressed: () {
          /// Delete account
          ///
          /// Confirm dialog
          infoDialog(context,
              icon: CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.close, color: Colors.white),
              ),
              title: '${i18n.translate("delete_account")} ?',
              message: i18n.translate(
                  'all_your_profile_data_will_be_permanently_deleted'),
              negativeText: i18n.translate("CANCEL"),
              positiveText: i18n.translate("DELETE"),
              negativeAction: () => Navigator.of(context).pop(),
              positiveAction: () async {
                // Close confirm dialog
                Navigator.of(context).pop();

                // Log out first
                UserModel().signOut().then((_) {
                  /// Go to delete account screen
                  Future(() {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => DeleteAccountScreen()));
                  });
                });
              });
        },
      ),
    );
  }
}
