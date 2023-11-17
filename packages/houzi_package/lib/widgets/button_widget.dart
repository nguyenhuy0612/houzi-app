import 'package:flutter/material.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Widget? icon;
  final Color? color;
  final double? fontSize;
  final void Function() onPressed;
  final double? buttonHeight;
  final double buttonWidth;
  final bool? iconOnRightSide;
  final bool? centeredContent;
  final ButtonStyle? buttonStyle;

  const ButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.icon,
    this.color,
    this.fontSize = 18.0,
    this.buttonHeight = 50.0,
    this.buttonWidth = double.infinity,
    this.iconOnRightSide = false,
    this.centeredContent = false,
    this.buttonStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconOnRightSide! ? Container() : showIcon(icon),
            centeredContent!
                ? ButtonContent(icon: icon, text: text, fontSize: fontSize!, rightIcon: iconOnRightSide!, textColor: textColor)
                : Expanded(child: ButtonContent(icon: icon, text: text, fontSize: fontSize!, rightIcon: iconOnRightSide!, textColor: textColor)),
            iconOnRightSide! ? showIcon(icon) : Container(),
          ],
        ),

        style: buttonStyle ?? ElevatedButton.styleFrom(
          elevation: 0.0, backgroundColor: color ?? AppThemePreferences.actionButtonBackgroundColor,
          // primary: color != null ? color : AppThemePreferences().current.primaryColor,
        ),
      ),
    );
  }
}

Widget showIcon(Widget? icon){
  if(icon == null){
    return Container();
  }
  return icon;
}

class ButtonContent extends StatelessWidget {
  final Widget? icon;
  final String text;
  final double? fontSize;
  final bool? rightIcon;
  final Color? textColor;

  const ButtonContent({
    Key? key,
    required this.text,
    this.icon,
    this.fontSize,
    this.rightIcon = false,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: icon == null
          ? const EdgeInsets.only(left: 0.0)
          : rightIcon!
          ? const EdgeInsets.only(right: 10.0)
          : const EdgeInsets.only(left: 10.0),
      child: GenericTextWidget(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor ?? AppThemePreferences.filledButtonTextColor,
          fontSize: fontSize,
        ),
      ),
    );
  }
}