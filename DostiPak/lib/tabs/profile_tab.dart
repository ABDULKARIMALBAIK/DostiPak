import 'package:flutter/material.dart';
import 'package:rishtpak/models/user_model.dart';
import 'package:rishtpak/widgets/app_section_card.dart';
import 'package:rishtpak/widgets/delete_account_button.dart';
import 'package:rishtpak/widgets/profile_basic_info_card.dart';
import 'package:rishtpak/widgets/profile_statistics_card.dart';
import 'package:rishtpak/widgets/sign_out_button_card.dart';
import 'package:rishtpak/widgets/vip_account_card.dart';
import 'package:scoped_model/scoped_model.dart';

class ProfileTab extends StatelessWidget {
  // Variables

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: ScopedModelDescendant<UserModel>(
          builder: (context, child, userModel) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Basic profile info
            ProfileBasicInfoCard(),

            SizedBox(height: 10),

            /// Profile Statistics Card
            ProfileStatisticsCard(),

            SizedBox(height: 10),

            /// Show VIP dialog
            if(UserModel().user.userGender != "affiliate")  //Only Male and female
              VipAccountCard(),

            SizedBox(height: 10),

            /// App Section Card
            AppSectionCard(),

            SizedBox(height: 20),

            /// Sign out button card
            SignOutButtonCard(),

            SizedBox(height: 25),
            
            /// Delete Account Button
            DeleteAccountButton(),

            SizedBox(height: 25),

          ],
        );
      }),
    );
  }
}
