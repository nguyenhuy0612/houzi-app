import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/models/article.dart';

import '../generic_text_widget.dart';
import 'article_box_design_for_properties.dart';

typedef FavouritesArticleBoxDesignWidgetListener = void Function(int propertyListIndex,Map<String, dynamic> addOrRemoveFromFavInfo);

Widget favouritesArticleBoxDesign({
  required BuildContext context,
  required Article item,
  required int propertyListIndex,
  required Function() onTap,
  required final FavouritesArticleBoxDesignWidgetListener favouritesArticleBoxDesignWidgetListener
}) {
  String heroId = item.id.toString() + FAVOURITES;
  String _imageUrl = "";
  if (item.imageList != null && item.imageList!.isNotEmpty) {
    _imageUrl = item.imageList![0];
  }
  String _title = UtilityMethods.stripHtmlIfNeeded(item.title!);

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
            favouriteWidget(
              onPressed: () async {
                Map<String, dynamic> addOrRemoveFromFavInfo = {"listing_id": item.id};
                favouritesArticleBoxDesignWidgetListener(propertyListIndex,addOrRemoveFromFavInfo);
              },
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleWidget(_title),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        propertyFeaturesWidget(item: item),
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

Widget titleWidget(String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 8, 10, 5),
    child: GenericTextWidget(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppThemePreferences().appTheme.titleTextStyle,
    ),
  );
}

Widget favouriteWidget({
  required Function() onPressed,
}){
  return Positioned(
    top: 10,
    right: 15,
    child: CircleAvatar(
      radius: 20,
      backgroundColor: AppThemePreferences().appTheme.favouriteWidgetBackgroundColor,
      child: IconButton(
        icon: Icon(
          AppThemePreferences.favouriteIconFilled,
          color: AppThemePreferences.favouriteIconColor,
        ),
        onPressed: onPressed,
      ),
    ),
  );
}