import 'dart:math';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/widgets/article_box_widgets/tags_widgets/featured_tag_widget.dart';
import 'package:houzi_package/widgets/article_box_widgets/tags_widgets/tag_widget.dart';

import 'package:houzi_package/widgets/generic_text_widget.dart';


Widget articleBox01({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
  bool isInMenu = false,
  required Function() onTap,
}) {
  return Stack(
    children: <Widget>[
      Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
        height: 155,//185,
        child: Card(
          color: AppThemePreferences().appTheme.articleDesignItemBackgroundColor,
          shape: AppThemePreferences.roundedCorners(AppThemePreferences.articleDesignRoundedCornersRadius),
          elevation: AppThemePreferences.articleDeignsElevation,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            onTap: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageWidget(context: context,infoDataMap: infoDataMap, isInMenu: isInMenu),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      propertyTitleWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(10,0,10,0)),
                      propertyTagsWidget(context: context, infoDataMap: infoDataMap),
                      propertyAddressWidget(infoDataMap: infoDataMap),
                      propertyFeaturesWidget(infoDataMap: infoDataMap),
                      propertyDetailsWidget(infoDataMap: infoDataMap),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Widget imageWidget({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
  required bool isInMenu,
}){
  String _heroId = infoDataMap[AB_HERO_ID];
  String _imageUrl = infoDataMap[AB_IMAGE_URL];
  String _imagePath = infoDataMap[AB_IMAGE_PATH];
  bool _validURL = UtilityMethods.validateURL(_imageUrl);

  return Padding(
    padding: const EdgeInsets.all(10),
    child: SizedBox(
      height: 150,
      width: 120,
      child: Hero(
        tag: _heroId,
        child: ClipRRect(
          // borderRadius: GenericMethods.isRTL(context)? const BorderRadius.only(topRight:  Radius.circular(8.0), bottomRight: Radius.circular(8.0)):
          // const BorderRadius.only(topLeft: Radius.circular(8.0), bottomLeft: Radius.circular(8.0)),
          borderRadius: new BorderRadius.circular(8.0),
          // borderRadius:BorderRadius.only(topLeft: Radius.circular(8.0), bottomLeft: Radius.circular(8.0)),
          child: isInMenu ? Image.asset(
            _imagePath,
            fit: BoxFit.cover,
          ) : !_validURL ? errorWidget() : FancyShimmerImage(
            imageUrl: _imageUrl,
            boxFit: BoxFit.cover,
            shimmerBaseColor: AppThemePreferences().appTheme.shimmerEffectBaseColor,
            shimmerHighlightColor: AppThemePreferences().appTheme.shimmerEffectHighLightColor,
            errorWidget: errorWidget(),
          ),
        ),
      ),
    ),
  );
}

Widget propertyTagsWidget({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
}) {
  List tagsList = [];
  EdgeInsetsGeometry padding = EdgeInsets.only(
      right: UtilityMethods.isRTL(context) ? 0 : 5,
      left: UtilityMethods.isRTL(context) ? 5 : 0,
  );

  if (infoDataMap[AB_IS_FEATURED]) {
    tagsList.add(infoDataMap[AB_IS_FEATURED]);
  }
  if (infoDataMap[AB_PROPERTY_STATUS].isNotEmpty) {
    tagsList.add(infoDataMap[AB_PROPERTY_STATUS]);
  }
  if (infoDataMap[AB_PROPERTY_LABEL].isNotEmpty) {
    tagsList.add(infoDataMap[AB_PROPERTY_LABEL]);
  }

  if (tagsList.length == 3) {
    tagsList.removeLast();
  }

  return tagsList.isEmpty
      ? Container()
      : Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: tagsList.map(
              (item) {
                if (item is bool) {
                  return Container(
                    padding: padding,
                    alignment: Alignment.topLeft,
                    child: FeaturedTagWidget(),
                  );
                }

                return Padding(
                  padding: padding,
                  child: TagWidget(label: item),
                );
              },
            ).toList(),
          ),
        );
}

Widget propertyTitleWidget({
  required Map<String, dynamic> infoDataMap,
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 10.0),
  // EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(10, 0, 10, 0),
}){
  String _title = infoDataMap[AB_TITLE];
  return Padding(
    padding: padding,
    child: GenericTextWidget(
      _title,
      maxLines: 1,
      overflow: TextOverflow.clip,
      strutStyle: const StrutStyle(
        forceStrutHeight: true,
        height: 1.7
      ),
      style: AppThemePreferences().appTheme.titleTextStyle,
    ),
  );
}

Widget propertyAddressWidget({
  required Map<String, dynamic> infoDataMap,
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 10.0),
  // EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(10, 0, 10, 0),
}){
  String _address = infoDataMap[AB_ADDRESS];
  return Container(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        AppThemePreferences().appTheme.articleBoxLocationIcon!,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: GenericTextWidget(
              _address,
              textDirection: TextDirection.ltr,
              maxLines: 1,
              strutStyle: const StrutStyle(forceStrutHeight: true),
              overflow: TextOverflow.clip,
              style: AppThemePreferences().appTheme.subBodyTextStyle,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget propertyFeaturesWidget({
  required Map<String, dynamic> infoDataMap,
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 10.0),
  // EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(10, 0, 10, 0),
}){
  String _bedRooms = infoDataMap[AB_BED_ROOMS];
  String _bathRooms = infoDataMap[AB_BATH_ROOMS];
  String _area = infoDataMap[AB_AREA];
  String _areaPostFix = infoDataMap[AB_AREA_POST_FIX];

  return Container(
    padding: padding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bedRooms == null || _bedRooms.isEmpty ? Container() :  Row(
            children: <Widget>[
              AppThemePreferences().appTheme.articleBoxBedIcon!,
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: GenericTextWidget(
                  _bedRooms,
                  strutStyle: const StrutStyle(forceStrutHeight: true),
                  style: AppThemePreferences().appTheme.subBodyTextStyle,
                ),
              ),
            ],
        ),
        _bathRooms == null || _bathRooms.isEmpty ? Container() : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          // padding: const EdgeInsets.only(left: 15),
          child: Row(
            children: <Widget>[
              AppThemePreferences().appTheme.articleBoxBathtubIcon!,
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: GenericTextWidget(
                  _bathRooms,
                  strutStyle: const StrutStyle(forceStrutHeight: true),
                  style: AppThemePreferences().appTheme.subBodyTextStyle,
                ),
              ),
            ],
          ),
        ),
        _area.isEmpty
            ? Container()
            : Expanded(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: AppThemePreferences()
                            .appTheme
                            .articleBoxAreaSizeIcon,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: GenericTextWidget(
                        "$_area $_areaPostFix",
                        strutStyle: const StrutStyle(forceStrutHeight: true),
                        style: AppThemePreferences().appTheme.subBodyTextStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
      ],
    ),
  );
}

Widget propertyDetailsWidget({
  required Map<String, dynamic> infoDataMap,
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 10.0),
  // EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(10, 0, 10, 0),
}){
  String _propertyType = infoDataMap[AB_PROPERTY_TYPE];
  String _firstPrice = infoDataMap[AB_PROPERTY_FIRST_PRICE];
  String _propertyPrice = infoDataMap[AB_PROPERTY_PRICE];

  return Container(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: GenericTextWidget(
              _propertyType,
              strutStyle: const StrutStyle(forceStrutHeight: true),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: AppThemePreferences().appTheme.articleBoxPropertyStatusTextStyle,
            ),
          ),
        ),
        GenericTextWidget(
          _firstPrice != null && _firstPrice.isNotEmpty ? _firstPrice : _propertyPrice,
          style: AppThemePreferences().appTheme.articleBoxPropertyPriceTextStyle,
        ),
      ],
    ),
  );
}

Widget errorWidget(){
  return Container(
    color: AppThemePreferences().appTheme.shimmerEffectErrorWidgetBackgroundColor,
    child: Center(child: AppThemePreferences().appTheme.shimmerEffectImageErrorIcon),
  );
}