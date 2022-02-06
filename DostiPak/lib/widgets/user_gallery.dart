import 'package:flutter/material.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/widgets/gallery_image_card.dart';

class UserGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        physics: ScrollPhysics(),
        itemCount: 9,
        shrinkWrap: true,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index) {
          /// Local variables
          String? imageUrl;
          BoxFit boxFit = BoxFit.none;

          dynamic imageProvider =
              AssetImage("assets/images/camera.png");

          if (!UserModel().userIsVip && index > 3) {
            imageProvider = AssetImage("assets/images/crow_badge_small.png");
          }

          /// Check gallery
          if (UserModel().user.userGallery != null) {
            // Check image index
            if (UserModel().user.userGallery!['image_$index'] != null) {
              // Get image link
              imageUrl = UserModel().user.userGallery!['image_$index'];
              // Get image provider
              imageProvider =
                  NetworkImage(UserModel().user.userGallery!['image_$index']);
              // Set boxFit
              boxFit = BoxFit.cover;
            }
          }
          /// Show image widget
          return GalleryImageCard(
            imageProvider: imageProvider,
            boxFit: boxFit,
            imageUrl: imageUrl,
            index: index,
          );
        });
  }
}
