import 'dart:math';

import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/files/item_design_files/item_design_notifier.dart';
import 'package:houzi_package/models/article.dart';
import 'package:houzi_package/pages/filter_page.dart';
import 'package:houzi_package/widgets/article_box_widgets/article_box_design.dart';
import 'package:houzi_package/widgets/generic_animate_icon_widget.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';
import 'package:houzi_package/widgets/no_result_error_widget.dart';
import 'package:houzi_package/widgets/search_result_widgets/panel_loading_widget.dart';
import 'package:houzi_package/widgets/search_result_widgets/search_choice_chip_widget.dart';
import 'package:houzi_package/widgets/search_result_widgets/sort_widget.dart';
import 'package:intl/intl.dart';

typedef PanelPropertiesListingWidgetListener = Function({
  bool? performSearch,
  int? totalResults,
});

class PanelPropertiesListingWidget extends StatefulWidget {

  final int? totalResults;
  final bool refreshing;
  final bool hasBottomNavigationBar;
  final ScrollController panelScrollController;
  final ItemDesignNotifier itemDesignNotifier;
  final Future<List<dynamic>>? futureFilteredArticles;
  final void Function(Article, int, String) onPropArticleTap;


  final PanelPropertiesListingWidgetListener listener;
  
  final bool isNativeAdLoaded;
  final List nativeAdList;


  PanelPropertiesListingWidget({
    Key? key,
    required this.totalResults,
    required this.refreshing,
    required this.hasBottomNavigationBar,
    required this.panelScrollController,
    required this.itemDesignNotifier,
    required this.futureFilteredArticles,
    required this.isNativeAdLoaded,
    required this.nativeAdList,
    required this.onPropArticleTap,

    required this.listener,

  }) : super(key: key);

  @override
  State<PanelPropertiesListingWidget> createState() => _PanelPropertiesListingWidgetState();
}

class _PanelPropertiesListingWidgetState extends State<PanelPropertiesListingWidget> {
  AnimateIconController gridListAnimateIconController = AnimateIconController();

  final ArticleBoxDesign _articleBoxDesign = ArticleBoxDesign();

  final Map<String, dynamic> sortByMenuOptions = {
    "Newest": Icons.access_time,
    "Oldest": Icons.access_time,
    "Price (low to high)": Icons.sell_outlined,
    "Price (high to low)": Icons.sell_outlined
  };

  bool _sortFlag = false;

  bool _showGridView = false;

  int _currentPropertyListSortValue = 0;

  int _previousPropertyListSortValue = -1;

  String gridAnimatedIconLabel = UtilityMethods.getLocalizedString(CHIP_GRID);

  @override
  Widget build(BuildContext context) {
    return widget.refreshing == true ? PanelLoadingWidget() : FutureBuilder<List<dynamic>>(
      future: widget.futureFilteredArticles,
      builder: (context, articleSnapshot) {

        if (articleSnapshot.hasData) {
          if (articleSnapshot.data!.isEmpty){
            return NoResultFoundPageWidget(
              refreshing: widget.refreshing,
              listener: ({performSearch, totalResults}) {
                widget.listener(performSearch: performSearch);
              },
              // listener: ({performSearch, }) {
              //   listener(performSearch: performSearch);
              // },
            );
          }

          List<dynamic> propertyList = articleSnapshot.data!;

          if (_sortFlag == true) {
            propertyList.removeWhere((element) => element is AdWidget);
            if (_currentPropertyListSortValue == 0) {
              propertyList.sort((a, b) {
                var aDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(a.dateGMT));
                var bDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(b.dateGMT));
                return bDate.compareTo(aDate);

              });
            }

            if (_currentPropertyListSortValue == 1) {
              propertyList.sort((a, b) {
                var aDate =
                DateFormat('yyyy-MM-dd').format(DateTime.parse(a.dateGMT));
                var bDate =
                DateFormat('yyyy-MM-dd').format(DateTime.parse(b.dateGMT));
                return aDate.compareTo(bDate);
              });
            }
            if (_currentPropertyListSortValue == 2) {
              propertyList.sort((a, b) {
                int aPrice = UtilityMethods.getCleanPriceForSorting(a.propertyInfo.price.isNotEmpty ? a.propertyInfo.price : "0");
                int bPrice = UtilityMethods.getCleanPriceForSorting(b.propertyInfo.price.isNotEmpty ? b.propertyInfo.price : "0");

                return aPrice.compareTo(bPrice);
              });
            }

            if (_currentPropertyListSortValue == 3) {
              propertyList.sort((a, b) {
                int aPrice = UtilityMethods.getCleanPriceForSorting(a.propertyInfo.price.isNotEmpty ? a.propertyInfo.price : "0");
                int bPrice = UtilityMethods.getCleanPriceForSorting(b.propertyInfo.price.isNotEmpty ? b.propertyInfo.price : "0");

                return bPrice.compareTo(aPrice);
              });
            }
            //_sortFlag = false;
          }
          if(SHOW_ADS_ON_LISTINGS){
            propertyList.removeWhere((element) => element is AdWidget);
            InsertAdsInPropertyList(propertyList);
          }

          return Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                              color: AppThemePreferences().appTheme.dividerColor,
                              borderRadius: const BorderRadius.all(Radius.circular(12.0))),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 30),//30
                      child: GenericTextWidget(
                        UtilityMethods.getLocalizedString("properties"),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // if (_isNativeAdLoaded)
                    //  Padding(
                    //    padding: EdgeInsets.only(top: 100),
                    //    child: Container(
                    //      height: 50,
                    //      color: Colors.black,
                    //      // child: AdWidget(ad: _nativeAd),
                    //    ),
                    //  ),
                  ],
                ),
              ),

              Column(
                children: [
                  // if (_isNativeAdLoaded && SHOW_ADS_ON_LISTINGS)
                  //   Container(
                  //     margin: EdgeInsets.only(top: 50),
                  //     padding: EdgeInsets.all(5),
                  //     height: 160,
                  //     child: AdWidget(ad: _nativeAd),
                  //   ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      // maxHeight: MediaQuery.of(context).size.height - (SHOW_ADS_ON_LISTINGS?310:100),//100
                      maxHeight: MediaQuery.of(context).size.height - (widget.hasBottomNavigationBar ? 150 : 100),
                      // maxHeight: MediaQuery.of(context).size.height - (widget.hasBottomNavigationBar ? 270 : 220),//150:100
                      // maxHeight: MediaQuery.of(context).size.height - 100,//100
                    ),
                    child: SingleChildScrollView(
                      controller: widget.panelScrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 70, left: UtilityMethods.isRTL(context) ? 10 : 20, right: UtilityMethods.isRTL(context) ? 20 : 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GenericTextWidget(
                                        widget.totalResults != null ? "${widget.totalResults} " + UtilityMethods.getLocalizedString("Results") :
                                        UtilityMethods.getLocalizedString("searching"),
                                        style: AppThemePreferences().appTheme.searchResultsTotalResultsTextStyle,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: GenericTextWidget(
                                          UtilityMethods.getLocalizedString("showing_sorted_results", inputWords: [getTheCurrentSortOption()]),
                                          style: AppThemePreferences().appTheme.searchResultsShowingSortedTextStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (SHOW_GRID_VIEW_BUTTON) SearchResultsChoiceChipsWidget(
                                        label: "",
                                        // label: gridAnimatedIconLabel,
                                        avatar: GenericAnimateIcons(
                                          startIcon: Icons.grid_view_outlined,
                                          endIcon: Icons.list_outlined,
                                          controller: gridListAnimateIconController,
                                          size: 20,
                                          onStartIconPress: () {
                                            onGridAnimatedButtonStartPressed();
                                            return true;
                                          },
                                          onEndIconPress: () {
                                            onGridAnimatedButtonEndPressed();
                                            return true;
                                          },
                                        ),
                                        onSelected: (value) {
                                          if (gridListAnimateIconController.isStart()) {
                                            onGridAnimatedButtonStartPressed();
                                          } else if (gridListAnimateIconController.isEnd()) {
                                            onGridAnimatedButtonEndPressed();
                                          }
                                        },
                                      ),
                                      SearchResultsChoiceChipsWidget(
                                        label: "",
                                        // label: GenericMethods.getLocalizedString(CHIP_SORT),
                                        iconData: Icons.sort_outlined,
                                        onSelected: (value) => onSortWidgetTap(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10),//50
                            // padding: EdgeInsets.only(top: SHOW_ADS_ON_LISTINGS?0:50),
                            // padding: EdgeInsets.only(top: 5),
                            child: _showGridView ? GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                              // controller: panelScrollController,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: propertyList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {

                                // var object = propertyList[index];
                                // if (object is AdWidget) {
                                //   return  Container();
                                // }
                                try{
                                  var object = propertyList[index];
                                  if (object is AdWidget) {
                                    return  Container();
                                  }
                                }catch(e){
                                  return Container();
                                }

                                Article item = propertyList[index];
                                var heroId = "${item.id}-${UtilityMethods.getRandomNumber()}-$FILTERED_GRID";
                                final int propId = item.id!;
                                return SizedBox(
                                  height: _articleBoxDesign.getArticleBoxDesignHeight(design: DESIGN_09),
                                  child: _articleBoxDesign.getArticleBoxDesign(
                                    design: DESIGN_09,
                                    buildContext: context,
                                    heroId: heroId,
                                    article: item,
                                    onTap: () => widget.onPropArticleTap(item, propId, heroId),
                                  ),
                                );
                              },
                            ) :
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              addAutomaticKeepAlives: true,
                              // controller: panelScrollController,
                              itemCount: propertyList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index){
                                // NativeAd native;
                                // if (SHOW_ADS_ON_LISTINGS && index % 5 == 0 && index != 0){
                                //    native =  getNativeAd();
                                // }
                                Article item;
                                var heroId = "";
                                int propId;
                                try{
                                  var object = propertyList[index];
                                  if (object is AdWidget) {
                                    return  Container(height:160,padding: const EdgeInsets.all(5),child: object);
                                  }
                                  item = propertyList[index];
                                  var heroId = "${item.id}-${UtilityMethods.getRandomNumber()}-$FILTERED";
                                  propId  = item.id!;
                                }catch(e){
                                  return Container();
                                }
                                return SizedBox(
                                  height: _articleBoxDesign.getArticleBoxDesignHeight(design: SEARCH_RESULTS_PROPERTIES_DESIGN),
                                  child: _articleBoxDesign.getArticleBoxDesign(
                                    design: SEARCH_RESULTS_PROPERTIES_DESIGN,
                                    buildContext: context,
                                    heroId: heroId,
                                    article: item,
                                    onTap: () => widget.onPropArticleTap(item, propId, heroId),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }else if (articleSnapshot.hasError) {
          widget.listener(totalResults: 0);
          return NoResultFoundPageWidget(
            refreshing: widget.refreshing,
            listener: ({performSearch, totalResults}) {
              widget.listener(performSearch: performSearch);
            },
          );
        }


        return PanelLoadingWidget();
      },
    );
  }

  InsertAdsInPropertyList(List<dynamic> propertyList){
    if(widget.isNativeAdLoaded){
      if (!(widget.nativeAdList.length <= 0)) {
        int offset = 5;
        int index = min(5, propertyList.length);
        for (NativeAd ad in widget.nativeAdList) {
          if (index > propertyList.length) {
            break;
          }

          propertyList.insert(index, AdWidget(ad: ad));
          index = index + offset;
          //print("index is $index, offset $offset, ad is ${ad.responseInfo.responseId}");
        }
      }
    }
  }

  String getTheCurrentSortOption(){
    List tempKeys = [];
    tempKeys = sortByMenuOptions.keys.toList();
    if(tempKeys.isNotEmpty){
      return UtilityMethods.getLocalizedString(tempKeys[_currentPropertyListSortValue]);
    }

    return UtilityMethods.getLocalizedString('Newest');
  }

  onGridAnimatedButtonStartPressed(){
    gridListAnimateIconController.animateToEnd();

    if(mounted) setState(() {
      _showGridView = true;
    });

    // gridAnimatedIconLabel = UtilityMethods.getLocalizedString(CHIP_LIST);
  }

  onGridAnimatedButtonEndPressed(){
    gridListAnimateIconController.animateToStart();

    if(mounted) setState(() {
      _showGridView = false;
    });

    // gridAnimatedIconLabel = UtilityMethods.getLocalizedString(CHIP_GRID);
  }

  onSortWidgetTap(BuildContext context){
    showModalBottomSheet<void>(
      useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SortMenuWidget(
              sortByMenuOptions: sortByMenuOptions,
              currentPropertyListSortValue: _currentPropertyListSortValue,
              previousPropertyListSortValue: _previousPropertyListSortValue,
              listener: ({currentSortValue, previousSortValue, sortFlag}) {
                if(mounted) setState(() {
                  if(currentSortValue != null){
                    _currentPropertyListSortValue = currentSortValue;
                  }

                  if(previousSortValue != null){
                    _previousPropertyListSortValue = previousSortValue;
                  }

                  if(sortFlag != null){
                    _sortFlag = sortFlag;
                  }
                });
              },
            ),
          );
        });
  }
}

class NoResultFoundPageWidget extends StatelessWidget {
  final bool refreshing;
  final PanelPropertiesListingWidgetListener listener;

  const NoResultFoundPageWidget({
    Key? key,
    required this.refreshing,
    required this.listener,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: refreshing == true ? PanelLoadingWidget() : NoResultErrorWidget(
        headerErrorText: UtilityMethods.getLocalizedString("no_result_found"),
        bodyErrorText: UtilityMethods.getLocalizedString("no_properties_error_message_filter_page_search"),
        buttonText:  UtilityMethods.getLocalizedString("refine_search_text"),
        onButtonPressed: () => NavigateToFilterPage(context),
      ),
    );
  }

  NavigateToFilterPage(BuildContext context, {Map? dataMap}){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterPage(
          mapInitializeData: dataMap != null && dataMap.isNotEmpty ?
          dataMap : HiveStorageManager.readFilterDataInfo() ?? {},
          filterPageListener: (Map<String, dynamic> map, String closeOption) {
            if (closeOption == DONE) {
              Navigator.of(context).pop();
              listener(performSearch: true);
            }else if(closeOption == CLOSE){
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }
}

