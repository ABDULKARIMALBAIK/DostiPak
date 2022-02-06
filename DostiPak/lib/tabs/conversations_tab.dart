import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rishtpak/api/conversations_api.dart';
import 'package:rishtpak/constants/constants.dart';
import 'package:rishtpak/datas/user.dart';
import 'package:rishtpak/dialogs/progress_dialog.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/screens/chat_screen.dart';
import 'package:rishtpak/widgets/badge.dart';
import 'package:rishtpak/widgets/build_title.dart';
import 'package:rishtpak/widgets/no_data.dart';
import 'package:rishtpak/widgets/processing.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationsTab extends StatelessWidget {
  // Variables
  final _conversationsApi = ConversationsApi();

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    final pr = ProgressDialog(context);

    return Column(
      children: [
        /// Header
        BuildTitle(
          svgIconName: 'message_icon',
          title: i18n.translate("conversations"),
        ),

        /// Conversations stream
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _conversationsApi.getConversations(),
            builder: (context, snapshot) {
              /// Check data
              if (!snapshot.hasData) {
                return Processing(text: i18n.translate("loading"));
              }
              else if (snapshot.data!.docs.isEmpty) {
                /// No conversation
                return NoData(
                    svgName: 'message_icon',
                    text: i18n.translate("no_conversation"));
              }
              else {
                return ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => Divider(height: 10),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: ((context, index) {
                    /// Get conversation DocumentSnapshot
                    final DocumentSnapshot conversation =
                          snapshot.data!.docs[index];

                    /// Show conversation
                    return ConversationItem(conversation);
                  }),
                );
              }
            }),
        ),
      ],
    );
  }



}



class ConversationItem extends StatefulWidget {

  DocumentSnapshot conversation;
  ConversationItem(this.conversation);

  @override
  State<StatefulWidget> createState() => _ConversationItemState();

}

class _ConversationItemState extends State<ConversationItem> {

  bool isOnline = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    // online/offline
    FirebaseFirestore.instance
        .collection(C_USERS)
        .doc(widget.conversation[USER_ID])
        .snapshots().listen((snapshot) {


      Map<String,dynamic> data =  snapshot.data()!;
      isOnline =  data[USER_ONLINE];
      print('change user online is ${isOnline}');
      print("user id is ${widget.conversation[USER_ID]}");
      setState(() {});

    });
  }

  @override
  Widget build(BuildContext context) {

    /// Initialization
    final i18n = AppLocalizations.of(context);
    final pr = ProgressDialog(context);

    return Container(
      color: !widget.conversation[MESSAGE_READ]
          ? Theme.of(context).primaryColor.withAlpha(40)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          backgroundImage:
          NetworkImage(widget.conversation[USER_PROFILE_PHOTO]),
        ),
        title: Text(widget.conversation[USER_FULLNAME].split(" ")[0], style: TextStyle(fontSize: 18)),

        //Text
        subtitle: widget.conversation[MESSAGE_TYPE] == 'text'
            ? Text(
            "${widget.conversation[LAST_MESSAGE]}\n"
                "${timeago.format(widget.conversation[TIMESTAMP].toDate())}")



        //Gif
            : widget.conversation[MESSAGE_TYPE] == 'gif' ?
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.extension,
                color: Theme.of(context).primaryColor),
            SizedBox(width: 5),
            Text(i18n.translate("gif")),
          ],
        )



        //Sticker
            : widget.conversation[MESSAGE_TYPE] == 'sticker' ?
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.style, color: Theme.of(context).primaryColor),
            SizedBox(width: 5),
            Text(i18n.translate("sticker")),
          ],
        )



        //Audio
            :
        widget.conversation[MESSAGE_TYPE] == 'audio' ?
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.mic_none_rounded,
                color: Theme.of(context).primaryColor),
            SizedBox(width: 5),
            Text(i18n.translate("audio")),
          ],
        )



        //Image
            :
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.photo_camera,
                color: Theme.of(context).primaryColor),
            SizedBox(width: 5),
            Text(i18n.translate("photo")),
          ],
        ),



        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            //Show online/offline mode
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(500) , color: isOnline ? Colors.green : Colors.grey,),
            ),
            SizedBox(width: 6,),


            //Show badge
            !widget.conversation[MESSAGE_READ]
                ? Badge(text: i18n.translate("new"))
                : Container(width: 0, height: 0,),
          ],
        ),

        onTap: () async {
          /// Show progress dialog
          pr.show(i18n.translate("processing"));

          /// 1.) Set conversation read = true
          await widget.conversation.reference
              .update({MESSAGE_READ: true});

          /// 2.) Get updated user info
          final DocumentSnapshot userDoc = await UserModel()
              .getUser(widget.conversation[USER_ID]);

          /// 3.) Get user object
          final User user = User.fromDocument(userDoc.data()!);

          /// Hide progrees
          pr.hide();


          /// Update Typing list
          _addUserToTypingList(context , user);


          // /// Go to chat screen
          // Navigator.of(context).push(
          //     MaterialPageRoute(
          //     builder: (context) => ChatScreen(user: user)));
        },
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

      //Else we don't need to do any thing


    });

  }

}
