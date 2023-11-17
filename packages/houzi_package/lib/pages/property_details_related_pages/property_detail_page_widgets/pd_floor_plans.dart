import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/models/article.dart';
import 'package:houzi_package/pages/property_details_related_pages/full_screen_image_view.dart';
import 'package:houzi_package/pages/property_details_related_pages/property_detail_page_widgets/pd_heading_widget.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';

class PropertyDetailPageFloorPlans extends StatefulWidget {
  final Article article;
  final String title;

  const PropertyDetailPageFloorPlans({
    required this.article,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  State<PropertyDetailPageFloorPlans> createState() =>
      _PropertyDetailPageFloorPlansState();
}

class _PropertyDetailPageFloorPlansState
    extends State<PropertyDetailPageFloorPlans> {
  Article? _article;

  List<dynamic> floorPlansList = [];

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    loadData(_article!);
  }

  loadData(Article article) {
    floorPlansList = article.features!.floorPlansList ?? [];
    if(mounted)setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_article != widget.article) {
      _article = widget.article;
      loadData(_article!);
    }
    return floorPlanWidget(widget.title);
  }

  Widget floorPlanWidget(String title) {
    if (title == null || title.isEmpty) {
      title = UtilityMethods.getLocalizedString("floor_plans");
    }
    return floorPlansList != null && floorPlansList.isNotEmpty
        ? Column(
            children: [
              textHeadingWidget(text: UtilityMethods.getLocalizedString(title)),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                child: Column(
                  children: floorPlansList.map((item) {
                    int index = floorPlansList.indexOf(item);
                    Map<String, dynamic> floorPlanMap = {};
                    String title = item.title ?? "";
                    String rooms = item.rooms ?? "";
                    String bathrooms = item.bathrooms ?? "";
                    String price = item.price ?? "";
                    String pricePostFix = item.pricePostFix ?? "";
                    if (price.isNotEmpty && pricePostFix.isNotEmpty) {
                      price = price + pricePostFix;
                    }
                    String size = item.size ?? "";
                    String image = item.image ?? "";
                    // String description = item.description;

                    if (rooms.isNotEmpty) {
                      floorPlanMap[FLOOR_PLAN_ROOMS] = AppThemePreferences.bedIcon;
                    }
                    if (bathrooms.isNotEmpty) {
                      floorPlanMap[FLOOR_PLAN_BATHROOMS] = AppThemePreferences.bathtubIcon;
                    }
                    if (price.isNotEmpty) {
                      floorPlanMap[FLOOR_PLAN_PRICE] = AppThemePreferences.priceTagIcon;
                    }
                    if (size.isNotEmpty) {
                      floorPlanMap[FLOOR_PLAN_SIZE] = AppThemePreferences.areaSizeIcon;
                    }
                    return floorPlanMap.isEmpty ?
                        Card(
                            elevation: AppThemePreferences.zeroElevation,
                            color: AppThemePreferences()
                                .appTheme
                                .containerBackgroundColor,
                            shape: AppThemePreferences.roundedCorners(
                                AppThemePreferences.globalRoundedCornersRadius),
                            child: InkWell(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              onTap: () {
                                if (image.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImageView(
                                        imageUrls: [image],
                                        tag: title + "floorPlans",
                                        floorPlan: true,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                                      child: GenericTextWidget(
                                          title.isNotEmpty ? UtilityMethods.getLocalizedString(title) :
                                          "${UtilityMethods.getLocalizedString("floor_plan")} ${index += 1}",
                                        strutStyle: StrutStyle(
                                            height: AppThemePreferences.genericTextHeight),
                                        style: AppThemePreferences().appTheme.label01TextStyle,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 5),
                                      child: CircleAvatar(
                                        radius: 13,
                                        backgroundColor: AppThemePreferences()
                                            .appTheme
                                            .homeScreenTopBarRightArrowBackgroundColor,
                                        // backgroundColor: AppThemePreferences().appTheme.primaryColor,
                                        child: AppThemePreferences()
                                            .appTheme
                                            .propertyDetailPageRightArrowIcon,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 1, vertical: 1),
                            child: Card(
                              elevation: AppThemePreferences.zeroElevation,
                              color: AppThemePreferences()
                                  .appTheme
                                  .containerBackgroundColor,
                              shape: AppThemePreferences.roundedCorners(
                                  AppThemePreferences
                                      .globalRoundedCornersRadius),
                              child: InkWell(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImageView(
                                        imageUrls: [image],
                                        tag: title + "floorPlans",
                                        floorPlan: true,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GenericTextWidget(
                                              UtilityMethods.getLocalizedString(title),
                                              strutStyle: StrutStyle(
                                                  height: AppThemePreferences
                                                      .genericTextHeight),
                                              style: AppThemePreferences()
                                                  .appTheme
                                                  .label01TextStyle,
                                            ),
                                            GenericTextWidget(
                                              UtilityMethods.getLocalizedString(
                                                  "view_floor_plan"),
                                              strutStyle: StrutStyle(
                                                  height: AppThemePreferences
                                                      .genericTextHeight),
                                              style: AppThemePreferences()
                                                  .appTheme
                                                  .readMoreTextStyle,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 10),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minHeight: 50,
                                            maxHeight: 60,
                                          ),
                                          child: StaggeredGridView.countBuilder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            crossAxisCount: 2,
                                            //floorPlanMap.length,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            itemCount: floorPlanMap.length,
                                            itemBuilder: (context, index) {
                                              var key = floorPlanMap.keys
                                                  .elementAt(index);
                                              var value = key ==
                                                      FLOOR_PLAN_ROOMS
                                                  ? rooms
                                                  : key == FLOOR_PLAN_BATHROOMS
                                                      ? bathrooms
                                                      : key == FLOOR_PLAN_PRICE
                                                          ? price
                                                          : key ==
                                                                  FLOOR_PLAN_SIZE
                                                              ? size
                                                              : "";
                                              return Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                // mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    floorPlanMap[key],
                                                    size: AppThemePreferences
                                                        .propertyDetailsFloorPlansIconSize,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: GenericTextWidget(
                                                      key == FLOOR_PLAN_PRICE
                                                          ? "\$$value"
                                                          : value,
                                                      strutStyle: StrutStyle(
                                                          height: AppThemePreferences
                                                              .genericTextHeight,),
                                                      style:
                                                          AppThemePreferences()
                                                              .appTheme
                                                              .label01TextStyle,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                            staggeredTileBuilder: (int index) =>
                                                const StaggeredTile.fit(1),
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 90, //100
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                  }).toList(),
                ),
              ),
            ],
          )
        : Container();
  }
}
