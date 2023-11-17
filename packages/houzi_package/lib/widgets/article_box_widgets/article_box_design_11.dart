import 'package:flutter/material.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';

import 'article_box_design_01.dart';
import 'article_box_design_02.dart';
import 'article_box_design_03.dart';


Widget articleBox11({
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
      child: Stack(
        children: [
          imageWidget03(context: context, height: 295.0, infoDataMap: infoDataMap, isInMenu: isInMenu, onTap: onTap),
          featuredTag(context: context, infoDataMap: infoDataMap),
          propertyStatusTag(context: context, infoDataMap: infoDataMap),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: containerDecoration(),
              padding: EdgeInsets.only(top: 5,bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  propertyTitleWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 8, 20, 0)),
                  propertyFeaturesWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 8, 20, 0)),
                  // propertyDetailsWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 8, 20, 5)),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Decoration containerDecoration(){
  return BoxDecoration(
    // color: AppThemePreferences().appTheme.cardColor!.withOpacity(0.8),
    color: AppThemePreferences().appTheme.articleDesignItemBackgroundColor!.withOpacity(0.8),
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(10),
    ),
  );
}
