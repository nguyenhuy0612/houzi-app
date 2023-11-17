import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String appBarTitle;
  final void Function()? onBackPressed;
  final double? elevation;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double? toolbarHeight;
  final bool automaticallyImplyLeading;
  final double? leadingWidth;

  AppBarWidget({
  Key? key,
    required this.appBarTitle,
    this.onBackPressed,
    this.elevation = 1.0,
    this.actions,
    this.bottom,
    this.toolbarHeight = kToolbarHeight,
    this.automaticallyImplyLeading = true,
    this.leadingWidth = 56.0,
  }) : super(key: key);

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight((toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0));

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppThemePreferences().appTheme.genericStatusBarColor,
          statusBarIconBrightness: AppThemePreferences().appTheme.genericStatusBarIconBrightness,
          statusBarBrightness:AppThemePreferences().appTheme.statusBarBrightness
      ),
      backgroundColor: AppThemePreferences().appTheme.primaryColor,
      leading: widget.automaticallyImplyLeading
          ? IconButton(
              icon: Icon(AppThemePreferences.arrowBackIcon),
              color: AppThemePreferences().appTheme.genericAppBarIconsColor,
              onPressed: widget.onBackPressed ??
                  () => onBackPressedFunc(context),
            )
          : Container(),
      leadingWidth: widget.automaticallyImplyLeading ? widget.leadingWidth : 0.0,
      title: GenericTextWidget(
        widget.appBarTitle,
        strutStyle: const StrutStyle(height: 1),
        style: AppThemePreferences().appTheme.genericAppBarTextStyle,
      ),
      actions: widget.actions,
      bottom: widget.bottom,
      toolbarHeight: widget.toolbarHeight,
      elevation: widget.elevation != AppThemePreferences.appBarWidgetElevation
          ? widget.elevation
          : AppThemePreferences.appBarWidgetElevation,
    );
  }
}

void onBackPressedFunc(BuildContext context) {
  Navigator.of(context).pop();
}
