import 'package:flutter/material.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/screens/edit_profile_screen.dart';
import 'package:rishtpak/screens/profile_screen.dart';
import 'package:rishtpak/screens/settings_screen.dart';
import 'package:rishtpak/widgets/cicle_button.dart';
import 'package:rishtpak/widgets/default_card_border.dart';
import 'package:rishtpak/widgets/svg_icon.dart';

class ProfileBasicInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    //
    // Get User Birthday
    final DateTime userBirthday = DateTime(
        UserModel().user.userBirthYear,
        UserModel().user.userBirthMonth, 
        UserModel().user.userBirthDay);
    // Get User Current Age
    final int userAge = UserModel().calculateUserAge(userBirthday);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: ScrollPhysics(),
      child: Card(
        color: Theme.of(context).primaryColor,
        elevation: 4.0,
        shape: defaultCardBorder(),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width - 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Profile image
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 40,
                      backgroundImage:
                          NetworkImage(UserModel().user.userProfilePhoto),
                    ),
                  ),

                  SizedBox(width: 10),

                  /// Profile details
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Flexible(
                          child: Text(
                            "${UserModel().user.userFullname.split(' ')[0]}, "
                                "${userAge.toString()}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 5),


                        /// Location
                        Row(
                          children: [
                            SvgIcon("assets/icons/location_point_icon.svg",
                                color: Colors.white),
                            SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // City
                                Flexible(
                                  child: Text("${UserModel().user.userLocality},",
                                      style: TextStyle(color: Colors.white)),
                                ),
                                // Country
                                Flexible(
                                  child: Text("${UserModel().user.userCountry}",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              /// Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 30,
                    child: OutlinedButton.icon(
                        icon: Icon(Icons.remove_red_eye, color: Colors.white),
                        label: Text(i18n.translate("view"), 
                          style: TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                          BorderSide(color: Colors.white)
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          )
                        )
                      ),
                        onPressed: () {
                          /// Go to profile screen
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                  user: UserModel().user, showButtons: false)));
                        }),
                  ),
                  cicleButton(
                    bgColor: Theme.of(context).accentColor,
                    padding: 13,
                    icon: SvgIcon("assets/icons/settings_icon.svg",
                        color: Colors.white, width: 30, height: 30),
                    onTap: () {
                      /// Go to profile settings
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SettingsScreen()));
                    },
                  ),
                  SizedBox(
                    height: 35,
                    child: TextButton.icon(
                        icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                         style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.white),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            )
                          )
                        ),
                        label: Text(i18n.translate("edit"),
                        style: TextStyle(color: Theme.of(context).primaryColor)),
                        onPressed: () {
                          /// Go to edit profile screen
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => EditProfileScreen()));
                        }),
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
