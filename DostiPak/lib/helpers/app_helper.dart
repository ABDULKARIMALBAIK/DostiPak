import 'dart:io';

import 'package:rishtpak/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/models/app_model.dart';

class AppHelper {
  /// Local variables
  final _firestore = FirebaseFirestore.instance;

  /// Check and request location permission
  Future<void> checkLocationPermission(
      {required VoidCallback onGpsDisabled,
      required VoidCallback onDenied,
      required VoidCallback onGranted}) async {
    /// Check if GPS is enabled
    if (!(await Geolocator.isLocationServiceEnabled())) {
      // Callback function
      onGpsDisabled();
      debugPrint('onGpsDisabled() -> disabled');
    } else {
      /// Request permission
      final LocationPermission permission =
          await Geolocator.requestPermission();

      switch (permission) {
        case LocationPermission.denied:
          onDenied();
          debugPrint('permission: denied');
          break;
        case LocationPermission.deniedForever:
          onDenied();
          debugPrint('permission: deniedForever');
          break;
        case LocationPermission.whileInUse:
          onGranted();
          debugPrint('permission: whileInUse');
          break;
        case LocationPermission.always:
          onGranted();
          debugPrint('permission: always');
          break;
      }
    }
  }

  /// Get User location from formatted address
  Future<Placemark> getUserAddress(double latitude, double longitude) async {
    /// Place object containing formatted address info
    Placemark place;

    ///  Get Placemark to retrieve user location
    final List<Placemark> places =
        await placemarkFromCoordinates(latitude, longitude);

    /// Get and returns the first place
    place = places.first;

    return place;
  }

  /// Get distance between current user and another user
  /// Returns distance in (Kilometers - KM)
  int getDistanceBetweenUsers(
      {required double userLat, required double userLong}) {
    /// Get instance of [Geoflutterfire]
    final Geoflutterfire geo = new Geoflutterfire();

    /// Set current user location [GeoFirePoint]
    final GeoFirePoint center = geo.point(
        latitude: UserModel().user.userGeoPoint.latitude,
        longitude: UserModel().user.userGeoPoint.longitude);

    /// Return distance (double) between users then round to int
    return center.distance(lat: userLat, lng: userLong).round();
  }

  /// Get app store URL - Google Play / Apple Store
  String get _appStoreUrl {
    String url = "";
    final String androidPackageName = AppModel().appInfo.androidPackageName;
    final String iOsAppId = AppModel().appInfo.iOsAppId;
    // Check device OS
    if (Platform.isAndroid) {
      url = ".............................................";
    } else if (Platform.isIOS) {
      url = "..........................................";
    }
    return url;
  }

  /// Get app current version from Cloud Firestore Database,
  /// that is the same with Google Play Store / Apple Store app version
  Future<int> getAppStoreVersion() async {
    final DocumentSnapshot appInfo =
        await _firestore.collection(C_APP_INFO).doc('settings').get();
    // Update AppInfo object
    AppModel().setAppInfo(appInfo.data()!);
    // Check Platform
    if (Platform.isAndroid) {
      return appInfo.data()?[ANDROID_APP_CURRENT_VERSION] ?? 1;
    } else if (Platform.isIOS) {
      return appInfo.data()?[IOS_APP_CURRENT_VERSION] ?? 1;
    }
     return 1;
  }

  /// Update app info data in database
  Future<void> updateAppInfo(Map<String, dynamic> data) async {
    // Update app data
    _firestore.collection(C_APP_INFO).doc('settings').update(data);
  }

  /// Share app method
  Future<void> shareApp() async {
    Share.share(_appStoreUrl);
  }

  /// Review app method
  Future<void> reviewApp() async {
    // Check OS and get correct url
    final String url =
        Platform.isIOS ? "......................" : _appStoreUrl;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  /// Open app store - Google Play / Apple Store
  Future<void> openAppStore() async {
    if (await canLaunch(_appStoreUrl)) {
      await launch(_appStoreUrl);
    } else {
      throw "Could not open app store url....";
    }
  }



  /// Open About us in Browser
  Future<void> openAboutUs() async {
    if (await canLaunch(".......................................")) {
      await launch(".................................");
    }
    else {
      throw "Could not launch url";
    }
  }



  /// Open watch video in Browser
  Future<void> openWatchVideo() async {
    if (await canLaunch("................................")) {
      await launch("............................");
    }
    else {
      throw "Could not launch url";
    }
  }


  /// Open earn money in Browser
  Future<void> openEarnMoney() async {
    if (await canLaunch("..................................")) {
      await launch("...........................");
    }
    else {
      throw "Could not launch url";
    }
  }


  /// Open Privacy Policy Page in Browser
  Future<void> openPrivacyPage() async {
    if (await canLaunch(AppModel().appInfo.privacyPolicyUrl)) {
      await launch(AppModel().appInfo.privacyPolicyUrl);
    } else {
      throw "Could not launch url";
    }
  }

  /// Open Terms of Services in Browser
  Future<void> openTermsPage() async {
    // Try to launch
    if (await canLaunch(AppModel().appInfo.termsOfServicesUrl)) {
      await launch(AppModel().appInfo.termsOfServicesUrl);
    } else {
      throw "Could not launch url";
    }
  }
}
