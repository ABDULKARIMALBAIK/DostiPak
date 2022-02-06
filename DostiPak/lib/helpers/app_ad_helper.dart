import 'dart:io';

import 'package:rishtpak/constants/constants.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppAdHelper {
  // Local Variables
  static InterstitialAd? _interstitialAd;
  //

  // Get Interstitial Ad ID
  static String get _interstitialID {
    if (Platform.isAndroid) {
      return ANDROID_INTERSTITIAL_ID;
    } else if (Platform.isIOS) {
      return IOS_INTERSTITIAL_ID;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  // Ad Event Listener
  static final AdListener _adListener = AdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) {
      print('Ad loaded.');
      _interstitialAd?.show();
    },
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      ad.dispose();
      print('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) {
      ad.load();
      print('Ad closed.');
    },
    // Called when an ad is in the process of leaving the application.
    onApplicationExit: (Ad ad) => print('Left application.'),
  );

  // Create Interstitial Ad
  static Future<void> _createInterstitialAd() async {
    _interstitialAd = InterstitialAd(
        adUnitId: _interstitialID,
        request: AdRequest(),
        listener: _adListener);
      // Load InterstitialAd Ad
      _interstitialAd?.load();
  }

  // Show Interstitial Ads for Non VIP Users
  static Future<void> showInterstitialAd() async {
    /// Check User VIP Status
    if (!UserModel().userIsVip) {
      _createInterstitialAd();
    } else {
      print('User is VIP');
    }
  }

  // Dispose Interstitial Ad
  static void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
