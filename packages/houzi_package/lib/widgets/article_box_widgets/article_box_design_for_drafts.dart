import 'dart:io';

import 'package:flutter/material.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/hooks_files/hooks_configurations.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/models/article.dart';

import 'package:houzi_package/widgets/button_widget.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';

Widget draftPropertiesArticleBoxDesign({
  required BuildContext context,
  required String heroID,
  required Article article,
  required Function() onTap,
  required Function() onActionButtonTap,
}){
  String _title = UtilityMethods.stripHtmlIfNeeded(article.title!);

  return InkWell(
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    onTap: onTap,
    child: Container(
      height: 250, //270
      padding: const EdgeInsets.only(bottom: 7.0 , left: 5.0 , right: 5.0 , top: 3.0),
      child: Card(
        color: AppThemePreferences().appTheme.articleDesignItemBackgroundColor,
        shape: AppThemePreferences.roundedCorners(AppThemePreferences.articleDesignRoundedCornersRadius),
        elevation: AppThemePreferences.articleDeignsElevation,
        child: Stack(
          children: <Widget>[
            imageWidget(heroId: heroID, imagePath: article.image!),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: titleAndButtonRowWidget(context: context, title: _title, onButtonTap: onActionButtonTap),
              // child: Column(
              //   // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     titleAndButtonRowWidget(context: context, title: _title, onButtonTap: onActionButtonTap),
              //     // featuresAndPriceRowWidget(article: article),
              //   ],
              // ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget imageWidget({
  required String heroId,
  required String imagePath,
}) {
  bool _validURL = imagePath != null && imagePath.isNotEmpty ? true : false;
  return SizedBox(
    height: 165,
    width: double.infinity,
    // width: MediaQuery.of(context).size.width,
    child: Hero(
      tag: heroId,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: !_validURL ? errorWidget() : Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        ),

          // Image.file(
          //   File(item[PROPERTY_MEDIA_IMAGE_PATH]),
          //   fit: BoxFit.cover,
          //   width: AppThemePreferences.propertyMediaGridViewImageWidth,
          //   height: AppThemePreferences.propertyMediaGridViewImageHeight,
          // )
        // child: !_validURL ? errorWidget() : Image.asset(
        //   imagePath,
        //   fit: BoxFit.cover,
        // ),
      ),
    ),
  );
}

Widget errorWidget(){
  return Container(
    color: AppThemePreferences().appTheme.shimmerEffectErrorWidgetBackgroundColor,
    child: Center(child: AppThemePreferences().appTheme.shimmerEffectImageErrorIcon),
  );
}

Widget titleAndButtonRowWidget({
  required BuildContext context,
  required String title,
  required Function() onButtonTap,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: titleWidget(title: title),
        ),
        Expanded(
          flex: 2,
          child: ButtonWidget(
            buttonHeight: 40,
            centeredContent: true,
            iconOnRightSide: true,
            icon: Icon(
              AppThemePreferences.dropDownArrowIcon,
              color: AppThemePreferences.filledButtonIconColor,
            ),
            text: UtilityMethods.getLocalizedString("action"),
            onPressed: onButtonTap,
          ),
        ),
      ],
    ),
  );
}

Widget featuresAndPriceRowWidget({
  required Article article,
}){
  return Container(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        propertyFeaturesWidget(item: article, padding: const EdgeInsets.fromLTRB(0, 0, 0, 0)),
        priceWidget(item: article),
      ],
    ),
  );
}

Widget titleWidget({
  required String title
}){
  return GenericTextWidget(
    title,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: AppThemePreferences().appTheme.titleTextStyle,
  );
}

Widget priceWidget({
  required Article item,
}){
  String finalPrice = "";

  HidePriceHook hidePrice = HooksConfigurations.hidePriceHook;
  bool hide = hidePrice();
  if(!hide) {
    finalPrice = item.getCompactPrice();
  }

  return GenericTextWidget(
    finalPrice,
    style: AppThemePreferences().appTheme.articleBoxPropertyPriceTextStyle,
  );
}

Widget propertyFeaturesWidget({
  required Article item,
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(5, 5, 5, 0),
}){

  String _area = item.features!.landArea!;
  String _areaPostFix = item.features!.landAreaUnit!;
  String _bedRooms = item.features!.bedrooms!;
  String _bathRooms = item.features!.bathrooms!;

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
                style: AppThemePreferences().appTheme.subBodyTextStyle,
              ),
            ),
          ],
        ),
        _bathRooms == null || _bathRooms.isEmpty ? Container() : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Row(
            children: <Widget>[
              AppThemePreferences().appTheme.articleBoxBathtubIcon!,
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
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
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
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