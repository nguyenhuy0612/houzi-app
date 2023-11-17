import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/user_related/user_signin.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';

class HomeScreenDrawerListTile extends StatefulWidget {
  final String title;
  final String selectedHome;
  final String sectionType;
  final IconData iconData;
  final WidgetBuilder? builder;
  final bool? checkLogin;
  final bool? isUserLoggedIn;
  final bool? fromHook;
  final GestureTapCallback? logOutConfirm;
  final VoidCallback? onTap;

  const HomeScreenDrawerListTile({ 
    Key? key,
    required this.title,
    required this.selectedHome,
    required this.sectionType,
    required this.iconData,
    this.builder,
    this.checkLogin = false,
    this.fromHook = false,
    this.isUserLoggedIn = false,
    this.logOutConfirm,
    this.onTap,
  }) : super(key: key);

  @override
  State<HomeScreenDrawerListTile> createState() => _HomeScreenListTileState();
}

class _HomeScreenListTileState extends State<HomeScreenDrawerListTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: ListTile(
        // selected: widget.sectionType == homeSectionType ? true : false,
        // selectedTileColor: widget.sectionType == homeSectionType
        //     ? AppThemePreferences().appTheme.primaryColor.withOpacity(0.1)
        //     : null,

        // selected: widget.title == _selectedDrawerOption ? true : false,
        // selectedTileColor: widget.title == _selectedDrawerOption
        //     ? AppThemePreferences().appTheme.primaryColor.withOpacity(0.1)
        //     : null,
        selected: widget.sectionType == widget.selectedHome
            || widget.sectionType == homeSectionType ? true : false,
        selectedTileColor: widget.sectionType == widget.selectedHome
            || widget.sectionType == homeSectionType
            ? AppThemePreferences().appTheme.primaryColor!.withOpacity(0.1)
            : null,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        title: GenericTextWidget(
          widget.title,
          style: TextStyle(
              fontWeight: AppThemePreferences.drawerMenuTextFontWeight,
              fontSize: AppThemePreferences.drawerMenuTextFontSize,
              // color: widget.title == _selectedDrawerOption
              //     ? AppThemePreferences().appTheme.primaryColor
              //     : AppThemePreferences().appTheme.normalTextColor),
              // color: widget.sectionType == homeSectionType
              //     ? AppThemePreferences().appTheme.primaryColor
              //     : AppThemePreferences().appTheme.normalTextColor),
              color: widget.sectionType == widget.selectedHome
                  || widget.sectionType == homeSectionType
                  ? AppThemePreferences().appTheme.primaryColor
                  : AppThemePreferences().appTheme.normalTextColor),
        ),
        leading: Icon(widget.iconData,
            // color: widget.title == _selectedDrawerOption
            //     ? AppThemePreferences().appTheme.primaryColor
            //     : AppThemePreferences().appTheme.normalTextColor),
            // color: widget.sectionType == homeSectionType
            //     ? AppThemePreferences().appTheme.primaryColor
            //     : AppThemePreferences().appTheme.normalTextColor),
            color:
            widget.sectionType == widget.selectedHome
                || widget.sectionType == homeSectionType
                ? AppThemePreferences().appTheme.primaryColor
                : AppThemePreferences().appTheme.normalTextColor),

        onTap: widget.fromHook ?? false
            ? () {
          onTapFromHook(
              context,
              widget.checkLogin ?? false,
              widget.onTap,
              widget.isUserLoggedIn ?? false,
          );
        }
            : widget.logOutConfirm ?? widget.onTap ??
                () {
              // setState(() {
              //   _selectedDrawerOption = widget.title;
              // });
              //Navigator.pop(context);
              if (widget.builder != null) {
                // if(widget.sectionType != homeSectionType && builder != null){
                if (widget.checkLogin ?? false) {
                  if (widget.isUserLoggedIn ?? false) {
                    navigateToRoute(context, widget.builder!);
                  } else {
                    navigateToRoute(
                        context,
                            (context) => UserSignIn(
                              (String closeOption) {
                            if (closeOption == CLOSE) {
                              Navigator.pop(context);
                            }
                          },
                        ));
                  }
                } else {
                  navigateToRoute(context, widget.builder!);
                }
              }
            },
      ),
    );
  }

  void navigateToRoute(BuildContext context, WidgetBuilder builder){
    UtilityMethods.navigateToRoute(context: context, builder: builder);
  }

  onTapFromHook(BuildContext context, bool checkLogin, VoidCallback? onTap, bool isUserLoggedIn) {
    if (checkLogin) {
      if (isUserLoggedIn) {
        onTap!();
      } else {
        navigateToRoute(
          context,
              (context) => UserSignIn((String closeOption) {
            if (closeOption == CLOSE) {
              Navigator.pop(context);
            }
          },
          ),
        );
      }
    } else {
      onTap!();
    }
  }
}
