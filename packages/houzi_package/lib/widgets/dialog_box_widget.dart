import 'package:flutter/material.dart';
import 'generic_text_widget.dart';

Future ShowDialogBoxWidget(
  BuildContext context, {
  required String title,
  TextStyle? style,
  Widget? content,
  List<Widget>? actions,
  EdgeInsetsGeometry actionsPadding = const EdgeInsets.all(0.0),
  double elevation = 5.0,
  TextAlign textAlign = TextAlign.start,
}){
  return showDialog(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: GenericTextWidget(
            title,
            textAlign: textAlign,
            style: style,
          ),
          content: content,
          actionsPadding: actionsPadding,
          elevation: elevation,
          actions: actions,
        );
      });
}