import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/widgets/article_box_widgets/tags_widgets/featured_tag_widget.dart';
import 'package:houzi_package/widgets/article_box_widgets/tags_widgets/tag_widget.dart';

import '../shimmer_effect_error_widget.dart';
import 'article_box_design_01.dart';

Widget articleBox02({
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
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              children: [
                imageWidget02(context: context, infoDataMap: infoDataMap, isInMenu: isInMenu),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    propertyTitleWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 8, 20, 0)),
                    propertyAddressWidget(infoDataMap: infoDataMap, padding: const EdgeInsets.fromLTRB(20, 8, 20, 0)),
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

Widget imageWidget02({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
  bool isInMenu = false,
  double height = 160.0,
  double width = double.infinity,
}){
  String _heroId = infoDataMap[AB_HERO_ID];
  String _imageUrl = infoDataMap[AB_IMAGE_URL];
  String _imagePath = infoDataMap[AB_IMAGE_PATH];
  bool _validURL = UtilityMethods.validateURL(_imageUrl);

  return SizedBox(
    height: height,
    width: width,
    // width: MediaQuery.of(context).size.width,
    child: Hero(
      tag: _heroId,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: isInMenu ? Image.asset(
          _imagePath,
          fit: BoxFit.cover,
        ) : !_validURL ? ShimmerEffectErrorWidget(iconSize: 100) : FancyShimmerImage(
          imageUrl: _imageUrl,
          boxFit: BoxFit.cover,
          shimmerBaseColor: AppThemePreferences().appTheme.shimmerEffectBaseColor,
          shimmerHighlightColor: AppThemePreferences().appTheme.shimmerEffectHighLightColor,
          errorWidget: ShimmerEffectErrorWidget(iconSize: 100),
        ),
      ),
    ),
  );
}

Widget featuredTag({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
}){
  bool isFeatured = infoDataMap[AB_IS_FEATURED];
  return Positioned(
    top: 10,
    left: 15,
    child: isFeatured ? Container(
      alignment: Alignment.topLeft,
      child: FeaturedTagWidget(),
    ) : Container(),
  );
}

Widget propertyStatusTag({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
}){
  String _propertyStatus = infoDataMap[AB_PROPERTY_STATUS];
  return Positioned(
    top: 10,
    right: 15,
    child: _propertyStatus == null || _propertyStatus.isEmpty ? Container() : Container(
      alignment: Alignment.topRight,
      child: TagWidget(label: UtilityMethods.getLocalizedString(_propertyStatus).toUpperCase()),
    ),
  );
}
