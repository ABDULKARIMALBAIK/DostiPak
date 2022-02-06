import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rishtpak/dialogs/progress_dialog.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/screens/home_screen.dart';
import 'package:rishtpak/screens/sign_up_screen.dart';
import 'package:rishtpak/screens/verification_code_screen.dart';
import 'package:rishtpak/widgets/default_button.dart';
import 'package:rishtpak/widgets/show_scaffold_msg.dart';
import 'package:rishtpak/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberScreen extends StatefulWidget {

  //New Vars
  bool isSecurePassword = true;


  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  // Variables
  final _formKey = GlobalKey<FormState>();
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final _numberController = TextEditingController();
  //New Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  //New Controllers
  String? _phoneCode = '+1'; // Define yor default phone code
  String _initialSelection = 'US'; // Define yor default country code
  late AppLocalizations _i18n;
  late ProgressDialog _pr;



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context, isDismissible: false);

    return SafeArea(
      child: Scaffold(
          key: _scaffoldkey,
          appBar: AppBar(
            title: Text(_i18n.translate("phone_password")),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[

                ////////////////////////// * Image * //////////////////////////
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(Icons.email_outlined , color: Colors.white, size: 30,),
                ),
                SizedBox(height: 10),


                ////////////////////////// * Title * //////////////////////////
                Text(_i18n.translate("sign_in_with_email_password"), textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                SizedBox(height: 25),



                ////////////////////////// * Subtitle * //////////////////////////
                Text(
                    _i18n.translate("enter_your_email_password_and_we_will_send_verification_email"),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 22),

                /// Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[


                      ////////////////////////// * Phone Number (OLD) * //////////////////////////
                      // TextFormField(
                      //   controller: _numberController,
                      //   decoration: InputDecoration(
                      //       labelText: _i18n.translate("phone_number"),
                      //       hintText: _i18n.translate("enter_your_number"),
                      //       floatingLabelBehavior: FloatingLabelBehavior.always,
                      //       prefixIcon: Padding(
                      //         padding: const EdgeInsets.only(left: 8.0),
                      //         child: CountryCodePicker(
                      //             alignLeft: false,
                      //             initialSelection: _initialSelection,
                      //             onChanged: (country) {
                      //               /// Get country code
                      //               _phoneCode = country.dialCode!;
                      //             }),
                      //       )),
                      //   keyboardType: TextInputType.number,
                      //   inputFormatters: <TextInputFormatter>[
                      //     FilteringTextInputFormatter.allow(new RegExp("[0-9]"))
                      //   ],
                      //   validator: (number) {
                      //     // Basic validation
                      //     if (number == null) {
                      //       return _i18n
                      //           .translate("please_enter_your_phone_number");
                      //     }
                      //     return null;
                      //   },
                      // ),




                      ////////////////////////// * Email/Password (NEW) * //////////////////////////
                      AutofillGroup(
                        child: Column(
                          children: [

                            ////////////////////////// * Email (NEW) * //////////////////////////
                            TextFormField(
                              autofillHints: [AutofillHints.email],
                              controller: _emailController,
                              enableSuggestions: true,
                              readOnly: false,
                              autocorrect: true,
                              style: TextStyle(color: Colors.black.withOpacity(0.9)),
                              textInputAction: TextInputAction.next,
                              cursorColor: Theme.of(context).primaryColor,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                                errorStyle: TextStyle(color: Theme.of(context).primaryColor, fontSize: 10, fontStyle: FontStyle.italic , fontWeight: FontWeight.w200),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(300),
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1)
                                ),
                                  focusedBorder:  OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(300),
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1)
                                  ),
                                  enabledBorder:  OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(300),
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1)
                                  ),
                                  labelText: _i18n.translate("email"),
                                  hintText: _i18n.translate("enter_your_email"),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  prefixIcon: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Icon(Icons.email_outlined , color: Theme.of(context).primaryColor,)
                                  )
                              ),
                              keyboardType: TextInputType.emailAddress,
                              // inputFormatters: <TextInputFormatter>[
                              //   FilteringTextInputFormatter.allow(new RegExp("[0-9]"))
                              // ],
                              validator: (email) {
                                // Basic validation
                                if (email == null) {
                                  return _i18n.translate("please_enter_your_email");
                                }
                                else if (validateEmail(email)){
                                  return _i18n.translate("please_enter_your_email");
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20,),



                            ////////////////////////// * Password (NEW) * //////////////////////////
                            TextFormField(
                              autofillHints: [AutofillHints.password],
                              controller: _passwordController,
                              obscureText: widget.isSecurePassword,
                              autocorrect: true,
                              enableSuggestions: true,
                              readOnly: false,
                              textInputAction: TextInputAction.done,
                              cursorColor: Theme.of(context).primaryColor,
                              style: TextStyle(color: Colors.black.withOpacity(0.9)),
                              onEditingComplete: () => TextInput.finishAutofillContext(),
                              decoration: InputDecoration(
                                errorStyle: TextStyle(color: Theme.of(context).primaryColor, fontSize: 10, fontStyle: FontStyle.italic , fontWeight: FontWeight.w200),
                                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(300),
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1)
                                ),
                                focusedBorder:  OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(300),
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1)
                                ),
                                enabledBorder:  OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(300),
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1)
                                ),
                                labelText: _i18n.translate("password"),
                                hintText: _i18n.translate("enter_your_password"),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                prefixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Icon(Icons.vpn_key_outlined , color: Theme.of(context).primaryColor,)
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(widget.isSecurePassword ? Icons.visibility : Icons.visibility_off),
                                  color: Theme.of(context).primaryColor,
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  onPressed: () {

                                    widget.isSecurePassword = !widget.isSecurePassword;
                                    setState(() {
                                    });


                                  },
                                ),

                              ),
                              keyboardType: TextInputType.text,
                              // inputFormatters: <TextInputFormatter>[
                              //   FilteringTextInputFormatter.allow(new RegExp("[0-9]"))
                              // ],
                              validator: (password) {
                                // Basic validation
                                if (password == null) {
                                  return _i18n.translate("please_enter_your_password");
                                }
                                else if (strongPassword(password)){
                                  return _i18n.translate("please_enter_your_password");
                                }
                                return null;
                              },
                            ),

                          ],
                        ),
                      ),
                      SizedBox(height: 8,),



                      ////////////////////////// * Button * //////////////////////////
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.maxFinite,
                        child: DefaultButton(
                          child: Text(_i18n.translate("CONTINUE"), style: TextStyle(fontSize: 18)),
                          onPressed: () async {
                            /// Validate form
                            /// Sign in
                            _signIn(context);
                          },
                        ),
                      ),



                      ////////////////////////// * Button sign up * //////////////////////////
                      SizedBox(height: 12),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        child: Center(
                          child: DefaultButton(
                            width: 120,
                            height: 30,
                            child:  Text(
                                _i18n.translate('sign_up'),
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.w400,
                                    fontSize: 12 ,
                                    letterSpacing: 2)
                            ),
                            onPressed: () async {
                              //Go to sign up
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => SignUpScreen()));
                            },
                          ),
                        ),
                      ),



                      ////////////////////////// * Forget Password (NEW) * //////////////////////////
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 12.0 , horizontal: 18),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: (){

                                  //Show Message
                                  showScaffoldMessage(
                                      context: context,
                                      message: _i18n.translate("click_forget_password"),
                                      bgcolor: Theme.of(context).primaryColor);

                                },
                                child: Text(
                                  _i18n.translate("forget_password"),
                                  style: TextStyle(
                                    // decoration:  TextDecoration.underline,
                                    // decorationColor: Theme.of(context).primaryColor,
                                      color: Theme.of(context).primaryColor,
                                      // fontWeight: FontWeight.w400,
                                      fontSize: 12 ,
                                      // fontStyle: FontStyle.italic,
                                      letterSpacing: 2),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),


                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  /// Sign in with phone number
  void _signIn(BuildContext context) async {

    ////////NEW

    //Validate data
    if(_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty){
      if(validateEmail(_emailController.text)){
        if(strongPassword(_passwordController.text)){

          // Show progress dialog
          _pr.show(_i18n.translate("processing"));

          //Start Save data
            try {

                //Sign in Email And Password
                await FirebaseAuth.instance
                    .signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text)
                    .then((userCredential) async {

                  print('sign in successfully');

                  /// Auth user account
                  UserModel().authUserAccount(
                      context: context,
                      scaffoldkey: _scaffoldkey,
                      homeScreen: () {

                        _pr.hide();

                        /// Go to home screen
                        Future(() {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => HomeScreen()) , (route) => false);
                        });
                      },
                      signUpScreen: () {

                        _pr.hide();

                        /// Go to sign up screen
                        Future(() {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => SignUpScreen()));
                        });
                      });



                });
              }
              on FirebaseAuthException catch (e) {
                //User Not Found
                if (e.code == 'user-not-found') {

                  print('No user found for that email.');

                  _pr.hide();


                  //SnackBar
                  _scaffoldkey.currentState!.showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).primaryColor,
                        content: Text(_i18n.translate("account_is_not_exists") , style: TextStyle(color: Colors.white),),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: (){},
                          textColor: Colors.white,
                        ),
                      )
                  );


                }
                //Wrong Password
                else if (e.code == 'wrong-password') {

                  print('Wrong password provided for that user.');

                  _pr.hide();

                  //SnackBar
                  _scaffoldkey.currentState!.showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).primaryColor,
                        content: Text(_i18n.translate("account_is_not_exists") , style: TextStyle(color: Colors.white),),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: (){},
                          textColor: Colors.white,
                        ),
                      )
                  );
                }
              }

        }
        else {

          _scaffoldkey.currentState!.showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).primaryColor,
                content: Text(_i18n.translate("please_enter_your_password") , style: TextStyle(color: Colors.white),),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: (){},
                  textColor: Colors.white,
                ),
              )
          );
        }
      }
      else{
        _scaffoldkey.currentState!.showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              content: Text(_i18n.translate("please_enter_your_email") , style: TextStyle(color: Colors.white),),
              action: SnackBarAction(
                label: 'OK',
                onPressed: (){},
                textColor: Colors.white,
              ),
            )
        );
      }
    }
    else {
      _scaffoldkey.currentState!.showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            content: Text(_i18n.translate("please_fill_data") , style: TextStyle(color: Colors.white),),
            action: SnackBarAction(
              label: 'OK',
              onPressed: (){},
              textColor: Colors.white,
            ),
          )
      );
    }

    ////////NEW


  }



  ///Validate if email   (NEW)
  bool validateEmail(String email){
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    return emailValid;
  }


  ///Validate if password   (NEW)
  bool strongPassword(String password){
    if(
    (
        password.contains(RegExp(r"[a-z]")) || password.contains(RegExp(r"[A-Z]"))) &&
        password.contains(RegExp(r"[0-9]")) &&
        password.contains(RegExp(r'[!@#\$%^&*(),.?:{}[]|<>]')) &&
        password.length >= 8){

      return true;
    }
    else
      return false;
  }
}





//   try {
//                 //Sign in Email And Password
//                 await FirebaseAuth.instance
//                     .signInWithEmailAndPassword(email: email, password: password)
//                     .then((userCredential) {
//                   print('sign in successfully');
//
//                   //Check email is verified
//                   if (userCredential.user!.emailVerified) {
//                     print('email is verified');
//
//                     //Go to foods
//                     Common.currentUser = userCredential.user as User;
//                     VxNavigator.of(context)
//                         .push(Uri(path: Routers.foodsRoute));
//                   }
//                   else {
//                     print('email is not verified');
//
//                     //Init Dynamic Link
//                     ///url:  https://abdulkarimalbaik.page.link/sign/?email=${userCredential.user!.email}
//                     var actionCodeSettings = ActionCodeSettings(
//                         url: 'https://foody-e374f.firebaseapp.com',
//                         dynamicLinkDomain: "abdulkarimalbaik.page.link",
//                         androidPackageName: "com.abdulkarimalbaik.foody",
//                         androidInstallApp: true,
//                         androidMinimumVersion: "22",
//                         iOSBundleId: "com.abdulkarimalbaik.foody",
//                         handleCodeInApp: true);
//
//                     //Send Email Verification
//                     userCredential.user!
//                         .sendEmailVerification(actionCodeSettings);
//
//                     //SnackBar Send Email
//                     SnakBarBuilder.buildAwesomeSnackBar(
//                         context,
//                         AppLocalizations.of(context)!.translate('home_snackBar_sendEmail_content'),
//                         Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white),
//                         AwesomeSnackBarType.info);
//
//                     // key.currentState!.showSnackBar(SnakBarBuilder.build(
//                     //     context,
//                     //     SelectableText(
//                     //       AppLocalizations.of(context)!
//                     //           .translate('home_snackBar_sendEmail_content'),
//                     //       cursorColor: Theme.of(context).primaryColor,
//                     //     ),
//                     //     AppLocalizations.of(context)!.translate('global_ok'),
//                     //         () {print('yes');}));
//                   }
//                 });
//               } on FirebaseAuthException catch (e) {
//                 //User Not Found
//                 if (e.code == 'user-not-found') {
//                   print('No user found for that email.');
//
//                   //SnackBar
//                   SnakBarBuilder.buildAwesomeSnackBar(
//                       context,
//                       AppLocalizations.of(context)!.translate('signIn_snackBar_emailNotFound'),
//                       Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white),
//                       AwesomeSnackBarType.error);
//
//                   // key.currentState!.showSnackBar(SnakBarBuilder.build(
//                   //     context,
//                   //     SelectableText(
//                   //       AppLocalizations.of(context)!
//                   //           .translate('signIn_snackBar_emailNotFound'),
//                   //       cursorColor: Theme.of(context).primaryColor,
//                   //     ),
//                   //     AppLocalizations.of(context)!.translate('global_ok'),
//                   //         () {print('yes');}));
//                 }
//                 //Wrong Password
//                 else if (e.code == 'wrong-password') {
//                   print('Wrong password provided for that user.');
//
//                   //SnackBar
//                   SnakBarBuilder.buildAwesomeSnackBar(
//                       context,
//                       AppLocalizations.of(context)!.translate('signIn_snackBar_wrongPassword'),
//                       Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white),
//                       AwesomeSnackBarType.error);
//
//                   // key.currentState!.showSnackBar(SnakBarBuilder.build(
//                   //     context,
//                   //     SelectableText(
//                   //       AppLocalizations.of(context)!
//                   //           .translate('signIn_snackBar_wrongPassword'),
//                   //       cursorColor: Theme.of(context).primaryColor,
//                   //     ),
//                   //     AppLocalizations.of(context)!.translate('global_ok'),
//                   //         () {print('yes');}));
//                 }
//               }
