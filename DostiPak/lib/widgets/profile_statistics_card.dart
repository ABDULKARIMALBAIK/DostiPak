import 'package:flutter/material.dart';
import 'package:rishtpak/dialogs/vip_dialog.dart';
import 'package:rishtpak/helpers/app_helper.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/screens/disliked_profile_screen.dart';
import 'package:rishtpak/screens/profile_likes_screen.dart';
import 'package:rishtpak/screens/profile_visits_screen.dart';
import 'package:rishtpak/widgets/default_card_border.dart';
import 'package:rishtpak/widgets/svg_icon.dart';

class ProfileStatisticsCard extends StatelessWidget {
  // Text style
  final _textStyle = TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    
    return Card(
      elevation: 4.0,
      color: Colors.grey[100],
      shape: defaultCardBorder(),
      child: Column(
        children: [


          //Likes
          ListTile(
            leading: SvgIcon("assets/icons/heart_icon.svg",
                width: 22, height: 22, color: Theme.of(context).primaryColor),
            title: Text(i18n.translate("LIKES"), style: _textStyle),
            trailing: _counter(context, UserModel().user.userTotalLikes),
            onTap: () {

              //Check user is verified
              if(UserModel().user.userWallet > 0.0){
                /// Go to profile likes screen
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => ProfileLikesScreen()));
              }
              else {
                /// Show VIP dialog
                showDialog(
                    context: context,
                    builder: (context) => VipDialog());
              }


            },
          ),
          Divider(height: 0),



          //Visits
          ListTile(
            leading: SvgIcon("assets/icons/eye_icon.svg",
                width: 31, height: 31, color: Theme.of(context).primaryColor),
            title: Text(i18n.translate("VISITS"), style: _textStyle),
            trailing: _counter(context, UserModel().user.userTotalVisits),
            onTap: () {

              //Check user is verified
              if(UserModel().user.userWallet > 0.0){
                /// Go to profile visits screen
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => ProfileVisitsScreen()));
              }
              else {
                /// Show VIP dialog
                showDialog(
                    context: context,
                    builder: (context) => VipDialog());
              }

            },
          ),
          Divider(height: 0),



          //Dislikes
          ListTile(
            leading: SvgIcon("assets/icons/close_icon.svg",
                width: 25, height: 25, color: Theme.of(context).primaryColor),
            title: Text(i18n.translate("DISLIKED_PROFILES"), style: _textStyle),
            trailing: _counter(context, UserModel().user.userTotalDisliked),
            onTap: () {

              //Check user is verified
              if(UserModel().user.userWallet > 0.0){
                /// Go to disliked profile screen
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => DislikedProfilesScreen()));
              }
              else {
                /// Show VIP dialog
                showDialog(
                    context: context,
                    builder: (context) => VipDialog());
              }

            },
          ),
          Divider(height: 0),



          //Watch video
          ListTile(
            leading: Image.asset(
                "assets/icons/icon_video.png",
                width: 25,
                height: 25,
                fit: BoxFit.cover),
            title: Text(i18n.translate("watch_video"), style: _textStyle),
            onTap: () async{
              /// Open link
              await AppHelper().openWatchVideo();
            },
          ),
          Divider(height: 0),


          //Earn money
          ListTile(
            leading: Image.asset(
                "assets/icons/icon_money.png",
                width: 25,
                height: 25,
                fit: BoxFit.cover),
            title: Text(i18n.translate("earn_money"), style: _textStyle),
            onTap: () async{
              /// Open link
              await AppHelper().openEarnMoney();
            },
          ),


        ],
      ),
    );
  }

  Widget _counter(BuildContext context, int value) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor, //.withAlpha(85),
          shape: BoxShape.circle),
      padding: const EdgeInsets.all(6.0),
      child: Text(value.toString(), style: TextStyle(color: Colors.white)));
  }
}
