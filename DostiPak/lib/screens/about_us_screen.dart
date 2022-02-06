import 'package:flutter/material.dart';
import 'package:rishtpak/constants/constants.dart';
import 'package:rishtpak/helpers/app_helper.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/models/app_model.dart';
import 'package:rishtpak/widgets/app_logo.dart';

class AboutScreen extends StatelessWidget {
  // Variables
  final AppHelper _appHelper = AppHelper();

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate('about_us')),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 65),
        child: Center(
          child: Column(
            children: <Widget>[
              /// App icon
              AppLogo(),
              SizedBox(height: 10),

              /// App name
              Text(
                APP_NAME,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),


              // slogan
              Text(i18n.translate('app_short_description'),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  )),
              SizedBox(height: 15),


              // App description
              Text(i18n.translate('about_us_description'),
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center),


              // Share app button
              SizedBox(height: 10),
              TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor)
                ),
                icon: Icon(Icons.share, color: Colors.white),
                label: Text(i18n.translate('share_app'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    )),
                onPressed: () async {
                  /// Share app
                  _appHelper.shareApp();
                },
              ),
              SizedBox(height: 10),



              // App version name
              Text(APP_VERSION_NAME,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Divider(height: 30, thickness: 1),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Contact
                  Text(i18n.translate('do_you_have_a_question'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  Text(i18n.translate('send_your_message_to_our_email_address'),
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center),


                  Text(AppModel().appInfo.appEmail,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor)),


                  // About us
                  SizedBox(height: 15),
                  GestureDetector(
                    child: Text(
                      i18n.translate("about_us_link"),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 17,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // Open privacy policy page in browser
                      _appHelper.openAboutUs();
                    },
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
