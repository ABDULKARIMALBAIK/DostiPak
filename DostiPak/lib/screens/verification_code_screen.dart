import 'package:rishtpak/dialogs/common_dialogs.dart';
import 'package:rishtpak/dialogs/progress_dialog.dart';
import 'package:rishtpak/helpers/app_helper.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/plugins/otp_screen/otp_screen.dart';
import 'package:rishtpak/screens/enable_location_screen.dart';
import 'package:rishtpak/screens/home_screen.dart';
import 'package:rishtpak/screens/sign_up_screen.dart';
import 'package:rishtpak/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:rishtpak/helpers/app_localizations.dart';

class VerificationCodeScreen extends StatefulWidget {
  // Variables
  final String verificationId;

  // Constructor
  VerificationCodeScreen({
    required this.verificationId,
  });

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  // Variables
  late AppLocalizations _i18n;
  late ProgressDialog _pr;
  final _scaffoldkey = GlobalKey<ScaffoldState>();

  /// Navigate to next page
  void _nextScreen(screen) {
    // Go to next page route
    Future(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => screen), (route) => false);
    });
  }

  /// Go to enable location or GPS screen
  void goToEnableLocationOrGpsScreen(String action) {
    // Navigate
    _nextScreen(EnableLocationScreen(action: action));
  }

  /// logic to validate otp return [null] when success else error [String]
  Future<String?> validateOtp(String otp) async {
    /// Handle entered verification code here
    ///
    /// Show progress dialog
    _pr.show(_i18n.translate("processing"));

    await UserModel().signInWithOTP(
        verificationId: widget.verificationId,
        otp: otp,
        checkUserAccount: () {
          /// Auth user account
          UserModel().authUserAccount(
              context: context,
              scaffoldkey: _scaffoldkey,
              homeScreen: () {
            /// Go to home screen
            _nextScreen(HomeScreen());
          }, signUpScreen: () async {
            // AppHelper instance
            final AppHelper appHelper = new AppHelper();

            /// Check location permission
            await appHelper.checkLocationPermission(onGpsDisabled: () {
              /// Go to Enable GPS screen
              goToEnableLocationOrGpsScreen('GPS');
            }, onDenied: () {
              /// Go to enable location screen
              goToEnableLocationOrGpsScreen('location');
            }, onGranted: () {
              /// Go to sign up screen
              _nextScreen(SignUpScreen());
            });
          });
        },
        onError: () async {
          // Hide dialog
          await _pr.hide();
          // Show error message to user
          errorDialog(context,
              message: _i18n.translate("we_were_unable_to_verify_your_number"));
        });

    // Hide progress dialog
    await _pr.hide();

    return null;
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context, isDismissible: false);

    return Scaffold(
      key: _scaffoldkey,
      body: OtpScreen.withGradientBackground(
        topColor: Theme.of(context).primaryColor,
        bottomColor: Theme.of(context).primaryColor.withOpacity(.7),
        otpLength: 6,
        validateOtp: validateOtp,
        routeCallback: (context) {},
        icon: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: SvgIcon("assets/icons/phone_icon.svg",
              width: 40, height: 40, color: Theme.of(context).primaryColor),
        ),
        title: _i18n.translate("verification_code"),
        subTitle: _i18n.translate("please_enter_the_sms_code_sent"),
      ),
    );
  }
}
