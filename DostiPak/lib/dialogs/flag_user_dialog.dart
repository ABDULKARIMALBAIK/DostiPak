import 'package:rishtpak/dialogs/common_dialogs.dart';
import 'package:rishtpak/dialogs/progress_dialog.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:flutter/material.dart';

class FlagUserDialog extends StatefulWidget {
  // Variables
  final String flaggedUserId;

  FlagUserDialog({required this.flaggedUserId});

  @override
  _FlagUserDialogState createState() => _FlagUserDialogState();
}

class _FlagUserDialogState extends State<FlagUserDialog> {
  // Variables
  String _selectedFlagOption = "";
  late ProgressDialog _pr;
  late AppLocalizations _i18n;

  @override
  Widget build(BuildContext context) {
    // Initialization
    _i18n = AppLocalizations.of(context);
    _pr = new ProgressDialog(context);

    // Get flag option list
    final List<String> flagOptions = [
      _i18n.translate("sexual_content"),
      _i18n.translate("abusive_content"),
      _i18n.translate("violent_content"),
      _i18n.translate("inappropriate_content"),
      _i18n.translate("spam_or_misleading"),
    ];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: _dialogContent(context, flagOptions),
      elevation: 3,
    );
  }

// Build dialog
  Widget _dialogContent(BuildContext context, List<String> flagOptions) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Icon(Icons.flag_outlined),
              SizedBox(width: 5),
              Text(
                _i18n.translate("flag_user"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.black,
          height: 5,
        ),
        Flexible(
          fit: FlexFit.loose,
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: flagOptions.map((selectedOption) {
                  return RadioListTile(
                      selected:
                          _selectedFlagOption == selectedOption ? true : false,
                      title: Text(selectedOption),
                      activeColor: Theme.of(context).primaryColor,
                      value: selectedOption,
                      groupValue: _selectedFlagOption,
                      onChanged: (value) {
                        setState(() {
                          _selectedFlagOption = value.toString();
                        });
                        print('Selected option: $_selectedFlagOption');
                      });
                }).toList()),
          ),
        ),
        Divider(
          color: Colors.black,
          height: 5,
        ),
        Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    child: Text(_i18n.translate("CLOSE")),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                       _i18n.translate("FLAG"),
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                    onPressed: _selectedFlagOption == ''
                        ? null
                        : () async {
                            // Show processing dialog
                            _pr.show(_i18n.translate("processing"));

                            /// Flag profile
                            await UserModel().flagUserProfile(
                                flaggedUserId: widget.flaggedUserId,
                                reason: _selectedFlagOption);

                            // Close progress
                            _pr.hide();
                            debugPrint('flagUserProfile() -> success');

                            String message = _i18n.translate(
                                "thank_you_the_profile_will_be_reviewed");
                            // Show success dialog
                            successDialog(context, message: message);
                          },
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
