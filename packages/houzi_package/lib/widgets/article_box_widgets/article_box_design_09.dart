import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../files/app_preferences/app_preferences.dart';
import '../generic_text_widget.dart';
import 'article_box_design_02.dart';

Widget articleBox09({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
  bool isInMenu = false,
  required Function() onTap
}){
  return isInMenu ? Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      design(context: context, infoDataMap: infoDataMap, isInMenu: isInMenu, onTap: onTap),
      design(context: context, infoDataMap: infoDataMap, isInMenu: isInMenu, onTap: onTap),
    ],
  ) : design(context: context, infoDataMap: infoDataMap, isInMenu: isInMenu, onTap: onTap);
}

Widget design({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
  bool isInMenu = false,
  required Function() onTap
}){
  double containerHeight = MediaQuery.of(context).size.width * 0.45;
  double imageHeight = MediaQuery.of(context).size.height * 0.17;
  double imageWidth = double.infinity;
  // double imageWidth = MediaQuery.of(context).size.width * 0.45;

  return ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: 160,
    ),
    child: Container(
      height: containerHeight,
      child: Card(
        color: AppThemePreferences().appTheme.articleDesignItemBackgroundColor,
        shape: AppThemePreferences.roundedCorners(AppThemePreferences.articleDesignRoundedCornersRadius),
        elevation: AppThemePreferences.articleDeignsElevation,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          onTap: onTap,
          child: Stack(
            children: [
              imageWidget02(context: context, height: imageHeight, //100.0,
                  // height: 130.0,
                  width: imageWidth, //160,
                  infoDataMap: infoDataMap, isInMenu: isInMenu),
              // featuredTag(context: context, infoDataMap: infoDataMap),
              // propertyStatusTag(context: context, infoDataMap: infoDataMap),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    propertyTitleWidget(infoDataMap: infoDataMap, padding: EdgeInsets.fromLTRB(10, 10, 10, 0)),
                    propertyDetailsWidget(infoDataMap: infoDataMap),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget propertyTitleWidget({
  required Map<String, dynamic> infoDataMap,
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(5, 5, 10, 0),
}){
  String _title = infoDataMap[AB_TITLE];
  return Container(
    padding: padding,
    child: GenericTextWidget(
      _title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      strutStyle: StrutStyle(
          forceStrutHeight: true
      ),
      // style: AppThemePreferences().appTheme.titleTextStyle,
      style: titleStyle(),
    ),
  );
}

Widget propertyDetailsWidget({
  required Map<String, dynamic> infoDataMap,
}){
  return Container(
    padding: EdgeInsets.fromLTRB(10, 3, 10, 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        propertyPriceWidget(infoDataMap: infoDataMap),
        propertyFeaturesWidget(infoDataMap: infoDataMap, padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
      ],
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
    // padding: EdgeInsets.only(top: 3),
    child: GenericTextWidget(
      _firstPrice != null && _firstPrice.isNotEmpty ? _firstPrice : _propertyPrice,
      // style: AppThemePreferences().appTheme.articleBoxPropertyPriceTextStyle,
      style: priceStyle(),
    ),
  );
}

Widget propertyFeaturesWidget({
  required Map<String, dynamic> infoDataMap,
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(5, 5, 5, 0),
}){
  String _bedRooms = infoDataMap[AB_BED_ROOMS];
  String _bathRooms = infoDataMap[AB_BATH_ROOMS];

  return Container(
    padding: padding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bedRooms == null || _bedRooms.isEmpty ? Container() :  Row(
          children: <Widget>[
            AppThemePreferences().appTheme.articleBoxBedIcon!,
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: GenericTextWidget(
                _bedRooms,
                strutStyle: StrutStyle(forceStrutHeight: true),
                // style: AppThemePreferences().appTheme.subBodyTextStyle,
                style: featuresStyle(),
              ),
            ),
          ],
        ),
        _bathRooms == null || _bathRooms.isEmpty ? Container() : Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Row(
            children: <Widget>[
              AppThemePreferences().appTheme.articleBoxBathtubIcon!,
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: GenericTextWidget(
                  _bathRooms,
                  strutStyle: StrutStyle(forceStrutHeight: true),
                  // style: AppThemePreferences().appTheme.subBodyTextStyle,
                  style: featuresStyle(),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

TextStyle featuresStyle(){
  return TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );
}

TextStyle priceStyle(){
  return TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w300,
  );
}
TextStyle titleStyle(){
  return TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}