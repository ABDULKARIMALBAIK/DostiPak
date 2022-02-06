import 'package:flutter/material.dart';
import 'package:rishtpak/dialogs/vip_dialog.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/widgets/default_card_border.dart';

class VipAccountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: defaultCardBorder(),
      child: ListTile(
        leading: Image.asset("assets/images/crow_badge_small.png",
            width: 35, height: 35),
        title: Text(i18n.translate("recharge"),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          /// Show VIP dialog
          showDialog(context: context, 
            builder: (context) => VipDialog());
        },
      ),
    );
  }
}
