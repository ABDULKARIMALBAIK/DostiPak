import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatMessage extends StatefulWidget {

  // Variables
  final bool isUserSender;
  final String userPhotoLink;
  final bool isImage;
  final String? imageLink;
  final String? textMessage;
  final String timeAgo;

  //NEW
  Duration audioValue = Duration(seconds: 0);
  Duration maxValue = Duration(seconds: 180);
  bool isPlaying = false;
  AudioPlayer playerAudio = AudioPlayer();


  final String audioLink;
  final bool isAudio;
  final String gifLink;
  final bool isGif;
  final String stickerLink;
  final bool isSticker;
  //NEW


  ChatMessage({
    required this.isUserSender,
    required this.userPhotoLink,
    required this.timeAgo,
    this.isImage = false,
    this.imageLink,
    this.textMessage,
    this.audioLink = '',
    this.isAudio = false,
    this.isGif = false,
    this.gifLink = '',
    this.isSticker = false,
    this.stickerLink = ''
  });


  AudioPlayer get getPlayerAudio => playerAudio;


  @override
  State<StatefulWidget> createState() => _ChatMessageState();
  
}



class _ChatMessageState extends State<ChatMessage> {


  @override
  // TODO: implement widget
  ChatMessage get widget => super.widget;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print('my chat_message : ${widget.isAudio}');
    print('my chat_message string: ${widget.audioLink}');
    widget.playerAudio = AudioPlayer();
    if(widget.isAudio){

      widget.getPlayerAudio.setUrl(widget.audioLink);

      widget.getPlayerAudio.onDurationChanged.first.then((value){
        widget.maxValue = value;
        setState((){});
      });


      widget.getPlayerAudio.onAudioPositionChanged.listen((p) {
        widget.audioValue = p;
        setState((){});
      });


      widget.getPlayerAudio.onPlayerCompletion.listen((event) {

        widget.audioValue = Duration(seconds: 0);
        widget.getPlayerAudio.stop();
        widget.isPlaying = false;

        setState(() {});
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {

    if(widget.isAudio){

      widget.getPlayerAudio.setUrl(widget.audioLink);

      widget.getPlayerAudio.onDurationChanged.first.then((value){
        widget.maxValue = value;
        setState((){});
      });


      widget.getPlayerAudio.onAudioPositionChanged.listen((p) {
        widget.audioValue = p;
        setState((){});
      });


      widget.getPlayerAudio.onPlayerCompletion.listen((event) {

        widget.audioValue = Duration(seconds: 0);
        widget.getPlayerAudio.stop();
        widget.isPlaying = false;

        setState(() {});
      });
    }


    /// User profile photo
    final _userProfilePhoto = CircleAvatar(
      backgroundColor: Theme.of(context).primaryColor,
      backgroundImage: NetworkImage(widget.userPhotoLink),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Row(
        children: <Widget>[
          /// User receiver photo Left
          !widget.isUserSender ? _userProfilePhoto : Container(width: 0, height: 0),

          SizedBox(width: 10),

          /// User message
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: widget.isUserSender
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                /// Message container
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color:
                          !widget.isSticker
                              ? !widget.isUserSender
                                   /// Color for receiver
                                   ? Colors.grey.withAlpha(70)
                                   /// Color for sender
                                   : Theme.of(context).primaryColor

                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(25)),
                  child:

                  // Message is image
                  widget.isImage
                      ? GestureDetector(
                          onTap: () {
                            // Show full image
                            Navigator.of(context).push(
                              new MaterialPageRoute(
                                builder: (context) => _ShowFullImage(widget.imageLink!))
                            );
                          },
                          child: Card(
                            /// Image
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            margin: const EdgeInsets.all(0),
                            color: Colors.grey.withAlpha(70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                                width: 200,
                                height: 200,
                                child: Hero(
                                  tag: widget.imageLink!,
                                  child: Image.network(widget.imageLink!,width: 200, height: 200, fit: BoxFit.cover,))),
                          ),
                        )


                  // Message is Gif
                  : widget.isGif
                      ? GestureDetector(
                    onTap: () {
                      // No thing here
                    },
                    child: Card(
                      /// Image
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      margin: const EdgeInsets.all(0),
                      color: Colors.grey.withAlpha(70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                          width: 200,
                          height: 200,
                          child: Image.network(widget.gifLink,width: 200, height: 200, fit: BoxFit.cover,)),
                    ),
                  )




                  // Message is Sticker
                      : widget.isSticker
                      ? GestureDetector(
                    onTap: () {
                      // No thing here
                    },
                    child: Card(
                      /// Image
                      semanticContainer: true,
                      elevation: 0,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      margin: const EdgeInsets.all(0),
                      // color: Colors.grey.withAlpha(70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                          width: 200,
                          height: 200,
                          child: Image.network(widget.stickerLink,width: 200, height: 200, fit: BoxFit.contain,)
                    ),
                  ))

                  //   child: SvgPicture.network(
                  //                             widget.stickerLink,
                  //                             fit: BoxFit.contain,
                  //                             width: 200,
                  //                             height: 200,
                  //                             placeholderBuilder: (ctx) => Container(width: 200, height: 200, color: Colors.grey.withOpacity(0.7),),
                  //                           )





                      // Message is Audio
                      : widget.isAudio
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                          onTap: () async{

                            // widget.getPlayerAudio.setUrl(widget.audioLink);

                            widget.getPlayerAudio.resume();
                            widget.isPlaying = true;
                            setState(() {});

                          },
                          onSecondaryTap: (){

                            widget.getPlayerAudio.pause();
                            widget.isPlaying = false;
                            setState(() {});
                          },
                          child: Icon(widget.isPlaying ? Icons.pause : Icons.play_arrow , color: Colors.white, size: 22,)),
                      SizedBox(width: 3,),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Slider.adaptive(
                          activeColor: Colors.white,
                          max: double.parse(widget.maxValue.inSeconds.toString()),
                          min: 0.0,
                          value: double.parse(widget.audioValue.inSeconds.toString()),
                          onChangeEnd: (value){
                            widget.getPlayerAudio.seek(Duration(seconds: value.toInt()));
                          },
                          onChanged: (value){

                          },
                        ),
                      ),
                    ],
                  )


                  /// Text message
                      : Text(
                    widget.textMessage ?? "",
                    style: TextStyle(
                        fontSize: 18,
                        color: widget.isUserSender ? Colors.white : Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 5),

                /// Message time ago
                Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(widget.timeAgo)
                ),
              ],
            ),
          ),
          SizedBox(width: 10),

          /// Current User photo right
          widget.isUserSender ? _userProfilePhoto : Container(width: 0, height: 0),
        ],
      ),
    );
  }


}

// Show chat image on full screen
class _ShowFullImage extends StatelessWidget {
  // Param
  final String imageUrl;

  _ShowFullImage(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
