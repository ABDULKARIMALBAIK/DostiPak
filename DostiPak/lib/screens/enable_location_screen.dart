import 'package:rishtpak/dialogs/common_dialogs.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/screens/sign_up_screen.dart';
import 'package:rishtpak/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class EnableLocationScreen extends StatefulWidget {
  // Variables
  final String action;

  EnableLocationScreen({required this.action});

  @override
  _EnableLocationScreenState createState() => _EnableLocationScreenState();
}

class _EnableLocationScreenState extends State<EnableLocationScreen> {
  // Variables
  late AppLocalizations _i18n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Show turn on GPS or Location dialog
    Future(() {
      /// Show dialog to enable GPS
      infoDialog(context,
          icon: SvgIcon("assets/icons/location_point_icon.svg",
              color: Colors.white),
          title: _i18n.translate(
              widget.action == 'GPS' ? "enable_GPS" : "enable_location"),
          message: _i18n.translate(widget.action == 'GPS'
              ? "we_were_unable_to_get_your_current_location_please_enable_gps_to_continue"
              : "you_need_to_enable_location_permission_to_use_this_app"),
          positiveText: _i18n.translate("ENABLE"), positiveAction: () {
        // Execute action
        widget.action == 'GPS'
            ? Geolocator.openLocationSettings()
            : Geolocator.openAppSettings();
        // Close dialog
        Navigator.of(context).pop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_i18n.translate(
            widget.action == 'GPS' ? "enable_GPS" : "enable_location")),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                child: Icon(Icons.location_on, size: 60, color: Colors.white),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              // TIP
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    _i18n.translate(widget.action == 'GPS'
                        ? "we_were_unable_to_get_your_current_location_please_enable_gps_to_continue"
                        : "you_need_to_enable_location_permission_to_use_this_app"),
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center),
              ),
              SizedBox(height: 5),
              Text(
                  _i18n.translate(widget.action == 'GPS'
                      ? "did_you_enable_GPS"
                      : "did_you_enable_location"),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(_i18n.translate("click_continue"),
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 15),
              SizedBox(
                height: 45,
                width: double.maxFinite,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(25),
                      )
                    )
                  ),
                  child: Text(_i18n.translate("CONTINUE"),
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  onPressed: () {
                    /// Go to SignUp Screen
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                        (route) => false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
