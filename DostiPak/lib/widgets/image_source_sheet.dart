import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/widgets/svg_icon.dart';

class ImageSourceSheet extends StatelessWidget {
  // Constructor
  ImageSourceSheet({required this.onImageSelected});

  // Callback function to return image file
  final Function(File?) onImageSelected;
  // ImagePicker instance
  final picker = ImagePicker();

  Future<void> selectedImage(BuildContext context, File? image) async {
    // init i18n
    final i18n = AppLocalizations.of(context);

    // Check file
    if (image != null) {
      final croppedImage = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          maxWidth: 400,
          maxHeight: 400,
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: i18n.translate("edit_crop_image"),
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
          ));
      onImageSelected(croppedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return BottomSheet(
        onClosing: () {},
        builder: ((context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [

            SizedBox(height: 10,),

            Container(
              padding: const EdgeInsets.all(18),
              width: 200,
              height: 5,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(300) ,color: Colors.grey,),
            ),

            SizedBox(height: 15,),



            Text(i18n.translate("media") , style: TextStyle(color: Theme.of(context).primaryColor , fontSize: 24),),
            SizedBox(height: 15,),


            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(i18n.translate("choose_your_image") , style: TextStyle(color: Colors.grey.withOpacity(0.7) , fontSize: 18),),
            ),
            SizedBox(height: 5,),


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  /// Select image from gallery
                  ElevatedButton.icon(
                    icon: Icon(Icons.photo_size_select_actual_outlined, color: Colors.white, size: 28),
                    label: Text(i18n.translate("gallery"), style: TextStyle(fontSize: 20 , color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(400))
                    ),
                    onPressed: () async {

                      // Get image from device gallery
                      final pickedFile = await picker.getImage(source: ImageSource.gallery,);

                      if (pickedFile == null) return;
                      selectedImage(context, File(pickedFile.path));
                    },
                  ),

                  SizedBox(width: 25,),

                  /// Capture image from camera
                  OutlinedButton.icon(
                    // icon: SvgIcon("assets/icons/camera_icon.svg", width: 24, height: 24),
                    icon: Icon(Icons.camera, color: Theme.of(context).primaryColor, size: 28),
                    label: Text(i18n.translate("camera"), style: TextStyle(fontSize: 20 , color: Theme.of(context).primaryColor)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(400)),
                      primary: Theme.of(context).primaryColor,
                    ),
                    onPressed: () async {
                      // Capture image from camera
                      final pickedFile = await picker.getImage(
                        source: ImageSource.camera,
                      );
                      if (pickedFile == null) return;
                      selectedImage(context, File(pickedFile.path));
                    },
                  ),
                ],
              ),
            ),
          ],
        )));
  }
}



//Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 /// Select image from gallery
//                 TextButton.icon(
//                   icon: Icon(Icons.photo_library, color: Colors.grey, size: 27),
//                   label: Text(i18n.translate("gallery"), style: TextStyle(fontSize: 16)),
//                   onPressed: () async {
//                     // Get image from device gallery
//                     final pickedFile = await picker.getImage(
//                       source: ImageSource.gallery,
//                     );
//                     if (pickedFile == null) return;
//                     selectedImage(context, File(pickedFile.path));
//                   },
//                 ),
//
//                 /// Capture image from camera
//                 TextButton.icon(
//                   icon: SvgIcon("assets/icons/camera_icon.svg",
//                       width: 20, height: 20),
//                   label: Text(i18n.translate("camera"),
//                       style: TextStyle(fontSize: 16)),
//                   onPressed: () async {
//                     // Capture image from camera
//                     final pickedFile = await picker.getImage(
//                       source: ImageSource.camera,
//                     );
//                     if (pickedFile == null) return;
//                     selectedImage(context, File(pickedFile.path));
//                   },
//                 ),
//               ],
//             )
