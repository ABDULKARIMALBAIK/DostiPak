import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rishtpak/api/conversations_api.dart';
import 'package:rishtpak/api/notifications_api.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/helpers/app_notifications.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/screens/notifications_screen.dart';
import 'package:rishtpak/tabs/conversations_tab.dart';
import 'package:rishtpak/tabs/discover_tab.dart';
import 'package:rishtpak/tabs/matches_tab.dart';
import 'package:rishtpak/tabs/profile_tab.dart';
import 'package:rishtpak/widgets/notification_counter.dart';
import 'package:rishtpak/widgets/show_scaffold_msg.dart';
import 'package:rishtpak/widgets/svg_icon.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rishtpak/constants/constants.dart';
import 'package:in_app_purchase/in_app_purchase.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
  /// Variables
  final _conversationsApi = ConversationsApi();
  final _notificationsApi = NotificationsApi();
  final _appNotifications = AppNotifications();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  late AppLocalizations _i18n;
  late Stream<DocumentSnapshot> _userStream;
  // in_app_purchase stream
  late StreamSubscription<List<PurchaseDetails>> _inAppPurchaseStream;

  /// Tab navigation
  Widget _showCurrentNavBar() {
    List<Widget> options = <Widget>[
      DiscoverTab(),
      MatchesTab(),
      ConversationsTab(),
      ProfileTab()
    ];

    return options.elementAt(_selectedIndex);
  }

  /// Update selected tab
  void _onTappedNavBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Get current User Real Time updates
  void _getCurrentUserUpdates() {
    /// Get user stream
    _userStream = UserModel().getUserStream();

    /// Subscribe to user updates
    _userStream.listen((userEvent) {
      // Update user
      UserModel().updateUserObject(userEvent.data()!);
    });
  }

  /// Check current User VIP Account status
  Future<void> _checkUserVipStatus() async {
    // Query past subscriptions
    InAppPurchaseConnection.instance
        .queryPastPurchases()
        .then((QueryPurchaseDetailsResponse pastPurchases) {
      // Chek past purchases result
      if (pastPurchases.pastPurchases.isNotEmpty) {
        for (var purchase in pastPurchases.pastPurchases) {
          /// Updae User VIP Status to true
          UserModel().setUserVip();
          // Set Vip Subscription Id
          UserModel().setActiveVipId(purchase.productID);
          // Debug
          print('Active VIP SKU: ${purchase.productID}');
        }
      } else {
        print('No Active VIP Subscription');
      }
    });
  }

  /// Handle in-app purchases upates
  void _handlePurchaseUpdates() {
    // listen purchase updates
    _inAppPurchaseStream = InAppPurchaseConnection
        .instance.purchaseUpdatedStream
        .listen((purchases) async {
      // Loop incoming purchases
      for (var purchase in purchases) {
        // Control purchase status
        switch (purchase.status) {
          case PurchaseStatus.pending:
            // Handle this case.
            break;
          case PurchaseStatus.purchased:

            /// **** Deliver product to user **** ///
            ///
            /// Update User VIP Status to true
            UserModel().setUserVip();
            // Set Vip Subscription Id
            UserModel().setActiveVipId(purchase.productID);

            /// Update user verified status
            await UserModel().updateUserData(
                userId: UserModel().user.userId,
                data: {USER_IS_VERIFIED: true});

            // User first name
            final String userFirstname =
                UserModel().user.userFullname.split(' ')[0];

            /// Save notification in database for user
            _notificationsApi.onPurchaseNotification(
              nMessage: '${_i18n.translate("hello")} $userFirstname, '
                  '${_i18n.translate("your_vip_account_is_active")}\n '
                  '${_i18n.translate("thanks_for_buying")}',
            );

            if (purchase.pendingCompletePurchase) {
              /// Complete pending purchase
              InAppPurchaseConnection.instance.completePurchase(purchase);
              print('Success pending purchase completed!');
            }
            break;
          case PurchaseStatus.error:
            // Handle this case.
            print('purchase error-> ${purchase.error?.message}');
            break;
        }
      }
    });
  }



  Future<void> _handleNotificationClick(Map<String, dynamic>? data) async {

    /// Handle notification click
    await _appNotifications.onNotificationClick(
        context,
        nType: data?[N_TYPE] ?? '',
        nSenderId: data?[N_SENDER_ID] ?? '',
        nMessage: data?[N_MESSAGE] ?? '',
        // CallInfo payload
        nCallInfo: data?['call_info'] ?? '');
  }

  /// Request permission for push notifications
  /// Only for iOS
  void _requestPermissionForIOS() async {
    if (Platform.isIOS) {
      // Request permission for iOS devices
      await FirebaseMessaging.instance.requestPermission();
    }
  }

  ///
  /// Handle incoming notifications while the app is in the Foreground
  ///
  Future<void> _initFirebaseMessage() async {
    // Get initial message if the application
    // has been opened from a terminated state.
    final message = await FirebaseMessaging.instance.getInitialMessage();
    // Check notification data
    if (message != null) {
      // Debug
      print('getInitialMessage() -> data: ${message.data}');
      // Handle notification data
      await _handleNotificationClick(message.data);
    }

    // Returns a [Stream] that is called when a user
    // presses a notification message displayed via FCM.
    // Note: A Stream event will be sent if the app has
    // opened from a background state (not terminated).
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // Debug
      print('onMessageOpenedApp() -> data: ${message.data}');
      // Handle notification data
      await _handleNotificationClick(message.data);
    });

    // Listen for incoming push notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      // Debug
      print('onMessage() -> data: ${message?.data}');
      // Handle notification data
      await _handleNotificationClick(message?.data);
    });
  }

  @override
  void initState() {
    super.initState();

    /// Check User VIP Status
    _checkUserVipStatus();

    /// Init streams
    _getCurrentUserUpdates();
    _handlePurchaseUpdates();
    _initFirebaseMessage();

    /// Request permission for IOS
    _requestPermissionForIOS();





    //Online stream
    WidgetsBinding.instance!.addObserver(this);
    //Change online status
    UserModel().getUser(UserModel().user.userId).then((snapshot) {

      Map<String,dynamic> data =  snapshot.data()!;

      if(data[USER_ONLINE] != true){

        data[USER_ONLINE] = true;
        FirebaseFirestore.instance.collection(C_USERS).doc(UserModel().user.userId).update(data);
      }

    });

  }

  @override
  void dispose() {
    super.dispose();
    // Close streams
    _userStream.drain();
    _inAppPurchaseStream.cancel();


    // WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    bool isBg = state == AppLifecycleState.paused;
    bool isClosed = state == AppLifecycleState.detached;
    bool isScreen = state == AppLifecycleState.resumed;

    print('state now is paused : ${state == AppLifecycleState.paused}');
    print('state now is resumed : ${state == AppLifecycleState.resumed}');
    print('state now is detached : ${state == AppLifecycleState.detached}');
    print('state now is inactive : ${state == AppLifecycleState.inactive}');
    print('state of app isBg : ${isBg}');
    print('state of app isClosed : ${isClosed}');
    print('state of app isScreen : ${isScreen}');

    if(isScreen == true){  //isBg || isScreen == true || isClosed == false
      //Set online
      UserModel().getUser(UserModel().user.userId).then((snapshot) {

        Map<String,dynamic> data =  snapshot.data()!;
        print('1- data from online/offline is : ${data[USER_ONLINE]}');

        if(data[USER_ONLINE] != true){

          data[USER_ONLINE] = true;
          FirebaseFirestore.instance.collection(C_USERS).doc(UserModel().user.userId).update(data).then((value) => print('is update online successfully'));
          UserModel().updateUserObject(data);
        }

      });
    }
    else {
      //Set offline
      UserModel().getUser(UserModel().user.userId).then((snapshot) {

        Map<String,dynamic> data =  snapshot.data()!;
        print('2- data from online/offline is : ${data[USER_ONLINE]}');

        if(data[USER_ONLINE] != false){

          data[USER_ONLINE] = false;
          FirebaseFirestore.instance.collection(C_USERS).doc(UserModel().user.userId).update(data).then((value) => print('is update offline successfully'));
          UserModel().updateUserObject(data);
        }

      });
    }
  }


  @override
  Widget build(BuildContext context) {

    /// Initialization
    _i18n = AppLocalizations.of(context);

    //Show Message Swipe left and swipe right
    // showScaffoldMessage(
    //     context: context,
    //     message: _i18n.translate("swipe_left_right_toast_message"),
    //     bgcolor: Theme.of(context).primaryColor);





    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset("assets/images/app_logo_new.jpeg", width: 40, height: 40),
              SizedBox(width: 5),
              Text(APP_NAME),
            ],
          ),
          actions: [
            IconButton(
                icon: _getNotificationCounter(),
                onPressed: () async {
                  // Go to Notifications Screen
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotificationsScreen()));
                })
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            elevation: Platform.isIOS ? 0 : 8,
            currentIndex: _selectedIndex,
            onTap: _onTappedNavBar,
            items: [
              /// Discover Tab
              BottomNavigationBarItem(
                  icon: SvgIcon("assets/icons/search_icon.svg",
                      width: 27,
                      height: 27,
                      color: _selectedIndex == 0
                          ? Theme.of(context).primaryColor
                          : null),
                  label: _i18n.translate("discover")),

              /// Matches Tab
              BottomNavigationBarItem(
                  icon: SvgIcon(
                      _selectedIndex == 1
                          ? "assets/icons/heart_2_icon.svg"
                          : "assets/icons/heart_icon.svg",
                      color: _selectedIndex == 1
                          ? Theme.of(context).primaryColor
                          : null),
                  label: _i18n.translate("connections")),

              /// Conversations Tab
              BottomNavigationBarItem(
                  icon: _getConversationCounter(),
                  label: _i18n.translate("conversations")),

              /// Profile Tab
              BottomNavigationBarItem(
                  icon: SvgIcon(
                      _selectedIndex == 3
                          ? "assets/icons/user_2_icon.svg"
                          : "assets/icons/user_icon.svg",
                      color: _selectedIndex == 3
                          ? Theme.of(context).primaryColor
                          : null),
                  label: _i18n.translate("profile")),
            ]),
        body: _showCurrentNavBar());
  }



  /// Count unread notifications
  Widget _getNotificationCounter() {


    // Set icon
    final icon = SvgIcon("assets/icons/bell_icon.svg", width: 33, height: 33);

    /// Handle stream
    return StreamBuilder<QuerySnapshot>(
        stream: _notificationsApi.getNotifications(),
        builder: (context, snapshot) {
          // Check result
          if (!snapshot.hasData) {
            return icon;
          }
          else {

            /// Get total counter to alert user
            final total = snapshot.data!.docs
                .where((doc) => doc.data()[N_READ] == false)
                .toList()
                .length;
            if (total == 0) return icon;
            return NotificationCounter(icon: icon, counter: total);
          }
        });
  }

  /// Count unread conversations
  Widget _getConversationCounter() {
    // Set icon
    final icon = SvgIcon(
        _selectedIndex == 2
            ? "assets/icons/message_2_icon.svg"
            : "assets/icons/message_icon.svg",
        width: 30,
        height: 30,
        color: _selectedIndex == 2 ? Theme.of(context).primaryColor : null);

    /// Handle stream
    return StreamBuilder<QuerySnapshot>(
        stream: _conversationsApi.getConversations(),
        builder: (context, snapshot) {
          // Check result
          if (!snapshot.hasData) {
            return icon;
          } else {
            /// Get total counter to alert user
            final total = snapshot.data!.docs
                .where((doc) => doc.data()[MESSAGE_READ] == false)
                .toList()
                .length;
            if (total == 0) return icon;
            return NotificationCounter(icon: icon, counter: total);
          }
        });
  }
}
