import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/files/hooks_files/hooks_configurations.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/pages/add_property_v2/add_property_v2.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/add_property.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/properties.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/request_demo.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/settings_page.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/user_related/all_users.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/user_related/manage_profile.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/user_related/user_signin.dart';
import 'package:houzi_package/pages/in_app_purchase/membership_plan_page.dart';
import 'package:houzi_package/pages/main_screen_pages/my_home_page.dart';
import 'package:houzi_package/widgets/dialog_box_widget.dart';
import 'package:houzi_package/widgets/generic_settings_row_widget.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';
import 'package:houzi_package/widgets/user_profile_related/app_info_widget.dart';

class UserRelatedActionsWidget extends StatelessWidget {
  final bool isUserLogged;
  final String userRole;
  final String appName;
  final String appVersion;
  final String paymentStatus;
  final ProfileHook? profileHook;

  const UserRelatedActionsWidget({
    Key? key,
    required this.isUserLogged,
    required this.userRole,
    required this.appName,
    required this.appVersion,
    required this.paymentStatus,
    this.profileHook,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Card(
            shape: AppThemePreferences.roundedCorners(AppThemePreferences.globalRoundedCornersRadius),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  if(isUserLogged)
                    GenericWidgetRow(
                        iconData: AppThemePreferences.manageProfile,
                        text: UtilityMethods.getLocalizedString("manage_profile"),
                        onTap: () => onEditProfileTap(context),
                    ),
                  if(userRole.isNotEmpty && userRole != USER_ROLE_HOUZEZ_BUYER_VALUE)
                    GenericWidgetRow(
                      iconData: AppThemePreferences.propertiesIcon,
                      text: UtilityMethods.getLocalizedString("properties"),
                      onTap: () => onPropertiesTap(context),
                    ),
                  if(SHOW_ADD_PROPERTY && userRole.isNotEmpty && userRole != USER_ROLE_HOUZEZ_BUYER_VALUE)
                    GenericWidgetRow(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
                      iconData: AppThemePreferences.addPropertyIcon,
                      text: UtilityMethods.getLocalizedString("add_property"),
                      removeDecoration: userRole == ROLE_ADMINISTRATOR ? false : true,
                      onTap: () => onAddPropertyTap(context),
                    ),
                  // if(isUserLogged && TOUCH_BASE_PAYMENT_ENABLED_STATUS == membership && paymentStatus == membership)
                  if(isUserLogged && paymentStatus == membership)
                    GenericWidgetRow(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
                      iconData: AppThemePreferences.membership,
                      text: UtilityMethods.getLocalizedString("Membership"),
                      onTap: () => onMembershipTap(context),
                    ),
                  if(userRole.isNotEmpty && userRole == ROLE_ADMINISTRATOR)
                    GenericWidgetRow(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
                      iconData: AppThemePreferences.allUsers,
                      text: UtilityMethods.getLocalizedString("users"),
                      removeDecoration: true,
                      onTap: () => onAllUsersTap(context),
                    ),

                ],
              ),
            ),
          ),

          Container(height: 20.0),
          if(profileHook != null && profileHook!(context).isNotEmpty) Card(
            shape: AppThemePreferences.roundedCorners(AppThemePreferences.globalRoundedCornersRadius),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: profileHook!(context),
              ),
            ),
          ),

          Container(height: 20.0),
          Card(
            shape: AppThemePreferences.roundedCorners(AppThemePreferences.globalRoundedCornersRadius),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  GenericWidgetRow(
                    iconData: AppThemePreferences.settingsIcon,
                    text: UtilityMethods.getLocalizedString("settings"),
                    onTap: () => onSettingsTap(context),
                  ),
                  if(SHOW_DEMO_CONFIGURATIONS) GenericWidgetRow(
                    iconData: AppThemePreferences.requestDemoIcon,
                    text: UtilityMethods.getLocalizedString("request_demo"),
                    onTap: () => onRequestDemoTap(context),
                  ),
                  isUserLogged ? GenericWidgetRow(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
                    iconData: AppThemePreferences.logOutIcon,
                    text: UtilityMethods.getLocalizedString("log_out"),
                    removeDecoration: true,
                    onTap: () => onLogOutTap(context),
                  )
                      : GenericWidgetRow(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
                    iconData: AppThemePreferences.loginIcon,
                    text: UtilityMethods.getLocalizedString("login"),
                    removeDecoration: true,
                    onTap: () => onLogInTap(context),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 20.0),
          AppInfoWidget(
            appName: appName,
            appVersion: appVersion,
          ),
        ],
      ),
    );
  }

  void onEditProfileTap(BuildContext context){
    UtilityMethods.navigateToRoute(
        context: context,
        builder: (context) => ManageProfile(),
    );
  }

  void onPropertiesTap(BuildContext context){
    isUserLogged
        ? UtilityMethods.navigateToRoute(
            context: context,
            builder: (context) => Properties(),
          )
        : onLogInTap(context);
  }

  void onAddPropertyTap(BuildContext context) {
    isUserLogged
        ? UtilityMethods.navigateToRoute(
            context: context,
            builder: (context) {

              return UtilityMethods.navigateToAddPropertyPage();
            },
            // builder: (context) => AddPropertyV2(),
            // builder: (context) => AddProperty(),
          )
        : onLogInTap(context);
  }

  void onAllUsersTap(BuildContext context) {
    UtilityMethods.navigateToRoute(
      context: context,
      builder: (context) => AllUsers(),
    );
  }

  void onMembershipTap(BuildContext context) {
    bool loadUserCurrentMembershipPackage = true;
    Map userPaymentStatusMap = HiveStorageManager.readUserPaymentStatus() ?? {};
    bool hasMembership = userPaymentStatusMap[userHasMembershipKey] ?? false;
    int remainingListing = int.tryParse(userPaymentStatusMap[remainingListingKey]) ?? 0;
    if (remainingListing != -1 && (!hasMembership || remainingListing <= 0)) {
      loadUserCurrentMembershipPackage = false;
    }
    UtilityMethods.navigateToRoute(
      context: context,
      builder: (context) => MembershipPlanPage(fetchMembershipDetail: loadUserCurrentMembershipPackage),
    );
  }

  void onSettingsTap(BuildContext context){
    UtilityMethods.navigateToRoute(
      context: context,
      builder: (context) => HomePageSettings(),
    );
  }

  void onRequestDemoTap(BuildContext context){
    UtilityMethods.navigateToRoute(
      context: context,
      builder: (context) => ContactDeveloper(),
    );
  }

  onLogInTap(BuildContext context) {
    UtilityMethods.navigateToRoute(
      context: context,
      builder: (context) => UserSignIn(
            (String closeOption) {
          if (closeOption == CLOSE) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  onLogOutTap(BuildContext context){
    ShowDialogBoxWidget(
      context,
      title: UtilityMethods.getLocalizedString("log_out"),
      content:
      GenericTextWidget(UtilityMethods.getLocalizedString("are_you_sure_you_want_to_log_out")),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: GenericTextWidget(UtilityMethods.getLocalizedString("cancel")),
        ),
        TextButton(
          child: GenericTextWidget(UtilityMethods.getLocalizedString("yes")),
          onPressed: () {
            Navigator.pop(context);
            UtilityMethods.userLogOut(
              context: context,
              builder: (context) => const MyHomePage(),
            );
          },
        ),
      ],
    );
  }
}
