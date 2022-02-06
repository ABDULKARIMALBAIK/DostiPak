import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rishtpak/dialogs/progress_dialog.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart' as path_provider;



class GifSourceSheet extends StatelessWidget {
  // Constructor
  GifSourceSheet({required this.onGifSelected});

  // Callback function to return image file
  final Function(String fireStorageURL) onGifSelected;
  // ImagePicker instance
  final picker = ImagePicker();


  late ProgressDialog _pr;
  late AppLocalizations _i18n;



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
            mainAxisAlignment: MainAxisAlignment.center,
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

              SizedBox(height: 10,),

              /// Select gif
              Expanded(
                child: GridView.count(
                  mainAxisSpacing: 3,
                  crossAxisCount: 4,
                  childAspectRatio: 200/200,
                  crossAxisSpacing: 3,
                  children: [

                    //Git 1
                    Container(
                      width: 200,
                      height: 200,
                      child: GestureDetector(
                        child: Image.asset(
                          'assets/images/gif1.gif',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        onTap: () async{

                          //Upload to storage
                          Navigator.of(context).pop();
                          uploadToFirebase('assets/images/gif1.gif');

                        },
                      ),
                    ),

                    //Git 2
                    Container(
                      width: 200,
                      height: 200,
                      child: GestureDetector(
                        child: Image.asset(
                          'assets/images/gif2.gif',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        onTap: () async{

                          //Upload to storage
                          Navigator.of(context).pop();
                          uploadToFirebase('assets/images/gif2.gif');

                        },
                      ),
                    ),

                    //Git 3
                    Container(
                      width: 200,
                      height: 200,
                      child: GestureDetector(
                        child: Image.asset(
                          'assets/images/gif3.gif',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        onTap: () async{

                          //Upload to storage
                          Navigator.of(context).pop();
                          uploadToFirebase('assets/images/gif3.gif');

                        },
                      ),
                    ),

                    //Git 4
                    Container(
                      width: 200,
                      height: 200,
                      child: GestureDetector(
                        child: Image.asset(
                          'assets/images/gif4.gif',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        onTap: () async{

                          //Upload to storage
                          Navigator.of(context).pop();
                          uploadToFirebase('assets/images/gif4.gif');

                        },
                      ),
                    ),

                    //Git 5
                    Container(
                      width: 200,
                      height: 200,
                      child: GestureDetector(
                        child: Image.asset(
                          'assets/images/gif5.gif',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        onTap: () async{



                          //Upload to storage
                          Navigator.of(context).pop();
                          uploadToFirebase('assets/images/gif5.gif');

                        },
                      ),
                    ),
                  ],
                ),
              )


            ],
          ),
        )));
  }



  void uploadToFirebase(String path) async {

    final byteData = await rootBundle.load(path);
    print('butter size : ${byteData.lengthInBytes}');


    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    else {

      Directory tempDir = await path_provider.getTemporaryDirectory();
      final file = File('${tempDir.path}/${Random().nextInt(10000)}.gif');
      await file.writeAsBytes(byteData.buffer.asUint8List(
          byteData.offsetInBytes, byteData.lengthInBytes));


      // Show processing dialog
      _pr.show(_i18n.translate("sending"));

      // Upload to firebase storage
      final Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/messages/gif${DateTime
          .now()
          .millisecondsSinceEpoch
          .toString()}}.gif');

      UploadTask task = firebaseStorageRef.putFile(file);
      task.then((value) async {

        print('##############done#########');
        var gifURL = await value.ref.getDownloadURL();
        String urlFile = gifURL.toString();


        // save message in firebase firestore
        onGifSelected(urlFile);

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