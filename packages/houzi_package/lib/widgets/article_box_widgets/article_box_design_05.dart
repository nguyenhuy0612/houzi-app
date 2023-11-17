import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';

import '../../files/generic_methods/utility_methods.dart';
import '../generic_text_widget.dart';
import 'article_box_design_01.dart';
import 'article_box_design_02.dart';


Widget articleBox05({
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
            imageWidget02(context: context, height: 170.0, infoDataMap: infoDataMap, isInMenu: isInMenu),
            featuredTag(context: context, infoDataMap: infoDataMap),
            propertyStatusTag(context: context, infoDataMap: infoDataMap),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  propertyDetailsWidget(infoDataMap: infoDataMap),
                  Container(
                    decoration: containerDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        propertyTitleWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 8, 20, 0)),
                        propertyAddressWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 8, 20, 5)),
                        propertyFeaturesWidget(context: context, infoDataMap: infoDataMap),
                      ],
                    ),
                  ),
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
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(15, 0, 15, 10),
}){
  String _propertyType = infoDataMap[AB_PROPERTY_TYPE];
  String _firstPrice = infoDataMap[AB_PROPERTY_FIRST_PRICE];
  String _propertyPrice = infoDataMap[AB_PROPERTY_PRICE];

  return Container(
    padding: padding,
    child: Container(
      constraints: const BoxConstraints(
        minHeight: 30,
        maxHeight: 60,
      ),
      // height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppThemePreferences().appTheme.cardColor!.withOpacity(0.9),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GenericTextWidget(
            _firstPrice != null && _firstPrice.isNotEmpty ? _firstPrice : _propertyPrice,
            style: AppThemePreferences().appTheme.body01TextStyle,
            // style: AppThemePreferences().appTheme.articleBoxPropertyPriceTextStyle,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: GenericTextWidget(
                _propertyType,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppThemePreferences().appTheme.articleBoxPropertyStatusTextStyle,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Decoration containerDecoration(){
  return const BoxDecoration(
    borderRadius: BorderRadius.only(
      bottomRight: Radius.circular(10),
      bottomLeft: Radius.circular(10),
    ),
  );
}

Widget propertyFeaturesWidget({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(10, 5, 10, 8),
}){
  String _bedRooms = infoDataMap[AB_BED_ROOMS];
  String _bathRooms = infoDataMap[AB_BATH_ROOMS];
  String _area = infoDataMap[AB_AREA];
  String _areaPostFix = infoDataMap[AB_AREA_POST_FIX];
  const double paddings = 10.0;

  return Container(
    padding: padding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _bedRooms == null || _bedRooms.isEmpty ? Container() :
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(right: paddings),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AppThemePreferences().appTheme.articleBoxBedIcon!,
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: GenericTextWidget(
                        _bedRooms,
                        style: AppThemePreferences().appTheme.subBodyTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 5, left: paddings, right: paddings),
                child: GenericTextWidget(
                  UtilityMethods.getLocalizedString("bedrooms"),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppThemePreferences().appTheme.subBodyTextStyle,
                ),
              ),
            ],
          ),
        ),
        _bathRooms == null || _bathRooms.isEmpty ? Container() :
        Container(
          padding: _bedRooms != null && _bedRooms.isNotEmpty ? const EdgeInsets.only(left: paddings, right: paddings) : const EdgeInsets.only(left: 0, right: paddings),
          decoration: _bedRooms != null && _bedRooms.isNotEmpty ? AppThemePreferences.dividerDecoration(left: true) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AppThemePreferences().appTheme.articleBoxBathtubIcon!,
                  Container(
                    padding: const EdgeInsets.only(left: 5),
                    child: GenericTextWidget(
                      _bathRooms,

                      style: AppThemePreferences().appTheme.subBodyTextStyle,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 5, left: paddings, right: paddings),
                child: GenericTextWidget(
                  UtilityMethods.getLocalizedString("bathrooms"),
                  textAlign: TextAlign.center,
                  style: AppThemePreferences().appTheme.subBodyTextStyle,
                ),
              ),

            ],
          ),
        ),
        _area == null || _area.isEmpty ? Container() :
        Container(
          padding: (_bedRooms != null && _bedRooms.isNotEmpty) || (_bathRooms != null && _bathRooms.isNotEmpty) ? const EdgeInsets.only(left: paddings, right: paddings) : const EdgeInsets.only(left: 0),
          decoration: (_bedRooms != null && _bedRooms.isNotEmpty) || (_bathRooms != null && _bathRooms.isNotEmpty)
              ? AppThemePreferences.dividerDecoration(left: true) : null,
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AppThemePreferences().appTheme.articleBoxAreaSizeIcon!,
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: GenericTextWidget(
                      _area,

                      style: AppThemePreferences().appTheme.subBodyTextStyle,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 5, left: paddings, right: paddings),
                child: GenericTextWidget(
                  _areaPostFix,
                  overflow: TextOverflow.ellipsis,
                  style: AppThemePreferences().appTheme.subBodyTextStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
