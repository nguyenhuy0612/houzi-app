import 'package:flutter/material.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';

import 'article_box_design_01.dart';
import 'article_box_design_02.dart';
import 'article_box_design_07.dart';

Widget articleBox08({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
  bool isInMenu = false,
  required Function() onTap
}){

  return Container(
    padding: const EdgeInsets.only(bottom: 7.0),
    child: Card(
      color: AppThemePreferences().appTheme.articleDesignItemBackgroundColor,
      shape: AppThemePreferences.roundedCorners(AppThemePreferences.articleDesignRoundedCornersRadius),
      elevation: AppThemePreferences.articleDeignsElevation,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        onTap: onTap,
        child: Stack(
          children: [
            imageWidget02(context: context, height: 165.0, infoDataMap: infoDataMap, isInMenu: isInMenu),
            featuredTag(context: context, infoDataMap: infoDataMap),
            propertyStatusTag(context: context, infoDataMap: infoDataMap),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  propertyTitleWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 10, 20, 0)),
                  propertyDetailsWidget(infoDataMap: infoDataMap),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget propertyDetailsWidget({
  required Map<String, dynamic> infoDataMap,
}){
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        propertyFeaturesWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(0, 0, 0, 0)),
        propertyPriceWidget(infoDataMap: infoDataMap),
      ],
    ),
  );
}
