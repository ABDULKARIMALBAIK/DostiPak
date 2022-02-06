import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:rishtpak/constants/constants.dart';
import 'package:rishtpak/datas/user.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/plugins/swipe_stack/swipe_stack.dart';
import 'package:rishtpak/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class ItsMatchDialog extends StatefulWidget {
  // Variables
  final GlobalKey<SwipeStackState>? swipeKey;
  final User matchedUser;
  final bool showSwipeButton;

  ItsMatchDialog({required this.matchedUser, this.swipeKey, this.showSwipeButton = true});


  @override
  State<StatefulWidget> createState() => _ItsMatchDialogState();

}


class _ItsMatchDialogState extends State<ItsMatchDialog> {


  late NavigatorState _navigator;

  @override
  // TODO: implement widget
  ItsMatchDialog get widget => super.widget;

  @override
  void didChangeDependencies() {
    _navigator = Navigator.of(context);
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Material(
      color: Colors.black.withOpacity(.55),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              /// Matched User image
              CircleAvatar(
                radius: 75,
                backgroundColor: Theme.of(context).primaryColor,
                backgroundImage: NetworkImage(widget.matchedUser.userProfilePhoto),
              ),
              SizedBox(height: 10),

              /// Matched User first name
              // Text(widget.matchedUser.userFullname.split(" ")[0],
              //     style: TextStyle(
              //         fontSize: 22,
              //         color: Colors.white,
              //         fontWeight: FontWeight.bold)),
              // SizedBox(height: 10),

              Text(i18n.translate("you_can_now_make_connection_with"),
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              Text(widget.matchedUser.userFullname.split(" ")[0],
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.normal)),
              SizedBox(height: 10),



              /// Send a message button
              SizedBox(
                  height: 47,
                  width: double.maxFinite,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              )
                          )
                      ),
                      child: Text(i18n.translate("send_a_message"),
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                      onPressed: () async{
                        /// Close it's match dialog  first
                        Navigator.of(context).pop();

                        //Save Typing in user field
                        _addUserToTypingList(context , widget.matchedUser);


                      })),
              SizedBox(height: 20),



              /// Keep swiping button
              if (widget.showSwipeButton)
                SizedBox(
                    height: 45,
                    width: double.maxFinite,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                            textStyle: MaterialStateProperty.all<TextStyle>(
                                TextStyle(color: Colors.white)
                            ),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    side: BorderSide(
                                        color: Theme.of(context).primaryColor, width: 2)
                                )
                            )
                        ),
                        child: Text(i18n.translate("keep_passing"),
                            style: TextStyle(fontSize: 18)),
                        onPressed: () {
                          /// Close it's match dialog
                          Navigator.of(context).pop();

                          /// Swipe right
                          // widget.swipeKey!.currentState!.swipeRight();
                        })),


            ],
          ),
        ),
      ),
    );
  }


  void _addUserToTypingList(BuildContext context , User user) async{


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
        _navigator.push(MaterialPageRoute(
            builder: (context) =>
                ChatScreen(user: widget.matchedUser)));

      }
      else {
        /// Go to chat screen
        print('pass 2');
        _navigator.push(MaterialPageRoute(
            builder: (context) => ChatScreen(user: widget.matchedUser)));
      }

      //Else we don't need to do any thing


    });

  }

}
