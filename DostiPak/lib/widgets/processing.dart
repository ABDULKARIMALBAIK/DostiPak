import 'package:flutter/material.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/widgets/my_circular_progress.dart';

class Processing extends StatelessWidget {
  final String? text;

  const Processing({this.text});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MyCircularProgress(),
          SizedBox(height: 10),
          Text(text ?? i18n.translate("processing"), style: TextStyle(fontSize: 18,
          fontWeight: FontWeight.w500)),
          SizedBox(height: 5),
          Text(i18n.translate("please_wait"), style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
