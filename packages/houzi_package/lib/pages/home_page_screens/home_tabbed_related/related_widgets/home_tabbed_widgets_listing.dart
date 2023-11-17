import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:houzi_package/files/hooks_files/hooks_configurations.dart';
import 'package:houzi_package/providers/state_providers/locale_provider.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/theme_service_files/theme_storage_manager.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/all_agency.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/all_agents.dart';
import 'package:houzi_package/pages/search_result.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';
import 'package:houzi_package/widgets/no_result_error_widget.dart';
import 'package:houzi_package/widgets/partners_widget/partner_widget.dart';
import 'package:houzi_package/widgets/type_status_row_widget.dart';
import 'package:provider/provider.dart';

import 'package:houzi_package/blocs/property_bloc.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/generic_methods/general_notifier.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/pages/home_page_screens/parent_home_related/home_screen_widgets/home_screen_properties_related_widgets/explore_properties_widget.dart';
import 'package:houzi_package/pages/home_page_screens/parent_home_related/home_screen_widgets/home_screen_properties_related_widgets/latest_featured_properties_widget/properties_carousel_list_widget.dart';
import 'package:houzi_package/pages/home_page_screens/parent_home_related/home_screen_widgets/home_screen_realtors_related_widgets/home_screen_realtors_list_widget.dart';
import 'package:houzi_package/pages/home_page_screens/parent_home_related/home_screen_widgets/home_screen_recent_searches_widget/home_screen_recent_searches_widget.dart';

typedef HomeTabbedListingsWidgetListener = void Function(bool errorWhileLoading, bool dataLoadingComplete);

class HomeTabbedListingsWidget extends StatefulWidget {
  final homeScreenData;
  final bool refresh;
  final Map selectedItem;
  final HomeTabbedListingsWidgetListener? homeTabbedListingsWidgetListener;

  HomeTabbedListingsWidget({
    this.homeScreenData,
    this.refresh = false,
    required this.selectedItem,
    this.homeTabbedListingsWidgetListener,
  });

  @override
  State<HomeTabbedListingsWidget> createState() => _HomeScreenListingsWidgetState();
}

class _HomeScreenListingsWidgetState extends State<HomeTabbedListingsWidget>  with AutomaticKeepAliveClientMixin<HomeTabbedListingsWidget>  {

  int page = 1;

  String arrowDirection = " >";

  NativeAd? _nativeAd;

  bool isDataLoaded = false;
  bool noDataReceived = false;
  bool _isNativeAdLoaded = false;

  bool isPageFreeForLoading = true;
  bool permissionGranted = false;

  List<dynamic> homeScreenList = [];

  Map homeConfigMap = {};
  Map<String, dynamic> setRouteRelatedDataMap = {};

  VoidCallback? generalNotifierLister;

  Future<List<dynamic>>? _futureHomeScreenList;

  final PropertyBloc _propertyBloc = PropertyBloc();

  Widget _placeHolderWidget = Container();


  @override
  void initState() {
    super.initState();

    generalNotifierLister = () {
      if (GeneralNotifier().change == GeneralNotifier.CITY_DATA_UPDATE) {
        if(homeConfigMap[sectionTypeKey] == allPropertyKey &&
            homeConfigMap[subTypeKey] == propertyCityDataType){
          setState(() {
            Map map = HiveStorageManager.readSelectedCityInfo();

            if(homeConfigMap[subTypeValueKey] != map[CITY_ID].toString()){
              homeScreenList = [];
              isDataLoaded = false;
              noDataReceived = false;
              if (map[CITY_ID] != null) {
                homeConfigMap[subTypeValueKey] = map[CITY_ID].toString();
              } else {
                homeConfigMap[subTypeValueKey] = "";
              }

              homeConfigMap[titleKey] = "";
              if(map[CITY] != null && map[CITY].isNotEmpty && map[CITY_ID] != null){
                homeConfigMap[titleKey] = UtilityMethods.getLocalizedString(
                    "latest_properties_in_city",inputWords: [map[CITY]]);
              }
              else{
                homeConfigMap[titleKey] = UtilityMethods.getLocalizedString("latest_properties");
              }

              loadData();
            }
          });
        }else if(homeConfigMap[sectionTypeKey] == propertyKey && homeConfigMap[subTypeKey] == propertyCityDataType &&
            homeConfigMap[subTypeValueKey] == userSelectedString){
          setState(() {
            Map map = HiveStorageManager.readSelectedCityInfo();

            homeScreenList = [];
            isDataLoaded = false;
            noDataReceived = false;
            homeConfigMap[titleKey] = "";

            if(map.isNotEmpty && map[CITY] != null && map[CITY].isNotEmpty && map[CITY_ID] != null){
              homeConfigMap[titleKey] = UtilityMethods.getLocalizedString(
                  "latest_properties_in_city",inputWords: [map[CITY]]);
            }
            else{
              homeConfigMap[titleKey] = UtilityMethods.getLocalizedString("latest_properties");
            }

            loadData();
          });
        }

      } else if(GeneralNotifier().change == GeneralNotifier.RECENT_DATA_UPDATE &&
          homeConfigMap[sectionTypeKey] == recentSearchKey){
        setState(() {
          homeScreenList.clear();
          List tempList = HiveStorageManager.readRecentSearchesInfo() ?? [];
          homeScreenList.addAll(tempList);
          setState(() {
            isDataLoaded = true;
          });
        });
      } else if(GeneralNotifier().change == GeneralNotifier.TOUCH_BASE_DATA_LOADED &&
          homeConfigMap[sectionTypeKey] != adKey
          && homeConfigMap[sectionTypeKey] != recentSearchKey
          && homeConfigMap[sectionTypeKey] != PLACE_HOLDER_SECTION_TYPE
          && mapEquals(widget.selectedItem, homeConfigMap
          )){
          // widget.selectedItem == homeConfigMap[sectionTypeKey]){
        if(mounted){
          setState(() {
            loadData();
            // widget.refresh = false;
          });
        }
      }
    };

    GeneralNotifier().addListener(generalNotifierLister!);
  }

  @override
  void dispose() {
    super.dispose();

    if(_nativeAd != null){
      _nativeAd!.dispose();
    }
    homeScreenList = [];
    homeConfigMap = {};
    if (generalNotifierLister != null) {
      GeneralNotifier().removeListener(generalNotifierLister!);
    }
  }

  setUpNativeAd() {
    print("CALLING ADS");
    String themeMode = ThemeStorageManager.readData(THEME_MODE_INFO) ?? LIGHT_THEME_MODE;
    bool isDarkMode = false;
    if (themeMode == DARK_THEME_MODE) {
      isDarkMode = true;
    }
    _nativeAd = NativeAd(
      customOptions: {"isDarkMode": isDarkMode},
      adUnitId: Platform.isAndroid ? ANDROID_NATIVE_AD_ID : IOS_NATIVE_AD_ID,
      factoryId: 'homeNativeAd',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isNativeAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (kDebugMode) {
            print(
              'Ad load failed (code=${error.code} message=${error.message})',
            );
          }
        },
      ),
    );

    _nativeAd!.load();
  }

  loadData() {
    // print("Item Section Type: ${widget.homeScreenData[sectionTypeKey]}");
    _futureHomeScreenList = fetchRelatedList(context, page);
    _futureHomeScreenList!.then((value) {
      if (value == null || value.isEmpty) {
        noDataReceived = true;
        widget.homeTabbedListingsWidgetListener!(false, true);
        isPageFreeForLoading = true;
      } else {
        if(value[0].runtimeType == Response){
          // print("Generic Home Listing (Error Code): ${value[0].statusCode}");
          // print("Generic Home Listing (Error Msg): ${value[0].statusMessage}");
          noDataReceived = true;
          widget.homeTabbedListingsWidgetListener!(true, true);
          isPageFreeForLoading = true;
        }else{
          homeScreenList = value;
          isDataLoaded = true;
          widget.homeTabbedListingsWidgetListener!(false, true);
          isPageFreeForLoading = true;
          noDataReceived = false;
        }
      }

      if(mounted){
        setState(() {});
      }

      return null;
    });
  }

  Future<List<dynamic>> fetchRelatedList(BuildContext context, int page) async {
    List<dynamic> tempList = [];
    setRouteRelatedDataMap = {};
    if (homeConfigMap[showNearbyKey]) {
      permissionGranted = await UtilityMethods.locationPermissionsHandling(permissionGranted);
    }
    try {
      /// Fetch featured properties
      if (homeConfigMap[sectionTypeKey] == featuredPropertyKey) {
        tempList = await _propertyBloc.fetchFeaturedArticles(page);
      }

      /// Fetch All_properties (old)
      else if (homeConfigMap[sectionTypeKey] == allPropertyKey &&
          homeConfigMap[subTypeKey] != propertyCityDataType) {
        String key = UtilityMethods.getSearchKey(homeConfigMap[subTypeKey]);
        String value = homeConfigMap[subTypeValueKey];
        Map<String, dynamic> dataMap = {};
        if(value != allString && value.isNotEmpty){
          dataMap = {key: value};
        }
        Map<String, dynamic> tempMap = await _propertyBloc.fetchFilteredArticles(dataMap);
        tempList.addAll(tempMap["result"]);
      }

      /// Fetch latest and city selected properties (old)
      else if (homeConfigMap[sectionTypeKey] == allPropertyKey && homeConfigMap[subTypeKey] == propertyCityDataType) {
        Map map = HiveStorageManager.readSelectedCityInfo();
        if (map.isNotEmpty && map[CITY_ID] != null) {
          homeConfigMap[subTypeValueKey] = map[CITY_ID].toString();
          if (homeConfigMap[titleKey] != "Please Select") {
            homeConfigMap[titleKey] = "";
            homeConfigMap[titleKey] = UtilityMethods.getLocalizedString(
                "latest_properties_in_city",inputWords: [map[CITY]]);
          }
        }
        if (homeConfigMap[subTypeValueKey] == userSelectedString || homeConfigMap[subTypeValueKey] == ""
            || homeConfigMap[subTypeValueKey] == allString) {
          tempList = await _propertyBloc.fetchLatestArticles(page);
        } else {
          int id = int.parse(homeConfigMap[subTypeValueKey]);
          tempList = await _propertyBloc.fetchPropertiesInCityList(id, page, 16);
        }
      }

      /// Fetch Properties
      else if (homeConfigMap[sectionTypeKey] == propertyKey) {
        Map<String, dynamic> dataMap = {};

        if(homeConfigMap[subTypeKey] == propertyCityDataType &&
            homeConfigMap[subTypeValueKey] == userSelectedString) {

          Map? map = HiveStorageManager.readSelectedCityInfo();
          if (map.isNotEmpty && map[CITY_ID] != null) {
            if (homeConfigMap[titleKey] != "Please Select") {
              homeConfigMap[titleKey] = "";
              homeConfigMap[titleKey] = UtilityMethods.getLocalizedString(
                  "latest_properties_in_city", inputWords: [map[CITY]]);
            }
            String citySlug = map[CITY_SLUG] ?? "";
            if (citySlug.isNotEmpty) {
              dataMap[SEARCH_RESULTS_LOCATION] = citySlug;
              setRouteRelatedDataMap[CITY_SLUG] = map[CITY_SLUG];
              setRouteRelatedDataMap[CITY] = map[CITY];
            }
          }else{
            setRouteRelatedDataMap[CITY] = allCapString;
          }
        }

        if(homeConfigMap.containsKey(searchApiMapKey) && homeConfigMap.containsKey(searchRouteMapKey) &&
            (homeConfigMap[searchApiMapKey] != null) && (homeConfigMap[searchRouteMapKey] != null)){
          dataMap.addAll(homeConfigMap[searchApiMapKey]);
          setRouteRelatedDataMap.addAll(homeConfigMap[searchRouteMapKey]);
        }
        else if(homeConfigMap.containsKey(subTypeListKey) && homeConfigMap.containsKey(subTypeValueListKey) &&
            (homeConfigMap[subTypeListKey] != null && homeConfigMap[subTypeListKey].isNotEmpty) &&
            (homeConfigMap[subTypeValueListKey] != null && homeConfigMap[subTypeValueListKey].isNotEmpty)){
          List subTypeList = homeConfigMap[subTypeListKey];
          List subTypeValueList = homeConfigMap[subTypeValueListKey];
          for(var item in subTypeList){
            if(item != allString){
              String searchKey = UtilityMethods.getSearchKey(item);
              String searchItemNameFilterKey = UtilityMethods.getSearchItemNameFilterKey(item);
              String searchItemSlugFilterKey = UtilityMethods.getSearchItemSlugFilterKey(item);
              List value = UtilityMethods.getSubTypeItemRelatedList(item, subTypeValueList);
              if(value.isNotEmpty && value[0].isNotEmpty) {
                dataMap[searchKey] = value[0];
                setRouteRelatedDataMap[searchItemSlugFilterKey] = value[0];
                setRouteRelatedDataMap[searchItemNameFilterKey] = value[1];
              }
            }
          }
        }
        else{
          String key = UtilityMethods.getSearchKey(homeConfigMap[subTypeKey]);
          String searchItemNameFilterKey = UtilityMethods.getSearchItemNameFilterKey(homeConfigMap[subTypeKey]);
          String searchItemSlugFilterKey = UtilityMethods.getSearchItemSlugFilterKey(homeConfigMap[subTypeKey]);
          String value = homeConfigMap[subTypeValueKey] ?? "";
          if(value.isNotEmpty && value != allString && value != userSelectedString){
            dataMap = {key: [value]};
            String itemName = UtilityMethods.getPropertyMetaDataItemNameWithSlug(dataType: homeConfigMap[subTypeKey], slug: value);
            setRouteRelatedDataMap[searchItemSlugFilterKey] = [value];
            setRouteRelatedDataMap[searchItemNameFilterKey] = [itemName];
          }
        }

        if(homeConfigMap[showFeaturedKey] ?? false){
          dataMap[SEARCH_RESULTS_FEATURED] = 1;
          setRouteRelatedDataMap[showFeaturedKey] = true;
        }

        if (homeConfigMap[showNearbyKey] ?? false) {
          if (permissionGranted) {
            Map<String, dynamic> dataMapForNearby = {};
            dataMapForNearby = await UtilityMethods.getMapForNearByProperties();
            dataMap.addAll(dataMapForNearby);
            setRouteRelatedDataMap.addAll(dataMapForNearby);
          } else {
            return [];
          }
        }
        //
        // print("dataMap: $dataMap");
        // print("setRouteRelatedDataMap: $setRouteRelatedDataMap");

        Map<String, dynamic> tempMap = await _propertyBloc.fetchFilteredArticles(dataMap);
        tempList.addAll(tempMap["result"]);
      }


      /// Fetch realtors list
      else if (homeConfigMap[sectionTypeKey] == agenciesKey ||
          homeConfigMap[sectionTypeKey] == agentsKey) {
        if (homeConfigMap[subTypeKey] == REST_API_AGENT_ROUTE) {
          tempList = await _propertyBloc.fetchAllAgentsInfoList(page, 16);
        } else {
          tempList = await _propertyBloc.fetchAllAgenciesInfoList(page, 16);
        }
      }


      /// Fetch Terms
      else if (homeConfigMap[sectionTypeKey] == termKey) {
        if(homeConfigMap.containsKey(subTypeListKey) &&
            (homeConfigMap[subTypeListKey] != null &&
                homeConfigMap[subTypeListKey].isNotEmpty)){
          List subTypeList = homeConfigMap[subTypeListKey];
          if(subTypeList.length == 1 && subTypeList[0] == allString){
            Map<String, dynamic> tempMap = {};
            tempMap = removeRedundantLocationTermsKeys(allTermsList);
            setRouteRelatedDataMap.addAll(tempMap);
            tempList = await _propertyBloc.fetchTermData(allTermsList);
          }else{
            if(subTypeList.contains(allString)){
              subTypeList.remove(allString);
            }
            Map<String, dynamic> tempMap = {};
            tempMap = removeRedundantLocationTermsKeys(subTypeList);
            setRouteRelatedDataMap.addAll(tempMap);
            tempList = await _propertyBloc.fetchTermData(subTypeList);
          }
        }else{
          if(homeConfigMap[subTypeKey] != null && homeConfigMap[subTypeKey].isNotEmpty){
            if(homeConfigMap[subTypeKey] == allString){
              Map<String, dynamic> tempMap = {};
              tempMap = removeRedundantLocationTermsKeys(allTermsList);
              setRouteRelatedDataMap.addAll(tempMap);
              tempList = await _propertyBloc.fetchTermData(allTermsList);
            }else{
              var item = homeConfigMap[subTypeKey];
              String key = UtilityMethods.getSearchItemNameFilterKey(item);
              setRouteRelatedDataMap[key] = [allCapString];
              tempList = await _propertyBloc.fetchTermData(homeConfigMap[subTypeKey]);
            }
          }
        }
      }

      /// Fetch taxonomies
      else if (homeConfigMap[sectionTypeKey] == termWithIconsTermKey) {
        tempList = [1];
      }

      /// Fetch partners list
      else if (homeConfigMap[sectionTypeKey] == partnersKey) {
        tempList = await _propertyBloc.fetchPartnersList();
      }

      else {
        tempList = [];
      }
    } on SocketException {
      throw 'No Internet connection';
    }
    return tempList;
  }

  Map<String, dynamic> removeRedundantLocationTermsKeys(List subTypeList){
    Map<String, dynamic> tempMap = {};
    for(var item in subTypeList){
      String key = UtilityMethods.getSearchItemNameFilterKey(item);
      tempMap[key] = [allCapString];
    }
    List<String> keysList = tempMap.keys.toList();
    if(keysList.isNotEmpty) {
      List<String> intersectionKeysList = locationRelatedList.toSet().intersection((keysList.toSet())).toList();
      if (intersectionKeysList.isNotEmpty && intersectionKeysList.length > 1) {
        for (int i = 1; i < intersectionKeysList.length; i++) {
          String key = intersectionKeysList[i];
          tempMap.remove(key);
        }
      }
    }

    return tempMap;
  }

  bool needToLoadData(Map oldDataMap, Map newDataMap){
    if(oldDataMap[sectionTypeKey] != newDataMap[sectionTypeKey] ||
        oldDataMap[subTypeKey] != newDataMap[subTypeKey] ||
        oldDataMap[subTypeValueKey] != newDataMap[subTypeValueKey]){
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.homeScreenData != homeConfigMap) {
      // Make sure new Home item is Map
      var newHomeConfigMap = widget.homeScreenData;
      if (newHomeConfigMap is! Map) {
        newHomeConfigMap = widget.homeScreenData.toJson();
      }

      if (!(mapEquals(newHomeConfigMap, homeConfigMap))) {
        if (homeConfigMap[sectionTypeKey] != newHomeConfigMap[sectionTypeKey] &&
            newHomeConfigMap[sectionTypeKey] == recentSearchKey) {
          homeScreenList.clear();
          List tempList = HiveStorageManager.readRecentSearchesInfo() ?? [];
          homeScreenList.addAll(tempList);
        } else if (newHomeConfigMap[sectionTypeKey] == adKey) {
          if (SHOW_ADS_ON_HOME) {
            if(!_isNativeAdLoaded){
              setUpNativeAd();
            }

          }
        } else if (newHomeConfigMap[sectionTypeKey] == PLACE_HOLDER_SECTION_TYPE){
          _placeHolderWidget = HooksConfigurations.homeWidgetsHook(
            context,
            newHomeConfigMap[titleKey],
            widget.refresh
          ) ?? Container();
        } else if (needToLoadData(homeConfigMap, newHomeConfigMap)){
          // Update Home Item
          homeConfigMap = newHomeConfigMap;
          loadData();
        }

        // Update Home Item
        homeConfigMap = newHomeConfigMap;
      }
    }

    if(widget.refresh && homeConfigMap[sectionTypeKey] != adKey
        && homeConfigMap[sectionTypeKey] != recentSearchKey
        && homeConfigMap[sectionTypeKey] != PLACE_HOLDER_SECTION_TYPE
    ){
      if(isPageFreeForLoading && mapEquals(widget.selectedItem, widget.homeScreenData)) {
        homeScreenList = [];
        isDataLoaded = false;
        noDataReceived = false;
        isPageFreeForLoading = false;
        // loadData();
        // widget.refresh = false;
      }
    }

    if (widget.refresh &&
        homeConfigMap[sectionTypeKey] == PLACE_HOLDER_SECTION_TYPE) {
      _placeHolderWidget = HooksConfigurations.homeWidgetsHook(
          context,
          homeConfigMap[titleKey],
          widget.refresh
      ) ?? Container();
    }


    // print("homeScreenItem: ${homeConfigMap}");

    return Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          if (homeConfigMap[sectionTypeKey] == allPropertyKey &&
              homeConfigMap[subTypeKey] == propertyCityDataType) {
            Map map = HiveStorageManager.readSelectedCityInfo();
            if (map.isNotEmpty && map[CITY_ID] != null) {
              homeConfigMap[subTypeValueKey] = map[CITY_ID].toString();
              if (homeConfigMap[titleKey] != "Please Select") {
                homeConfigMap[titleKey] = "";
                homeConfigMap[titleKey] = UtilityMethods.getLocalizedString(
                    "latest_properties_in_city",
                    inputWords: [map[CITY]]);
              }
            }
          }

          if(homeConfigMap[sectionTypeKey] == recentSearchKey && homeScreenList.isNotEmpty){
            homeScreenList.removeWhere((element) => element is! Map);
          }

          return noDataReceived
              ? Container()
              : Column(
              children: [
                if (homeConfigMap[sectionTypeKey] == recentSearchKey)
                  homeScreenList.isEmpty
                      ? NoResultErrorWidget(
                          headerErrorText: UtilityMethods.getLocalizedString(
                              "no_result_found"),
                          bodyErrorText: UtilityMethods.getLocalizedString(
                              "no_recent_properties_error_message"),
                          hideGoBackButton: true,
                        )
                      : HomeScreenRecentSearchesWidget(
                          recentSearchesInfoList:
                              HiveStorageManager.readRecentSearchesInfo() ?? [],
                          // listingView: homeScreenWidgetsListingCarouselView,
                          // listingView: homeScreenWidgetsListingListView,
                          listingView: homeConfigMap[sectionListingViewKey] ??
                              homeScreenWidgetsListingListView,
                        ),
                if (homeConfigMap[sectionTypeKey] == adKey &&
                    SHOW_ADS_ON_HOME &&
                    _isNativeAdLoaded)
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    height: 50,
                    child: AdWidget(ad: _nativeAd!),
                  ),
                if (homeConfigMap[sectionTypeKey] == termWithIconsTermKey)
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: TermWithIconsWidget(),
                  ),
                if (homeConfigMap[sectionTypeKey] == allPropertyKey ||
                    homeConfigMap[sectionTypeKey] == propertyKey ||
                    homeConfigMap[sectionTypeKey] == featuredPropertyKey)
                  if (isDataLoaded)
                    genericWidgetWithSeeAllOption(
                      onTap: () => setRouteToNavigate(),
                      widget: PropertiesListingGenericWidget(
                        propertiesList: homeScreenList,
                        design: UtilityMethods.getDesignValue(
                                homeConfigMap[designKey]) ??
                            DESIGN_01,
                        // listingView: homeScreenWidgetsListingCarouselView,
                        // listingView: homeScreenWidgetsListingListView,
                        listingView: homeConfigMap[sectionListingViewKey] ??
                            homeScreenWidgetsListingListView,
                      ),
                    )
                  else
                    genericLoadingWidgetForCarousalWithShimmerEffect(context),
                if (homeConfigMap[sectionTypeKey] == termKey)
                  if (isDataLoaded)
                    ExplorePropertiesWidget(
                      design: UtilityMethods.getDesignValue(
                          homeConfigMap[designKey]),
                      propertiesData: homeScreenList,
                      // listingView: homeScreenWidgetsListingCarouselView,
                      // listingView: homeScreenWidgetsListingListView,
                      listingView: homeConfigMap[sectionListingViewKey] ??
                          homeScreenWidgetsListingListView,
                      explorePropertiesWidgetListener: ({filterDataMap}) {
                        if (filterDataMap != null &&
                            filterDataMap.isNotEmpty) {}
                      },
                    )
                  else
                    genericLoadingWidgetForCarousalWithShimmerEffect(context),
                if (homeConfigMap[sectionTypeKey] == REST_API_AGENCY_ROUTE ||
                    homeConfigMap[sectionTypeKey] == REST_API_AGENT_ROUTE)
                  if (isDataLoaded &&
                      homeScreenList.isNotEmpty &&
                      homeScreenList[0] is List)
                    genericWidgetWithSeeAllOption(
                        onTap: () => setRouteToNavigate(),
                        widget: RealtorListingsWidget(
                          tag: homeConfigMap[subTypeKey] == REST_API_AGENT_ROUTE
                              ? AGENTS_TAG
                              : AGENCIES_TAG,
                          realtorInfoList: homeScreenList[0],
                          // listingView: homeScreenWidgetsListingCarouselView,
                          // listingView: homeScreenWidgetsListingListView,
                          listingView: homeConfigMap[sectionListingViewKey] ??
                              homeScreenWidgetsListingListView,
                        ))
                  else
                    genericLoadingWidgetForCarousalWithShimmerEffect(context),

                if (homeConfigMap[sectionTypeKey] == PLACE_HOLDER_SECTION_TYPE)
                  _placeHolderWidget,

                if (homeConfigMap[sectionTypeKey] == partnersKey)
                  PartnerWidget(
                    partnersList: homeScreenList,
                    // listingView: LIST_VIEW,
                    // listingView: CAROUSEL_VIEW,
                    listingView: homeConfigMap[sectionListingViewKey] ?? CAROUSEL_VIEW,
                  ),
              ],
            );
    });
  }

  Widget genericWidgetWithSeeAllOption({
    required Widget widget,
    required Function() onTap,
}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        widget,
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(
                left : UtilityMethods.isRTL(context) ? 20 : 0,
                right: UtilityMethods.isRTL(context) ? 0 : 20,
                top: 5,
                bottom: 20
            ),
            child: GenericTextWidget(
              UtilityMethods.getLocalizedString("see_all") + arrowDirection,
              style: AppThemePreferences().appTheme.readMoreTextStyle,
            ),
          ),
        ),
      ],
    );
  }


  setRouteToNavigate() async {
    StatefulWidget Function(dynamic context)? route;
    if (homeConfigMap[sectionTypeKey] == featuredPropertyKey) {
      route = getSearchResultPath(onlyFeatured: true);
    }
    else if (homeConfigMap[sectionTypeKey] == allPropertyKey &&
        homeConfigMap[subTypeKey] != propertyCityDataType) {
      Map<String, dynamic> dataMap = {
        UtilityMethods.getSearchKey(homeConfigMap[subTypeKey]): "",
      };
      route = getSearchResultPath(map: dataMap);
    } else if (homeConfigMap[sectionTypeKey] == propertyKey) {
      route = getSearchResultPath(
        onlyFeatured: setRouteRelatedDataMap[showFeaturedKey] != null
            && setRouteRelatedDataMap[showFeaturedKey] is bool
            && setRouteRelatedDataMap[showFeaturedKey]
            ? true
            : false,
        map: setRouteRelatedDataMap,
      );
    } else if (homeConfigMap[sectionTypeKey] == termKey) {
      route = getSearchResultPath(map: setRouteRelatedDataMap);
    } else if (homeConfigMap[subTypeKey] == agenciesKey) {
      route = (context) => AllAgency();
    } else if (homeConfigMap[subTypeKey] == agentsKey) {
      route = (context) => AllAgents();
    } else if (homeConfigMap[sectionTypeKey] == allPropertyKey &&
        homeConfigMap[subTypeKey] == propertyCityDataType) {
      Map<String, dynamic> dataMap = {};
      Map cityInfoMap = HiveStorageManager.readSelectedCityInfo() ?? {};
      if (cityInfoMap != null && cityInfoMap[CITY_ID] != null) {
        dataMap[CITY_SLUG] = cityInfoMap[CITY_SLUG];
        dataMap[CITY] = cityInfoMap[CITY];
      }else{
        dataMap[CITY] = allCapString;
      }
      route = getSearchResultPath(map: dataMap);
    } else {
      route = null;
    }
    navigateToRoute(route);
  }

  getSearchResultPath({Map<String, dynamic>? map, bool onlyFeatured = false}){
    return (context) => SearchResult(
      dataInitializationMap: onlyFeatured ? null : map,
      fetchFeatured: onlyFeatured,
      searchPageListener: (Map<String, dynamic> map, String closeOption) {
        if (closeOption == CLOSE) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  navigateToRoute(WidgetBuilder? builder) {
    if (builder != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: builder,
        ),
      );
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}