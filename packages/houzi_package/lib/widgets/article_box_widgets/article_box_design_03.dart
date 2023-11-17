import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';

import '../shimmer_effect_error_widget.dart';


import 'article_box_design_01.dart';
import 'article_box_design_02.dart';

Widget articleBox03({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
  bool isInMenu = false,
  required Function() onTap,
}){

  return Container(
    padding: const EdgeInsets.only(bottom: 7.0),
    child: Card(
      color: AppThemePreferences().appTheme.articleDesignItemBackgroundColor,
      shape: AppThemePreferences.roundedCorners(AppThemePreferences.articleDesignRoundedCornersRadius),
      elevation: AppThemePreferences.articleDeignsElevation,
      child: Stack(
        children: [
          imageWidget03(context: context, infoDataMap: infoDataMap, isInMenu: isInMenu, onTap: onTap),
          featuredTag(context: context, infoDataMap: infoDataMap),
          propertyStatusTag(context: context, infoDataMap: infoDataMap),
          Positioned(
            bottom: 0.0, left: 0.0, right: 0.0,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(10),),
              onTap: onTap,
              child: Container(
                decoration: containerDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    propertyTitleWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 10, 20, 0)),
                    propertyAddressWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 8, 20, 0)),
                    propertyFeaturesWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 8, 20, 0)),
                    propertyDetailsWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 5, 20, 5)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget imageWidget03({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
  bool isInMenu = false,
  required Function() onTap,
  double? height,
}){
  String _heroId = infoDataMap[AB_HERO_ID];
  String _imageUrl = infoDataMap[AB_IMAGE_URL];
  String _imagePath = infoDataMap[AB_IMAGE_PATH];
  bool _validURL = UtilityMethods.validateURL(_imageUrl);

  return SizedBox(
    height: height,
    width: MediaQuery.of(context).size.width,
    child: Hero(
      tag: _heroId,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: isInMenu ? Image.asset(
          _imagePath,
          fit: BoxFit.cover,
        ) : Stack(
          fit: StackFit.expand,
          children: [
            !_validURL ? ShimmerEffectErrorWidget(iconSize: 100) : FancyShimmerImage(
              imageUrl: _imageUrl,
              boxFit: BoxFit.cover,
              shimmerBaseColor: AppThemePreferences().appTheme.shimmerEffectBaseColor,
              shimmerHighlightColor: AppThemePreferences().appTheme.shimmerEffectHighLightColor,
              errorWidget: ShimmerEffectErrorWidget(iconSize: 100),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  onTap: onTap,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Decoration containerDecoration(){
  return BoxDecoration(
    // color: AppThemePreferences().appTheme.cardColor!.withOpacity(0.8),
      color: AppThemePreferences().appTheme.articleDesignItemBackgroundColor!.withOpacity(0.8),
    borderRadius: const BorderRadius.only(
      bottomRight: Radius.circular(10),
      bottomLeft: Radius.circular(10),
    ),
  );
}