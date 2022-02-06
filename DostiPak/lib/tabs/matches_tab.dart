import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rishtpak/api/matches_api.dart';
import 'package:rishtpak/constants/constants.dart';
import 'package:rishtpak/datas/user.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/screens/chat_screen.dart';
import 'package:rishtpak/widgets/build_title.dart';
import 'package:rishtpak/widgets/loading_card.dart';
import 'package:rishtpak/widgets/no_data.dart';
import 'package:rishtpak/widgets/processing.dart';
import 'package:rishtpak/widgets/profile_card.dart';
import 'package:rishtpak/widgets/users_grid.dart';

class MatchesTab extends StatefulWidget {
  @override
  _MatchesTabState createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  /// Variables
  final MatchesApi _matchesApi = MatchesApi();
  List<DocumentSnapshot>? _matches;
  late AppLocalizations _i18n;

  late BannerAd _bannerAd;
  bool isBannerVisible = false;



  @override
  void initState() {
    super.initState();

    /// Get user matches
    _matchesApi.getMatches().then((matches) {
      if (mounted) setState(() => _matches = matches);
    });
    
    //Google Banner Ads
    _bannerAd = BannerAd(
      adUnitId: '.................................',  //BannerAd.testAdUnitId
      size: AdSize.banner,  //AdSize(width:  2000, height: 65)
      request: AdRequest(),
      listener: AdListener(
        onAdLoaded: (Ad ad) async{

          print('$BannerAd loaded.');
          await Future.delayed(Duration(milliseconds: 2000));
          isBannerVisible = true;
          setState(() {});
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );

    _bannerAd.load();
    //Google Banner Ads

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    //Banner Ads widget
    final AdWidget adWidget = AdWidget(ad: _bannerAd);

    return Column(
      children: [

        /// Banner Ad
        Visibility(
          visible: isBannerVisible,
          child: Align(
            alignment: FractionalOffset.topCenter,
            child: Padding(
                padding: EdgeInsets.all(12),
                child: Container(
                  alignment: Alignment.center,
                  child: adWidget,
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                )
            ),
          ),
        ),


        /// Header
        BuildTitle(
          svgIconName: 'heart_icon',
          title: _i18n.translate("connections"),
        ),

        /// Show matches
        Expanded(child: _showMatches()),
      ],
    );
  }


  /// Handle matches result
  Widget _showMatches() {
    /// Check result
    if (_matches == null) {
      return Processing(text: _i18n.translate("loading"));
    }
    else if (_matches!.isEmpty) {
      /// No match
      return NoData(
        svgName: 'heart_icon', text: _i18n.translate("no_connections"));
    }
    else {
      /// Load matches
      return UsersGrid(
        itemCount: _matches!.length,
        itemBuilder: (context, index) {
          /// Get match doc
          final DocumentSnapshot match = _matches![index];

          /// Load profile
          return FutureBuilder<DocumentSnapshot>(
              future: UserModel().getUser(match.id),
              builder: (context, snapshot) {
                /// Check result
                if (!snapshot.hasData) return LoadingCard();

                /// Get user object
                final User user = User.fromDocument(snapshot.data!.data()!);

                /// Show user card
                return GestureDetector(
                    child: ProfileCard(user: user, page: 'matches' , showLiking: false, isLiked: false, isDisLiked: false,),
                    onTap: () {

                      //NEW (here add user friend to typing list)
                      _addUserToTypingList(context , user);


                      // /// Go to chat screen
                      // Navigator.of(context).push(
                      //     MaterialPageRoute(
                      //         builder: (context) => ChatScreen(user: user)));
                    });
              });
        },
      );
    }
  }


  void _addUserToTypingList(BuildContext context , User user) async {


    FirebaseFirestore.instance
        .collection(C_USERS)
        .doc(UserModel().user.userId)
        .get().then((snapshot) async {

      Map<String , dynamic> currentUserData = snapshot.data()!;
      Map<String , dynamic> currentUserTypings = snapshot.data()![USER_TYPING];


      DocumentSnapshot otherUser = await FirebaseFirestore.instance.collection(C_USERS).doc(user.userId).get();

      Map<String , dynamic> otherUserData = otherUser.data()!;
      Map<String , dynamic> otherUserTypings = otherUser.data()![USER_TYPING];



      if( !(currentUserTypings.containsKey(user.userId)) || !(otherUserTypings.containsKey(UserModel().user.userId)) ){

        ////////////////////Add new typing data in current user

        currentUserTypings[user.userId] = false;
        // print('size of typing list ${currentUserTypings.length}');

        currentUserData[USER_TYPING] = currentUserTypings;
        // print('size of  data[USER_TYPING] list ');

        FirebaseFirestore.instance.collection(C_USERS).doc(UserModel().user.userId).update(currentUserData).then((value) => print('current user is updated successfully'));



        ////////////////////Add new typing data in other user

        otherUserTypings[UserModel().user.userId] = false;
        // print('size of typing list ${currentUserTypings.length}');

        otherUserData[USER_TYPING] = otherUserTypings;
        // print('size of  data[USER_TYPING] list ');

        FirebaseFirestore.instance.collection(C_USERS).doc(user.userId).update(otherUserData).then((value) => print('other user is updated successfully'));


        /// Go to chat screen
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                ChatScreen(user: user)));

      }
      else {
        /// Go to chat screen
        print('pass 2');
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChatScreen(user: user)));
      }

    });

  }

}
