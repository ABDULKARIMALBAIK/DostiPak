import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rishtpak/constants/constants.dart';
import 'package:rishtpak/datas/user.dart';
import 'package:rishtpak/dialogs/flag_user_dialog.dart';
import 'package:rishtpak/helpers/app_helper.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/plugins/swipe_stack/swipe_stack.dart';
import 'package:rishtpak/widgets/badge.dart';
import 'package:rishtpak/widgets/default_card_border.dart';
import 'package:rishtpak/widgets/show_like_or_dislike.dart';
import 'package:rishtpak/widgets/svg_icon.dart';


class ProfileCard extends StatefulWidget {

  /// User object
  final User user;

  /// Screen to be checked
  final String? page;

  /// Swiper position
  final SwiperPosition? position;

  //New (for Discovery screen)
  final bool showLiking;
  final bool isLiked;
  final bool isDisLiked;
  //New


  ProfileCard({Key? key,
    this.page,
    this.position,
    required this.user ,
    required this.showLiking,
    required this.isLiked,
    required this.isDisLiked,
  }) : super(key: key);


  @override
  State<StatefulWidget> createState() => _ProfileCardState();

}


class _ProfileCardState extends State<ProfileCard> {

  // Local variables
  final AppHelper _appHelper = AppHelper();
  bool isOnline = false;


  @override
  // TODO: implement widget
  ProfileCard get widget => super.widget;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    // online/offline
    FirebaseFirestore.instance
        .collection(C_USERS)
        .doc(widget.user.userId)
        .snapshots().listen((snapshot) {


      Map<String,dynamic> data =  snapshot.data()!;
      isOnline =  data[USER_ONLINE];
      print('change user online is ${isOnline}');
      print("user id is ${widget.user.userId}");
      setState(() {});

    });

  }


  @override
  Widget build(BuildContext context) {
    // Variables
    final bool requireVip =
        widget.page == 'require_vip' && !UserModel().userIsVip;
    late ImageProvider userPhoto;
    // Check user vip status
    if (requireVip) {
      userPhoto = AssetImage('assets/images/crow_badge.png');
    } else {
      userPhoto = NetworkImage(widget.user.userProfilePhoto);
    }

    //
    // Get User Birthday
    final DateTime userBirthday = DateTime(
        UserModel().user.userBirthYear,
        UserModel().user.userBirthMonth,
        UserModel().user.userBirthDay);
    // Get User Current Age
    final int userAge = UserModel().calculateUserAge(userBirthday);

    // Build profile card
    return Padding(
      key: UniqueKey(),
      padding: const EdgeInsets.all(9.0),
      child: Stack(
        children: [
          /// User Card
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            margin: EdgeInsets.all(0),
            shape: defaultCardBorder(),
            child: Container(
              decoration: BoxDecoration(
                /// User profile image
                image: DecorationImage(
                  /// Show VIP icon if user is not vip member
                    image: userPhoto,
                    fit: requireVip ? BoxFit.contain : BoxFit.cover),
              ),
              child: Container(
                /// BoxDecoration to make user info visible
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Colors.transparent
                      ]),
                ),

                /// User info container
                child: Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// User fullname
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${widget.user.userFullname}, '
                                  '${userAge.toString()}',
                              style: TextStyle(
                                  fontSize: widget.page == 'discover' ? 20 : 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      /// User education
                      Row(
                        children: [
                          SvgIcon("assets/icons/university_icon.svg",
                              color: Colors.white, width: 20, height: 20),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.user.userSchool,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3),

                      /// User job title
                      Row(
                        children: [
                          SvgIcon("assets/icons/job_bag_icon.svg",
                              color: Colors.white, width: 17, height: 17),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.user.userJobTitle,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      widget.page == 'discover'
                          ? SizedBox(height: 70)
                          : Container(width: 0, height: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),


          /// Show location distance  ///NEW commented
          // Positioned(
          //   top: 10,
          //   left: this.page == 'discover' ? 8 : 5,
          //   child: Badge(
          //       icon: this.page == 'discover'
          //           ? SvgIcon("assets/icons/location_point_icon.svg",
          //               color: Colors.white, width: 15, height: 15)
          //           : null,
          //       text:
          //           '${_appHelper.getDistanceBetweenUsers(userLat: user.userGeoPoint.latitude, userLong: user.userGeoPoint.longitude)}km'),
          // ),



          /// Show Like or Dislike
          widget.page == 'discover'
              ? ShowLikeOrDislike(position: widget.position!)
              : Container(width: 0, height: 0),




          /// Show message icon
          widget.page == 'matches'
              ? Positioned(
            bottom: 5,
            right: 5,
            child: Container(
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: SvgIcon("assets/icons/message_icon.svg",
                    color: Colors.white, width: 30, height: 30)),
          )
              : Container(width: 0, height: 0),





          /// Show online/offline mode
          widget.page == 'matches'
              ? Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0,0),
                    color: isOnline ? Colors.green.withOpacity(0.4) : Colors.grey.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 4
                  )
                ],
                borderRadius: BorderRadius.circular(500) ,
                color: isOnline ? Colors.green : Colors.grey,),
            ),
          )
              : Container(width: 0, height: 0),




          /// Show flag profile icon
          widget.page == 'discover'
              ? Positioned(
              right: 0,
              child: IconButton(
                  icon: Icon(Icons.flag,
                      color: Theme.of(context).primaryColor),
                  onPressed: () {
                    /// Flag user profile
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return FlagUserDialog(flaggedUserId: widget.user.userId);
                        });
                  }))
              : Container(width: 0, height: 0),





          /// NEW NEW check if liked or disliked => add highlight
          if(widget.showLiking)
            widget.isLiked
                ?
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.6),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10) , bottomLeft: Radius.circular(10))
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Liked' , style: TextStyle(color: Colors.white , fontSize: 14),),
                ),
              ),
            )
                :
            widget.isDisLiked
                ?
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.6),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10) , bottomLeft: Radius.circular(10))
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Disliked' , style: TextStyle(color: Colors.white , fontSize: 14),),
                ),
              ),
            )
                :
            Container(width: 0, height: 0,)

        ],
      ),
    );
  }

}
