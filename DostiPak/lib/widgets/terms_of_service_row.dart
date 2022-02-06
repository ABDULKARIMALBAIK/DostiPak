import 'package:flutter/material.dart';
import 'package:rishtpak/helpers/app_helper.dart';
import 'package:rishtpak/helpers/app_localizations.dart';

class TermsOfServiceRow extends StatelessWidget {
  // Params
  final Color color;

  TermsOfServiceRow({this.color = Colors.white});

  // Private variables
  final _appHelper = AppHelper();

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          child: Text(
            i18n.translate("terms_of_service"),
            style: TextStyle(
                color: color,
                fontSize: 17,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold),
          ),
          onTap: () {
            // Open terms of service page in browser
            _appHelper.openTermsPage();
          },
        ),
        Text(
          ' | ',
          style: TextStyle(
              color: color, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          child: Text(
            i18n.translate("privacy_policy"),
            style: TextStyle(
                color: color,
                fontSize: 17,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold),
          ),
          onTap: () {
            // Open privacy policy page in browser
            _appHelper.openPrivacyPage();
          },
        ),
      ],
    );
  }
}
