import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rishtpak/api/visits_api.dart';
import 'package:rishtpak/constants/constants.dart';
import 'package:rishtpak/datas/user.dart';
import 'package:rishtpak/dialogs/vip_dialog.dart';
import 'package:rishtpak/helpers/app_localizations.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/screens/profile_screen.dart';
import 'package:rishtpak/widgets/build_title.dart';
import 'package:rishtpak/widgets/loading_card.dart';
import 'package:rishtpak/widgets/no_data.dart';
import 'package:rishtpak/widgets/processing.dart';
import 'package:rishtpak/widgets/profile_card.dart';
import 'package:rishtpak/widgets/users_grid.dart';
import 'package:flutter/material.dart';

class ProfileVisitsScreen extends StatefulWidget {
  @override
  _ProfileVisitsScreenState createState() => _ProfileVisitsScreenState();
}

class _ProfileVisitsScreenState extends State<ProfileVisitsScreen> {
  
  // Variables
  final ScrollController _gridViewController = new ScrollController();
  final VisitsApi _visitsApi = VisitsApi();
  late AppLocalizations _i18n;
  List<DocumentSnapshot>? _userVisits;
  late DocumentSnapshot _userLastDoc;
  bool _loadMore = true;

  /// Load more users
  void _loadMoreUsersListener() async {
    _gridViewController.addListener(() {
      if (_gridViewController.position.pixels ==
          _gridViewController.position.maxScrollExtent) {
        /// Load more users
        if (_loadMore) {
          _visitsApi
              .getUserVisits(loadMore: true, userLastDoc: _userLastDoc)
              .then((users) {
            /// Update users list
            if (users.isNotEmpty) {
              _updateUserList(users);
            } else {
              setState(() => _loadMore = false);
            }
            print('load more users: ${users.length}');
          });
        } else {
          print('No more users');
        }
      }
    });
  }

  /// Update list
  void _updateUserList(List<DocumentSnapshot> users) {
    if (mounted) {
      setState(() {
        _userVisits!.addAll(users);
        if (users.isNotEmpty) {
          _userLastDoc = users.last;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _visitsApi.getUserVisits().then((users) {
      // Check result
      if (users.isNotEmpty) {
        if (mounted) {
          setState(() {
            _userVisits = users;
            _userLastDoc = users.last;
          });
        }
      } else {
        setState(() => _userVisits = []);
      }
    });

    /// Listener
    _loadMoreUsersListener();
  }

  @override
  void dispose() {
    _gridViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_i18n.translate("visits")),
      ),
      body: Column(
        children: [
          /// Header Title
          BuildTitle(
            svgIconName: "eye_icon",
            title: _i18n.translate("users_who_visited_you"),
          ),
          /// Matches
          Expanded(child: _showProfiles())
        ],
      ));
  }

  /// Show profiles
  Widget _showProfiles() {
    if (_userVisits == null) {
      return Processing(text: _i18n.translate("loading"));
    } else if (_userVisits!.isEmpty) {
      // No data
      return NoData(svgName: 'eye_icon', text: _i18n.translate("no_visit"));
    } else {
      /// Show users
      return UsersGrid(
        gridViewController: _gridViewController,
        itemCount: _userVisits!.length + 1, /// Workaround for loading more
        itemBuilder: (context, index) {
        /// Validate fake index
        if (index < _userVisits!.length) {
          /// Get user id 
          final userId = _userVisits![index][VISITED_BY_USER_ID];

          /// Load profile
          return FutureBuilder<DocumentSnapshot>(
            future: UserModel().getUser(userId),
            builder: (context, snapshot) {
              /// Chech result
              if (!snapshot.hasData) return LoadingCard();
              /// Get user object
              final User user =
                  User.fromDocument(snapshot.data!.data()!);
              /// Show user card
              return GestureDetector(
                child: ProfileCard(user: user, page: 'require_vip' ,  showLiking: false, isLiked: false, isDisLiked: false,),
                onTap: () {
                  /// Check vip account
                  if (UserModel().user.userIsVerified || UserModel().user.userWallet > 0.0) {
                    /// Go to profile screen - using showDialog to
                    /// prevents reloading getUser FutureBuilder
                    showDialog(context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return ProfileScreen(
                            user: user,
                            hideDislikeButton: true
                          );
                        }
                    );
                    /// Increment user visits an push notification
                    _visitsApi.visitUserProfile(
                      visitedUserId: user.userId,
                      userDeviceToken: user.userDeviceToken,
                      nMessage: "${UserModel().user.userFullname.split(' ')[0]}, "
                          "${_i18n.translate("visited_your_profile_click_and_see")}",
                    );
                  } else {
                      /// Show VIP dialog
                      showDialog(context: context, 
                        builder: (context) => VipDialog());
                  }
                },
              );
            });
          } else {
              return Container();
          }
        },
      );
    }
  }

}
