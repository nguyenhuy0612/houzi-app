import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';

import '../../common/constants.dart';
import '../shimmer_effect_error_widget.dart';

Widget articleBox10({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
  bool isInMenu = false,
  required Function() onTap,
})  {
  return Container(
    padding: const EdgeInsets.only(bottom: 7.0),
    child: Card(
      color: AppThemePreferences().appTheme.articleDesignItemBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: AppThemePreferences.articleDeignsElevation,
      child: Stack(
        children: [
          // infoDataMap[AB_PROPERTY_VIDEO_AD_URL] != null && infoDataMap[AB_PROPERTY_VIDEO_AD_URL].isNotEmpty
          //     ? VideoPlayerWidget(height: 240.0, infoDataMap: infoDataMap)
          //     :
        _imageWidget02(
                  context: context,
                  height: 240.0,
                  infoDataMap: infoDataMap,
                  isInMenu: isInMenu,
            onTap : onTap
                )
        ],
      ),
    ),
  );
}

Widget _imageWidget02({
  required BuildContext context,
  required Map<String, dynamic> infoDataMap,
  bool isInMenu = false,
  double height = 160.0,
  double width = double.infinity,
  required Function() onTap,
}){
  String _imageUrl = infoDataMap[AB_IMAGE_URL];

  return GestureDetector(
    onTap: onTap,
    child: SizedBox(
      height: height,
      width: width,
      // width: MediaQuery.of(context).size.width,
      child: ClipRRect(
        borderRadius:
        BorderRadius.all(Radius.circular(10)),
        child: FancyShimmerImage(
            imageUrl: _imageUrl,
            boxFit: BoxFit.cover,
            boxDecoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
            shimmerBaseColor: AppThemePreferences().appTheme.shimmerEffectBaseColor,
            shimmerHighlightColor: AppThemePreferences().appTheme.shimmerEffectHighLightColor,
            errorWidget: ShimmerEffectErrorWidget(iconSize: 100),
          ),
      ),
    ),
  );
}