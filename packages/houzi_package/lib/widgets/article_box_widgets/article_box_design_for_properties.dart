import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/hooks_files/hooks_configurations.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/models/article.dart';
import 'package:houzi_package/widgets/article_box_widgets/tags_widgets/tag_widget.dart';

import 'package:houzi_package/widgets/button_widget.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';

import 'tags_widgets/featured_tag_widget.dart';

typedef PropertiesArticleBoxDesignWidgetListener = void Function(Map<String, dynamic> actionButtonMap);

Widget propertiesArticleBoxDesign({
  required BuildContext context,
  required Article item,
  required Map<String, dynamic> actionButtonMap,
  required Function() onTap,
  required final PropertiesArticleBoxDesignWidgetListener propertiesArticleBoxDesignWidgetListener}) {

  String _imageUrl = item.imageList != null && item.imageList!.isNotEmpty ? item.imageList![0] : "";
  String _status = item.status!;
  String _title = UtilityMethods.stripHtmlIfNeeded(item.title!);
  String heroId = item.id.toString() + RELATED;

  if (TOUCH_BASE_PAYMENT_ENABLED_STATUS == perListing && actionButtonMap["_status"] != STATUS_PUBLISH) {
    String paymentStatus = item.propertyInfo!.paymentStatus ?? "";
    if (paymentStatus == "not_paid") {
      _status = "Pay Now";
    }
  }

  return InkWell(
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    onTap: onTap,
    child: Container(
      height: 270,
      padding: const EdgeInsets.only(bottom: 7,left: 5,right: 5,top: 3),
      child: Card(
        color: AppThemePreferences().appTheme.articleDesignItemBackgroundColor,
        shape: AppThemePreferences.roundedCorners(AppThemePreferences.articleDesignRoundedCornersRadius),
        elevation: AppThemePreferences.articleDeignsElevation,
        child: Stack(
          children: <Widget>[
            imageWidget(context: context, heroId: heroId, imageUrl: _imageUrl),
            propertyStatusWidget(_status),
            item.propertyInfo!.isFeatured! ? propertyFeatureWidget() : Container(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleAndActionButtonWidget(context: context, title: _title, actionButtonMap: actionButtonMap, articleBox09WidgetListener: propertiesArticleBoxDesignWidgetListener),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        propertyFeaturesWidget(item: item, padding: const EdgeInsets.fromLTRB(0, 0, 0, 0)),
                        priceWidget(item: item),
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

Widget imageWidget({
  required BuildContext context,
  required String heroId,
  required String imageUrl,
}) {
  bool _validURL = UtilityMethods.validateURL(imageUrl);

  return SizedBox(
    height: 165,
    width: MediaQuery.of(context).size.width,
    child: Hero(
      tag: heroId,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: !_validURL ? errorWidget() : FancyShimmerImage(
          imageUrl: imageUrl,
          boxFit: BoxFit.cover,
          shimmerBaseColor: AppThemePreferences().appTheme.shimmerEffectBaseColor,
          shimmerHighlightColor: AppThemePreferences().appTheme.shimmerEffectHighLightColor,
          errorWidget: errorWidget(),
        ),
      ),
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


Widget titleAndActionButtonWidget({
  required BuildContext context,
  required String title,
  required Map<String, dynamic> actionButtonMap,
  required PropertiesArticleBoxDesignWidgetListener articleBox09WidgetListener,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
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
              onPressed: () => articleBox09WidgetListener(actionButtonMap)),
        ),
      ],
    ),
  );
}

Widget propertyStatusWidget(String status) {
  return Positioned(
    top: 10,
    right: 15,
    child: status == null || status.isEmpty ? Container() : Container(
      padding: const EdgeInsets.all(5),
      alignment: Alignment.topRight,
      child: TagWidget(label: UtilityMethods.getLocalizedString(status).toUpperCase()),
    ),
  );
}

Widget propertyFeatureWidget() {
  return Positioned(
    top: 10,
    left: 15,
    child: Container(
      padding: const EdgeInsets.all(5),
      alignment: Alignment.topLeft,
      child: FeaturedTagWidget(),
    ),
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

Widget errorWidget(){
  return Container(
    color: AppThemePreferences().appTheme.shimmerEffectErrorWidgetBackgroundColor,
    child: Center(child: AppThemePreferences().appTheme.shimmerEffectImageErrorIcon),
  );
}