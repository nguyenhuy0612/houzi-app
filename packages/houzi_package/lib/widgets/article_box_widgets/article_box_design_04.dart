import 'package:flutter/material.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';

import 'article_box_design_01.dart';
import 'article_box_design_02.dart';


Widget articleBox04({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
  bool isInMenu = false,
  required Function() onTap,
}){

  return Container(
    padding: const EdgeInsets.only(bottom: 7),
    child: Card(
      color: AppThemePreferences().appTheme.articleDesignItemBackgroundColor,
      shape: AppThemePreferences.roundedCorners(AppThemePreferences.articleDesignRoundedCornersRadius),
      elevation: AppThemePreferences.articleDeignsElevation,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              children: [
                imageWidget02(context: context, height: 180.0, infoDataMap: infoDataMap, isInMenu: isInMenu),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    propertyTitleWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 10, 20, 0)),
                    propertyFeaturesWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 8, 20, 0)),
                    propertyDetailsWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 8, 20, 5)),
                  ],
                ),
              ],
            ),
            featuredTag(context: context, infoDataMap: infoDataMap),
            propertyStatusTag(context: context, infoDataMap: infoDataMap),
          ],
        ),
      ),
    ),
  );
}
