import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rishtpak/dialogs/progress_dialog.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:rishtpak/widgets/svg_icon.dart';


class StickerSourceSheet extends StatelessWidget {
  // Constructor
  StickerSourceSheet({required this.onStickerSelected});

  // Callback function to return image file
  final Function(String fireStorageURL) onStickerSelected;

  late ProgressDialog _pr;
  late AppLocalizations _i18n;


  List<String> stickerPaths = [
    'assets/stickers/sticker1.png',
    'assets/stickers/sticker2.png',
    'assets/stickers/sticker3.png',
    'assets/stickers/sticker4.png',
    'assets/stickers/sticker5.png',
    'assets/stickers/sticker6.png',
    'assets/stickers/sticker7.png',
    'assets/stickers/sticker8.png',
    'assets/stickers/sticker9.png',
    'assets/stickers/sticker10.png',
    'assets/stickers/sticker11.png',
    'assets/stickers/sticker12.png',
    'assets/stickers/sticker13.png',
    'assets/stickers/sticker14.png',
    'assets/stickers/sticker15.png',
    'assets/stickers/sticker16.png',
    'assets/stickers/sticker18.png',
    'assets/stickers/sticker19.png',
    'assets/stickers/sticker20.png',
    'assets/stickers/sticker21.png',
    'assets/stickers/sticker22.png',
    'assets/stickers/sticker23.png',
    'assets/stickers/sticker24.png',
    'assets/stickers/sticker25.jpeg',
    'assets/stickers/sticker26.jpeg',
    'assets/stickers/sticker27.jpeg',
    'assets/stickers/sticker28.jpeg',
    'assets/stickers/sticker29.jpeg',
    'assets/stickers/sticker30.jpeg',
    'assets/stickers/sticker31.jpeg',
    'assets/stickers/sticker32.jpeg',
    'assets/stickers/sticker33.jpeg',
  ];


  @override
  Widget build(BuildContext context) {

    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context);


    return BottomSheet(
        onClosing: () {},
        builder: ((context) => Container(
          width: MediaQuery.of(context).size.width,
          height:  MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              SizedBox(height: 10,),

              Container(
                padding: const EdgeInsets.all(18),
                width: 200,
                height: 5,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(300) ,color: Colors.grey,),
              ),

              SizedBox(height: 15,),


              Text(_i18n.translate("sticker") , style: TextStyle(color: Theme.of(context).primaryColor , fontSize: 24),),
              SizedBox(height: 15,),


              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_i18n.translate("choose_the_sticker_you_like") , style: TextStyle(color: Colors.grey.withOpacity(0.7) , fontSize: 18),),
              ),
              SizedBox(height: 20,),


              /// Select stickers
              Expanded(
                child: GridView.count(
                  mainAxisSpacing: 3,
                  crossAxisCount: 3,
                  childAspectRatio: 200/200,
                  crossAxisSpacing: 3,
                  children: stickerPaths.map((stickerPath){


                    return  Container(
                      width: 200,
                      height: 200,
                      child: GestureDetector(
                        child: Image.asset(
                          stickerPath,
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        onTap: () async {

                          //Upload to storage
                          Navigator.of(context).pop();
                          uploadToFirebase(stickerPath);

                        },
                      ),
                    );

                  }).toList(),
                ),
              )

            ],
          ),
        )));
  }

  void uploadToFirebase(String path) async {

    final byteData = await rootBundle.load(path);
    print('buffer size : ${byteData.lengthInBytes}');


    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    else {
      String extension = path.split(".")[1];
      print('extension is $extension');

      Directory tempDir = await path_provider.getTemporaryDirectory();
      final file = File('${tempDir.path}/${Random().nextInt(10000)}.$extension');
      await file.writeAsBytes(byteData.buffer.asUint8List(
          byteData.offsetInBytes, byteData.lengthInBytes));


      // Show processing dialog
      _pr.show(_i18n.translate("sending"));

      // Upload to firebase storage
      final Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/messages/sticker${DateTime
          .now()
          .millisecondsSinceEpoch
          .toString()}.$extension');

      UploadTask task = firebaseStorageRef.putFile(file);
      task.then((value) async {

        print('##############done#########');
        var gifURL = await value.ref.getDownloadURL();
        String urlFile = gifURL.toString();


        // save message in firebase firestore
        onStickerSelected(urlFile);

        // Hide processing dialog
        _pr.hide();
      });


      // getApplicationSupportDirectory().then((pathDir) async{
      //
      //
      // });
    }

  }
}













//[
//
//
//                     // Container(
//                     //   padding: const EdgeInsets.only(top: 5),
//                     //   width: 200,
//                     //   height: 200,
//                     //   child: GestureDetector(
//                     //     onTap: () async{
//                     //
//                     //       //Upload to storage
//                     //       Navigator.of(context).pop();
//                     //       uploadToFirebase('assets/stickers/stickerSVG1.svg');
//                     //
//                     //     },
//                     //     child: SvgIcon("assets/stickers/stickerSVG1.svg",
//                     //         width: 200,
//                     //         height: 200,
//                     //         color: Colors.white),
//                     //   ),
//                     // ),
//
//
//
//                     Container(
//                       width: 200,
//                       height: 200,
//                       child: GestureDetector(
//                         child: Image.asset(
//                           'assets/stickers/sticker.png',
//                           width: 200,
//                           height: 200,
//                           fit: BoxFit.contain,
//                         ),
//                         onTap: () async{
//
//                           //Upload to storage
//                           Navigator.of(context).pop();
//                           uploadToFirebase('assets/stickers/sticker.jpeg');
//
//                         },
//                       ),
//                     ),
//
//
//                     Container(
//                       width: 200,
//                       height: 200,
//                       child: GestureDetector(
//                         child: Image.asset(
//                           'assets/stickers/sticker26.jpeg',
//                           width: 200,
//                           height: 200,
//                           fit: BoxFit.contain,
//                         ),
//                         onTap: () async{
//
//                           //Upload to storage
//                           Navigator.of(context).pop();
//                           uploadToFirebase('assets/stickers/sticker26.jpeg');
//
//                         },
//                       ),
//                     ),
//
//
//                   ]