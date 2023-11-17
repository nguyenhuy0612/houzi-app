import 'package:flutter/cupertino.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/hooks_files/hooks_configurations.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/models/article.dart';

import 'article_box_design_01.dart';
import 'article_box_design_02.dart';
import 'article_box_design_03.dart';
import 'article_box_design_04.dart';
import 'article_box_design_05.dart';
import 'article_box_design_06.dart';
import 'article_box_design_07.dart';
import 'article_box_design_08.dart';
import 'article_box_design_09.dart';
import 'article_box_design_10.dart';
import 'article_box_design_11.dart';

class ArticleBoxDesign{

  PropertyItemHook propertyItemHook = HooksConfigurations.propertyItem;

  Widget getArticleBoxDesign(
      {required String design,
      required BuildContext buildContext,
      required String heroId,
      required Article article,
      bool isInMenu = false,
      required Function() onTap}) {
    if (propertyItemHook(buildContext, article) != null) {
      return propertyItemHook(buildContext, article)!;
    }

    String _propertyPrice = "";
    String _firstPrice = "";
    String _secondPrice = "";
    bool _isFeatured = article.propertyInfo!.isFeatured ?? false;
    String _title = UtilityMethods.stripHtmlIfNeeded(article.title!);
    String _imageUrl = article.image ?? "";
    String _address = article.address!.address!;
    String _area = article.features!.landArea!;
    String _areaPostFix = article.features!.landAreaUnit == ""
        ? MEASUREMENT_UNIT_TEXT
        : article.features!.landAreaUnit!;
    String _bedRooms = article.features!.bedrooms!;
    String _bathRooms = article.features!.bathrooms!;
    String _propertyStatus = article.propertyInfo!.propertyStatus ?? "";
    String _propertyLabel = article.propertyInfo!.propertyLabel ?? "";
    String _propertyType = article.propertyInfo!.propertyType ?? "";
    HidePriceHook hidePrice = HooksConfigurations.hidePriceHook;
    bool hide = hidePrice();

    if(!hide) {
      _propertyPrice = article.getCompactPrice();
      _firstPrice = article.getCompactFirstPrice();
      _secondPrice = article.getCompactSecondPrice();
    }

    String _imagePath = "assets/settings/dummy_property_image.jpg";

    Map<String, dynamic> _informationDataMap = {
      AB_HERO_ID : heroId,
      AB_PROPERTY_PRICE : _propertyPrice,
      AB_PROPERTY_FIRST_PRICE : _firstPrice,
      AB_PROPERTY_SECOND_PRICE : _secondPrice,
      AB_IS_FEATURED : _isFeatured,
      AB_TITLE : _title,
      AB_IMAGE_URL : _imageUrl,
      AB_IMAGE_PATH : _imagePath,
      AB_ADDRESS : _address,
      AB_AREA : _area,
      AB_AREA_POST_FIX : _areaPostFix,
      AB_BED_ROOMS : _bedRooms,
      AB_BATH_ROOMS : _bathRooms,
      AB_PROPERTY_STATUS : _propertyStatus,
      AB_PROPERTY_TYPE : _propertyType.toUpperCase(),
      AB_PROPERTY_LABEL : _propertyLabel,
    };

    if (design == DESIGN_01) {
      return articleBox01(context: buildContext, infoDataMap: _informationDataMap, onTap: onTap, isInMenu: isInMenu);
    }
    if (design == DESIGN_02) {
      return articleBox02(context: buildContext, infoDataMap: _informationDataMap, onTap: onTap, isInMenu: isInMenu);
    }
    if (design == DESIGN_03) {
      return articleBox03(context: buildContext, infoDataMap: _informationDataMap, onTap: onTap, isInMenu: isInMenu);
    }
    if (design == DESIGN_04) {
      return articleBox04(context: buildContext, infoDataMap: _informationDataMap, onTap: onTap, isInMenu: isInMenu);
    }
    if (design == DESIGN_05) {
      return articleBox05(context: buildContext, infoDataMap: _informationDataMap, onTap: onTap, isInMenu: isInMenu);
    }
    if (design == DESIGN_06) {
      return articleBox06(context: buildContext, infoDataMap: _informationDataMap, onTap: onTap, isInMenu: isInMenu);
    }
    if (design == DESIGN_07) {
      return articleBox07(context: buildContext, infoDataMap: _informationDataMap, onTap: onTap, isInMenu: isInMenu);
    }
    if (design == DESIGN_08) {
      return articleBox08(context: buildContext, infoDataMap: _informationDataMap, onTap: onTap, isInMenu: isInMenu);
    }
    if (design == DESIGN_09) {
      return articleBox09(context: buildContext, infoDataMap: _informationDataMap, onTap: onTap, isInMenu: isInMenu);
    }
    if (design == DESIGN_10) {
      return articleBox10(context: buildContext, infoDataMap: _informationDataMap, onTap: onTap, isInMenu: isInMenu);
    }
    if (design == DESIGN_11) {
      return articleBox11(context: buildContext, infoDataMap: _informationDataMap, onTap: onTap, isInMenu: isInMenu);
    }

    return articleBox01(context: buildContext, infoDataMap: _informationDataMap, onTap: onTap, isInMenu: isInMenu);
  }

  double getArticleBoxDesignHeight({required String design}){
    if(design == DESIGN_01){
      return 160;
    }
    if(design == DESIGN_02){
      return 295;
    }
    if(design == DESIGN_03){
      return 315;
    }
    if(design == DESIGN_04){
      return 290;
    }
    if(design == DESIGN_05){
      return 295;
    }
    if(design == DESIGN_06){
      return 310;
    }
    if(design == DESIGN_07){
      return 305;
    }
    if(design == DESIGN_08){
      return 250;
    }
    if(design == DESIGN_09){
      return 210;
    }
    if(design == DESIGN_10){
      return 240;
    }
    if(design == DESIGN_11){
      return 240;
    }

    return 160;
  }
}