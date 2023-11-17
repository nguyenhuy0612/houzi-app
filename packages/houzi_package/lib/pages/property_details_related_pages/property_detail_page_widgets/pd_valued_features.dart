import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/models/article.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';

class PropertyDetailPageValuedFeatured extends StatefulWidget {
  final Article article;

  const PropertyDetailPageValuedFeatured({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  State<PropertyDetailPageValuedFeatured> createState() => _PropertyDetailPageValuedFeaturedState();
}

class _PropertyDetailPageValuedFeaturedState extends State<PropertyDetailPageValuedFeatured> {
  Map<String, String> articleDetailsMap = {};
  Map<String, String> _mapOfFeaturesWithValues = {};
  Map<String, dynamic> _iconMap = UtilityMethods.iconMap;

  @override
  void initState() {
    super.initState();

    articleDetailsMap = widget.article.propertyDetailsMap ?? {};

    if(articleDetailsMap.isNotEmpty){
      _iconMap.forEach((key, value) {
        if (articleDetailsMap.containsKey(key)) {
          _mapOfFeaturesWithValues[key] = articleDetailsMap[key]!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return valuedFeaturesWidget();
  }

  Widget valuedFeaturesWidget() {
    return _mapOfFeaturesWithValues == null || _mapOfFeaturesWithValues.isEmpty ? Container()
        : Container(
            height: 50,
            padding: EdgeInsets.fromLTRB(
                UtilityMethods.isRTL(context) ? 0 : 16,
                0, UtilityMethods.isRTL(context) ? 16 : 0, 0,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: _mapOfFeaturesWithValues.length,
              itemBuilder: (context, index) {
                var key = _mapOfFeaturesWithValues.keys.elementAt(index);
                var value = _mapOfFeaturesWithValues[key];
                String label = UtilityMethods.getLocalizedString(key);
                return singleValueFeatureWidget(index, key, value!, label, _iconMap, widget.article);
              },
            ),
          );
  }

  Widget singleValueFeatureWidget(int index, String key, String value, String label, Map<String, dynamic> _iconMap, Article _article) {
    return Padding(
      padding: EdgeInsets.only(left: index == 0 ? 0 : 5),
      child: Card(
        elevation: AppThemePreferences.zeroElevation,
        shape: AppThemePreferences.roundedCorners(
            AppThemePreferences.propertyDetailPageRoundedCornersRadius),
        color: AppThemePreferences().appTheme.containerBackgroundColor,
        // padding: EdgeInsets.symmetric(horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconMap.containsKey(key)
                    ? _iconMap[key]
                    : AppThemePreferences.errorIcon,
                size: AppThemePreferences.propertyDetailsValuedFeaturesIconSize,
              ),
              Container(
                padding: const EdgeInsets.only(top: 0, left: 5),
                child: GenericTextWidget(
                  value,
                  textAlign: TextAlign.center,
                  strutStyle: StrutStyle(height: AppThemePreferences.genericTextHeight),
                  style: AppThemePreferences().appTheme.label01TextStyle,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 0, left: 5),
                child: GenericTextWidget(
                  key == PROPERTY_DETAILS_PROPERTY_SIZE
                      ? UtilityMethods.isValidString(_article.features!.landAreaUnit)
                          ? _article.features!.landAreaUnit!
                          : MEASUREMENT_UNIT_TEXT
                      : label,
                  textAlign: TextAlign.center,
                  strutStyle: StrutStyle(height: AppThemePreferences.genericTextHeight),
                  style: AppThemePreferences().appTheme.label01TextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
