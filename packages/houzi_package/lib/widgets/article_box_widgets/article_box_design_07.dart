import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';

import '../generic_text_widget.dart';
import 'article_box_design_01.dart';
import 'article_box_design_02.dart';

Widget articleBox07({
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
            imageWidget02(context: context, height: 170.0, infoDataMap: infoDataMap, isInMenu: isInMenu),
            featuredTag(context: context, infoDataMap: infoDataMap),
            propertyStatusTag(context: context, infoDataMap: infoDataMap),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  propertyTitleWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 8, 20, 0)),
                  propertyPriceWidget(infoDataMap: infoDataMap),
                  propertyTypeWidget(infoDataMap: infoDataMap),
                  propertyFeaturesWidget02(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 8, 20, 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget propertyPriceWidget({
  required Map<String, dynamic> infoDataMap,
}){
  String _firstPrice = infoDataMap[AB_PROPERTY_FIRST_PRICE];
  String _propertyPrice = infoDataMap[AB_PROPERTY_PRICE];

  return (_firstPrice == null || _firstPrice.isEmpty) && (_propertyPrice == null || _propertyPrice.isEmpty)?
  Container() : Container(
    padding: const EdgeInsets.only(top: 8),
    child: GenericTextWidget(
      _firstPrice != null && _firstPrice.isNotEmpty ? _firstPrice : _propertyPrice,
      style: AppThemePreferences().appTheme.articleBoxPropertyPriceTextStyle,
    ),
  );
}

Widget propertyTypeWidget({
  required Map<String, dynamic> infoDataMap,
}){
  String _propertyType = infoDataMap[AB_PROPERTY_TYPE];

  return _propertyType == null || _propertyType.isEmpty? Container() : Container(
    padding: const EdgeInsets.only(top: 8),
    child: GenericTextWidget(
      _propertyType,
      style: AppThemePreferences().appTheme.articleBoxPropertyStatusTextStyle,
    ),
  );
}

Widget propertyFeaturesWidget02({
  required Map<String, dynamic> infoDataMap,
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(5, 5, 5, 0),
}){
  String _bedRooms = infoDataMap[AB_BED_ROOMS];
  String _bathRooms = infoDataMap[AB_BATH_ROOMS];
  String _area = infoDataMap[AB_AREA];
  String _areaPostFix = infoDataMap[AB_AREA_POST_FIX];

  return Container(
    padding: padding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _bedRooms == null || _bedRooms.isEmpty ? Container() :  Row(
          children: <Widget>[
            AppThemePreferences().appTheme.articleBoxBedIcon!,
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: GenericTextWidget(
                _bedRooms,
                style: AppThemePreferences().appTheme.subBodyTextStyle,
              ),
            ),
          ],
        ),
        _bathRooms == null || _bathRooms.isEmpty ? Container() : Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Row(
            children: <Widget>[
              AppThemePreferences().appTheme.articleBoxBathtubIcon!,
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 8),
                child: GenericTextWidget(
                  _bathRooms,
                  style: AppThemePreferences().appTheme.subBodyTextStyle,
                ),
              ),
            ],
          ),
        ),
        _area == null || _area.isEmpty ? Container() : Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: AppThemePreferences().appTheme.articleBoxAreaSizeIcon,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 5),
              child: GenericTextWidget(
                "$_area $_areaPostFix",
                style: AppThemePreferences().appTheme.subBodyTextStyle,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
