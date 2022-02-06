import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rishtpak/api/dislikes_api.dart';
import 'package:rishtpak/api/likes_api.dart';
import 'package:rishtpak/api/matches_api.dart';
import 'package:rishtpak/api/users_api.dart';
import 'package:rishtpak/api/visits_api.dart';
import 'package:rishtpak/constants/constants.dart';
import 'package:rishtpak/datas/user.dart';
import 'package:rishtpak/dialogs/its_match_dialog.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/plugins/swipe_stack/swipe_stack.dart';
import 'package:rishtpak/screens/chat_screen.dart';
import 'package:rishtpak/screens/disliked_profile_screen.dart';
import 'package:rishtpak/screens/profile_screen.dart';
import 'package:rishtpak/widgets/cicle_button.dart';
import 'package:rishtpak/widgets/no_data.dart';
import 'package:rishtpak/widgets/processing.dart';
import 'package:rishtpak/widgets/profile_card.dart';

// ignore: must_be_immutable
class DiscoverTab extends StatefulWidget {
  @override
  _DiscoverTabState createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  // Variables
  final GlobalKey<SwipeStackState> _swipeKey = GlobalKey<SwipeStackState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LikesApi _likesApi = LikesApi();
  final DislikesApi _dislikesApi = DislikesApi();
  final MatchesApi _matchesApi = MatchesApi();
  final VisitsApi _visitsApi = VisitsApi();
  final UsersApi _usersApi = UsersApi();
  late AppLocalizations _i18n;

  List<DocumentSnapshot>? _users = [];
  List<DocumentSnapshot>? _likedProfiles =  [];
  List<DocumentSnapshot>? _dislikedUsers = [];
  int indexLiked = 0;
  int indexDisliked = 0;


  late BannerAd _bannerAd;
  bool isBannerVisible = false;


  ///New
  late User selectUser;
  /// New


  /// Get all Users
  Future<void> _loadUsers() async {
    _usersApi.getUsers().then((users) {
      // Check result
      if (users.isNotEmpty) {
        if (mounted) {
          setState(() => _users = users);
        }
      }
      else {
        if (mounted) {
          setState(() => _users = []);
        }
      }

      // Debug
      print('getUsers() -> ${users.length}');
      // print('getDislikedUsers() -> ${_dislikedUsers.length}');
    });
  }

  @override
  void initState() {
    super.initState();

    /// First: Load All Disliked Users to be filtered
    _dislikesApi
        .getDislikedUsers(withLimit: false)
        .then((List<DocumentSnapshot> dislikedUsers) async {

      //NEW Changes (NOW Passport)

      /// Validate user max distance
      // await UserModel().checkUserMaxDistance();

      _dislikedUsers = dislikedUsers;

      _likesApi.getLikedProfiles().then((List<DocumentSnapshot> likedUsers) async{

        _likedProfiles = likedUsers;

        /// Load all users
        await _loadUsers();

      });

      //NEW Changes  (NOW Passport)


    });



    //Google Ads
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8658570767670237/6384316070',  // BannerAd.testAdUnitId,    ca-app-pub-8658570767670237/3997346952
      size: AdSize.banner,
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
    //Google Ads




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
    return Scaffold(key: _scaffoldKey, body: _showUsers(context));
  }

  Widget _showUsers(BuildContext context) {
    /// Check result
    if (_users == null) {
      return Processing(text: _i18n.translate("loading"));
    }
    else if (_users!.isEmpty) {
      /// No user found


      return NoData(
          svgName: 'search_icon',
          text: _i18n.translate("no_user_found_around_you_please_try_again_later"));
    }
    else {

      //Show toast left and right swipe
      if(isFirstTime){
        _scaffoldKey.currentState!.showSnackBar(
            SnackBar(content: Text(_i18n.translate("swipe_left_right_toast_message"),style: TextStyle(color: Colors.white),) ,
              backgroundColor: Theme.of(context).primaryColor,)
        );
        isFirstTime = false;
      }



      //NEW
      selectUser =  User.fromDocument(_users![_users!.length - 1].data()!);
      print('check it user: ${selectUser.userId}');
      //New




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
          /// Banner Ad

          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                /// User card list
                SwipeStack(
                    key: _swipeKey,
                    children: _users!.map((userDoc) {

                      // Get User object
                      print('1-chec my user: ${userDoc.data()!}');
                      final User user = User.fromDocument(userDoc.data()!);



                      // Map<String,dynamic> tempUser = userDoc.data()!;
                      // bool isLikedOrDislikedUser = false;


                      //Check if user liked or not
                      bool isLiked = false;
                      if(_likedProfiles!.length > 0)
                        isLiked = checkUserLiked(userDoc.data()!);



                      // if(indexLiked < _likedProfiles!.length){
                      //
                      //   Map<String,dynamic>  likedUser = _likedProfiles![indexLiked].data()!;
                      //   if(tempUser[USER_ID] == likedUser[LIKED_USER_ID]){
                      //     isLikedOrDislikedUser = true;
                      //   }
                      //   indexLiked++;
                      // }





                      //Check if user liked or not
                      bool isDisLiked = false;
                      if(_dislikedUsers!.length > 0)
                        isDisLiked = checkUserDisLiked(userDoc.data()!);


                      // if(isDisLiked)
                      //   isLiked = false;



                      // if(indexDisliked < _dislikedUsers!.length){
                      //
                      //   Map<String,dynamic>  disLikedUser = _dislikedUsers![indexDisliked].data()!;
                      //   if(tempUser[USER_ID] == disLikedUser[DISLIKED_USER_ID]){
                      //     isLikedOrDislikedUser = true;
                      //   }
                      //   indexDisliked++;
                      // }



                      // Return user profile
                      return SwiperItem(builder: (SwiperPosition position, double progress) {
                        /// Return User Card
                        return ProfileCard(page: 'discover', position: position, user: user , isLiked: isLiked, isDisLiked: isDisLiked, showLiking: true,);
                      });
                    }).toList(),
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    translationInterval: 6,
                    scaleInterval: 0.03,
                    stackFrom: StackFrom.None,
                    onEnd: () async {

                      await Future.delayed(Duration(seconds: 1));

                      /// First: Load All Disliked Users to be filtered
                      _dislikesApi
                          .getDislikedUsers(withLimit: false)
                          .then((List<DocumentSnapshot> dislikedUsers) async {

                        //NEW Changes (NOW Passport)

                        /// Validate user max distance
                        // await UserModel().checkUserMaxDistance();

                        _dislikedUsers = dislikedUsers;

                        _likesApi.getLikedProfiles().then((List<DocumentSnapshot> likedUsers) async{

                          _likedProfiles = likedUsers;

                          /// Load all users
                          await _loadUsers();
                          setState(() {});

                        });

                        //NEW Changes  (NOW Passport)
                      });

                    },
                    onSwipe: (int index, SwiperPosition position) {


                      /// Control swipe position
                      switch (position) {
                        case SwiperPosition.None:
                          break;




                        case SwiperPosition.Left:

                        /// Swipe Left Dislike profile
                          _dislikesApi.dislikeUser(
                              dislikedUserId: _users![index][USER_ID],
                              onDislikeResult: (r){
                                //Here check if user like before or not => remove it
                                FirebaseFirestore.instance
                                    .collection(C_LIKES)
                                    .where(LIKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
                                    .where(LIKED_USER_ID, isEqualTo: _users![index][USER_ID])
                                    .get()
                                    .then((snap){

                                  if(snap.docs.isNotEmpty){
                                    LikesApi().deleteLike(_users![index][USER_ID]).then((value){

                                      print('liked user is remove it');

                                      //Check if user is matched (connected) => remove
                                      MatchesApi().removeMatchingUser(userId: _users![index][USER_ID]).then((value) => print('matched user is deleted'));

                                    });
                                  }
                                  else {
                                    print('liked user is not exists');
                                  }

                                });
                              });

                          //NEW
                          int selectIndex = index - 1;
                          if(selectIndex < 0){
                            selectUser =  User.fromDocument(_users![_users!.length - 1].data()!);
                            selectIndex = _users!.length;
                            print('check index: ${selectIndex}');
                          }
                          else {
                            selectUser =  User.fromDocument(_users![selectIndex].data()!);
                            print('check index: ${selectIndex}');
                          }
                          //New

                          break;




                        case SwiperPosition.Right:

                        /// Swipe right and Like profile
                          _likeUser(context, clickedUserDoc: _users![index]);

                          //NEW
                          int selectIndex = index - 1;
                          if(selectIndex < 0){
                            selectUser =  User.fromDocument(_users![_users!.length - 1].data()!);
                            selectIndex = _users!.length;
                            print('check index: ${selectIndex}');
                          }
                          else {
                            selectUser =  User.fromDocument(_users![selectIndex].data()!);
                            print('check index: ${selectIndex}');
                          }
                          //New


                          break;
                      }
                    }),

                /// Swipe buttons
                Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: swipeButtons(context),
                    )),
              ],
            ),
          ),
        ],
      );
    }
  }

  /// Build swipe buttons
  Widget swipeButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// Rewind profiles
        ///
        /// Go to Disliked Profiles
        cicleButton(
            bgColor: Colors.white,
            padding: 8,
            icon: Icon(Icons.message, size: 22, color: Colors.grey),
            onTap: () {


              //Add typing user to both users and navigate to chat screen
              _addUserToTypingList(context , selectUser);


              // Go to Disliked Profiles Screen
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => ChatScreen(user: selectUser,)));


            }),

        SizedBox(width: 20),

        /// Swipe left and reject user
        cicleButton(
            bgColor: Colors.white,
            padding: 8,
            icon: Icon(Icons.close, size: 35, color: Colors.grey),
            onTap: () {
              /// Get card current index
              final cardIndex = _swipeKey.currentState!.currentIndex;

              /// Check card valid index
              if (cardIndex != -1) {
                /// Swipe left
                _swipeKey.currentState!.swipeLeft();
              }
            }),

        SizedBox(width: 20),

        /// Swipe right and like user
        cicleButton(
            bgColor: Colors.white,
            padding: 8,
            icon: Icon(Icons.favorite, size: 35, color: Theme.of(context).primaryColor),
            onTap: () async {
              /// Get card current index
              final cardIndex = _swipeKey.currentState!.currentIndex;

              /// Check card valid index
              if (cardIndex != -1) {
                /// Swipe right
                _swipeKey.currentState!.swipeRight();
              }
            }),

        SizedBox(width: 20),

        /// Go to user profile
        cicleButton(
            bgColor: Colors.white,
            padding: 8,
            icon: Icon(Icons.remove_red_eye, size: 22, color: Colors.grey),
            onTap: () {
              /// Get card current index
              final cardIndex = _swipeKey.currentState!.currentIndex;

              /// Check card valid index
              if (cardIndex != -1) {
                /// Get User object
                final User user = User.fromDocument(_users![cardIndex].data()!);

                /// Go to profile screen
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: user, showButtons: false)));

                /// Increment user visits an push notification
                _visitsApi.visitUserProfile(
                  visitedUserId: user.userId,
                  userDeviceToken: user.userDeviceToken,
                  nMessage: "${UserModel().user.userFullname.split(' ')[0]}, "
                      "${_i18n.translate("visited_your_profile_click_and_see")}",
                );
              }
            }),
      ],
    );
  }

  /// Like user function
  Future<void> _likeUser(BuildContext context,
      {required DocumentSnapshot clickedUserDoc}) async {
    /// Check match first


    /// like profile
    await _likesApi.likeUser(
        likedUserId: clickedUserDoc[USER_ID],
        userDeviceToken: clickedUserDoc[USER_DEVICE_TOKEN],
        nMessage: "${UserModel().user.userFullname.split(' ')[0]}, "
            "${_i18n.translate("liked_your_profile_click_and_see")}",
        onLikeResult: (result) {
          print('likeResult: $result');

          //Here check if user dislike before => remove it
          FirebaseFirestore.instance
              .collection(C_DISLIKES)
              .where(DISLIKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
              .where(DISLIKED_USER_ID, isEqualTo: clickedUserDoc[USER_ID])
              .get()
              .then((snap){

            if(snap.docs.isNotEmpty){
              DislikesApi().deleteDislikedUser(clickedUserDoc[USER_ID]).then((value) => print('disliked user is remove it'));
            }
            else {
              print('disliked user is not exists');
            }
          });
        });



    /// Save matched user
    await _matchesApi.addMatchingUser(userId: clickedUserDoc[USER_ID]);

    /// It`s match - show dialog to ask user to chat or continue playing
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ItsMatchDialog(
            swipeKey: _swipeKey,
            matchedUser: User.fromDocument(clickedUserDoc.data()!),
          );
        });






    // await _matchesApi.checkMatch(
    //     userId: clickedUserDoc[USER_ID],
    //     onMatchResult: (result) {
    //       if (result) {
    //
    //       }
    //     });


  }


  void _addUserToTypingList(BuildContext context , User user) async {

    FirebaseFirestore.instance
        .collection(C_USERS)
        .doc(UserModel().user.userId)
        .get().then((snapshot) async {

      // print('user id: ${user.userId}');

      Map<String , dynamic> currentUserData = snapshot.data()!;
      Map<String , dynamic> currentUserTypings = snapshot.data()![USER_TYPING];
      print('check currentUserTypings : ${currentUserTypings}');


      DocumentSnapshot otherUser = await FirebaseFirestore.instance.collection(C_USERS).doc(user.userId).get();

      Map<String , dynamic> otherUserData = otherUser.data()!;
      Map<String , dynamic> otherUserTypings = otherUser.data()![USER_TYPING];
      print('check otherUserTypings : ${otherUserTypings}');




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
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChatScreen(user: user)));
      }

      //Else we don't need to do any thing


    });

  }


  /// Check user liked
  bool checkUserLiked(Map<String,dynamic> user) {

    for(int i = 0; i < _likedProfiles!.length ; i++){

      Map<String,dynamic>  likedUser = _likedProfiles![i].data()!;

      if(user[USER_ID] == likedUser[LIKED_USER_ID])
        return true;

    }

    return false;
  }



  /// Check user disliked
  bool checkUserDisLiked(Map<String, dynamic> user) {

    for(int i = 0; i < _dislikedUsers!.length ; i++){

      Map<String,dynamic>  disLikedUser = _dislikedUsers![i].data()!;

      if(user[USER_ID] == disLikedUser[DISLIKED_USER_ID])
        return true;

    }

    return false;

  }

}


