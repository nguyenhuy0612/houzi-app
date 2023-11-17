import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/hooks_files/hooks_configurations.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/models/article.dart';
import 'package:houzi_package/pages/property_details_related_pages/property_detail_page_widgets/pd_heading_widget.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';

class PropertyDetailPageFeaturesDetail extends StatefulWidget {
  final Article article;
  final String title;

  const PropertyDetailPageFeaturesDetail({
    required this.article,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  State<PropertyDetailPageFeaturesDetail> createState() => _PropertyDetailPageFeaturesDetailState();
}

class _PropertyDetailPageFeaturesDetailState extends State<PropertyDetailPageFeaturesDetail> {

  Article? _article;
  bool isMoreDetails = false;
  bool hide = false;

  Map<String, String> articleDetailsMap = {};
  Map<String, String> customFieldsMap = {};

  List<dynamic> additionalDetailsList = [];
  
  @override
  void initState() {
    super.initState();
    _article = widget.article;
    HidePriceHook hidePrice = HooksConfigurations.hidePriceHook;
    hide = hidePrice();
    loadData(_article!);
  }

  loadData(Article article) {
    articleDetailsMap = article.propertyDetailsMap ?? {};
    customFieldsMap = article.propertyInfo!.customFieldsMap ?? {};

    if (customFieldsMap.isNotEmpty) {
      articleDetailsMap.addAll(customFieldsMap);
    }
    if(UtilityMethods.isValidString(article.propertyInfo!.propertyStatus)){
      articleDetailsMap[ARTICLE_STATUS] = article.propertyInfo!.propertyStatus!;
    }

    additionalDetailsList = article.features!.additionalDetailsList ?? [];
    if(mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_article != widget.article) {
      _article = widget.article;
      loadData(_article!);
    }
    return featuresDetailsWidget(widget.title);
  }

  Widget featuresDetailsWidget(String title) {
    if (!UtilityMethods.isValidString(title)) {
      title = "details";
    }

    return (articleDetailsMap == null || articleDetailsMap.isEmpty) ? Container()
        : Column(
      children: [
        textHeadingWidget(
          text: UtilityMethods.getLocalizedString(title),
          widget: showMoreDetails(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: AppThemePreferences.zeroElevation,
            shape: AppThemePreferences.roundedCorners(AppThemePreferences.propertyDetailPageRoundedCornersRadius),
            color: AppThemePreferences().appTheme.containerBackgroundColor,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: articleDetailsMap.length > 3
                    ? isMoreDetails
                    ? articleDetailsMap.length
                    : 3
                    : articleDetailsMap.length,
                itemBuilder: (context, int index) {
                  String key = articleDetailsMap.keys.elementAt(index);
                  String value = articleDetailsMap[key] ?? "";
                  if(value.contains("\n")){
                    value = value.replaceAll("\n", ", ");
                  }
                  if (key == FIRST_PRICE ||key == PRICE || key == SECOND_PRICE) {
                    if (hide) {
                      return Container();
                    }
                    value = UtilityMethods.priceFormatter(value, "");
                  }
                  key = UtilityMethods.getLocalizedString(key);
                  return Container(
                    decoration: index == 0
                        ? null
                        : AppThemePreferences.dividerDecoration(top: true),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 40,
                    child: singleFeatureDetailWidget(key, value),
                  );
                },
              ),
            ),
          ),
        ),
        articleAdditionalFeaturesDetailsWidget(),
      ],
    );
  }

  Widget singleFeatureDetailWidget(String key, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GenericTextWidget(
          key + " : ",
          textAlign: TextAlign.start,
          strutStyle: StrutStyle(height: AppThemePreferences.genericTextHeight),
          style: AppThemePreferences().appTheme.subBody01TextStyle,
        ),
        Expanded(
          child: GenericTextWidget(
            UtilityMethods.getLocalizedString(value),
            textAlign: TextAlign.end,
            strutStyle: StrutStyle(height: AppThemePreferences.genericTextHeight),
            style: AppThemePreferences().appTheme.label01TextStyle,
          ),
        ),
      ],
    );
  }

  Widget articleAdditionalFeaturesDetailsWidget() {
    return isMoreDetails &&
        additionalDetailsList != null &&
        additionalDetailsList.isNotEmpty
        ? Column(
      children: [
        textHeadingWidget(
          text: UtilityMethods.getLocalizedString("additional_details"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: AppThemePreferences.zeroElevation,
            shape: AppThemePreferences.roundedCorners(AppThemePreferences.propertyDetailPageRoundedCornersRadius),
            color: AppThemePreferences().appTheme.containerBackgroundColor,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: additionalDetailsList.length,
                itemBuilder: (context, int index) {
                  String title = additionalDetailsList[index].title ?? "";
                  String value = additionalDetailsList[index].value ?? "";
                  return Container(
                    decoration: index == 0
                        ? null
                        : AppThemePreferences.dividerDecoration(top: true),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 40,
                    child: singleFeatureDetailWidget(title, value),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    )
        : Container();
  }

  Widget showMoreDetails() {
    return articleDetailsMap.length > 3 || (additionalDetailsList != null && additionalDetailsList.isNotEmpty)
        ? Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
          child: InkWell(
            onTap: () {
              setState(() {
                isMoreDetails = !isMoreDetails;
              });
            },
            child: GenericTextWidget(
              isMoreDetails
                  ? UtilityMethods.getLocalizedString("less_details")
                  : UtilityMethods.getLocalizedString("more_details"),
              strutStyle: StrutStyle(height: AppThemePreferences.genericTextHeight),
              style: AppThemePreferences().appTheme.readMoreTextStyle,
              // textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    )
        : Container();
  }
}