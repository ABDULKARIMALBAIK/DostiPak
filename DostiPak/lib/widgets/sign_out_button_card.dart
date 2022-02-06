import 'package:flutter/material.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/screens/sign_in_screen.dart';
import 'package:rishtpak/widgets/default_card_border.dart';

class SignOutButtonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: defaultCardBorder(),
      child: ListTile(
        leading: Icon(Icons.exit_to_app),
        title: Text(i18n.translate("sign_out"), style: TextStyle(fontSize: 18)),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          // Log out button
          UserModel().signOut().then((_) {
            /// Go to login screen
            Future(() {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SignInScreen()));
            });
          });
        },
      ),
    );
  }
}
