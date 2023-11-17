import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:houzi_package/blocs/property_bloc.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/files/theme_service_files/theme_notifier.dart';
import 'package:houzi_package/pages/search_result.dart';
import 'package:houzi_package/widgets/app_bar_widget.dart';
import 'package:houzi_package/widgets/saved_searches_widgets/ss_bottom_action_widget.dart';
import 'package:houzi_package/widgets/saved_searches_widgets/ss_loading_widget.dart';
import 'package:houzi_package/widgets/saved_searches_widgets/ss_no_result_found_widget.dart';
import 'package:houzi_package/widgets/saved_searches_widgets/ss_pagination_loading_widget.dart';
import 'package:houzi_package/widgets/saved_searches_widgets/ss_query_items_widget.dart';
import 'package:houzi_package/widgets/saved_searches_widgets/ss_query_options_widget.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:houzi_package/files/generic_methods/general_notifier.dart';

class SavedSearches extends StatefulWidget {
  final bool showAppBar;
  final bool fetchLeadSavedSearches;
  final String? leadId;

  const SavedSearches({
    this.showAppBar = false,
    this.fetchLeadSavedSearches = false,
    this.leadId,
  });

  @override
  _SavedSearchesState createState() => _SavedSearchesState();
}

class _SavedSearchesState extends State<SavedSearches> with AutomaticKeepAliveClientMixin<SavedSearches> {

  bool isInternetConnected = true;
  bool isRefreshing = false;
  bool shouldLoadMore = true;
  bool _isLoading = false;

  int page = 1;
  int perPage = 10;

  Future<List<dynamic>>? _futureSavedSearches;

  List<dynamic> savedSearchesList = [];
  List<dynamic> citiesMetaDataList = [];
  List<dynamic> propertyTypesMetaData = [];
  List<dynamic> propertyStatusMetaData = [];

  VoidCallback? generalNotifierLister;

  final PropertyBloc _propertyBloc = PropertyBloc();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {

    loadData();

    generalNotifierLister = () {
      if (GeneralNotifier().change == GeneralNotifier.NEW_SAVED_SEARCH_ADDED) {
        loadDataFromApi();
      }
    };

    GeneralNotifier().addListener(generalNotifierLister!);

    super.initState();
  }

  loadData(){
    citiesMetaDataList = HiveStorageManager.readCitiesMetaData() ?? [];
    propertyTypesMetaData = HiveStorageManager.readPropertyTypesMetaData() ?? [];
    propertyStatusMetaData = HiveStorageManager.readPropertyStatusMetaData() ?? [];
    loadDataFromApi();

    if (mounted) {
      setState(() {});
    }
  }

  retryLoadData() {
    _isLoading = false;
    loadData();
  }

  loadDataFromApi({bool forPullToRefresh = true}) {
    if (forPullToRefresh) {
      if (_isLoading) {
        return;
      }
      setState(() {
        isRefreshing = true;
        _isLoading = true;
      });

      page = 1;
      _futureSavedSearches = fetchSavedSearches(page);
      _refreshController.refreshCompleted();
    } else {
      if (!shouldLoadMore || _isLoading) {
        _refreshController.loadComplete();
        return;
      }
      setState(() {
        isRefreshing = false;
        _isLoading = true;
      });
      page++;
      _futureSavedSearches = fetchSavedSearches(page);
      _refreshController.loadComplete();

    }

  }

  Future<List<dynamic>> fetchSavedSearches(int page) async {
    List<dynamic> tempList = await _propertyBloc.fetchSavedSearches(
      page, perPage,
      fetchLeadSavedSearches: widget.fetchLeadSavedSearches,
      leadId: widget.leadId,
    );
    if (tempList == null ||
        (tempList.isNotEmpty && tempList[0] == null) ||
        (tempList.isNotEmpty && tempList[0].runtimeType == Response)) {
      if (mounted) {
        setState(() {
          isInternetConnected = false;
          shouldLoadMore = false;
        });
      }
      return savedSearchesList;
    } else {
      if (mounted) {
        setState(() {
          isInternetConnected = true;
          shouldLoadMore = false;
        });
      }
      if (page == 1) {
        savedSearchesList.clear();
      }
      if (tempList.isNotEmpty) {
        savedSearchesList.addAll(tempList);
      }
    }

    return savedSearchesList;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) {
        return Scaffold(
          appBar: widget.showAppBar
              ? AppBarWidget(
            appBarTitle:
            UtilityMethods.getLocalizedString("saved_searches"),
          )
              : null,
          body: Stack(
            children: [
              // showSavedSearchList(context, _futureSavedSearches!),
              SavedSearchesListWidget(
                showAppBar: widget.showAppBar,
                shouldLoadMore: shouldLoadMore,
                onRefresh: loadDataFromApi,
                onLoading: () => loadDataFromApi(forPullToRefresh: false),
                refreshController: _refreshController,
                futureSavedSearchesList: _futureSavedSearches!,
                getQueryMap: getUrlMap,
                listener: ({isLoading, itemIndex}) {
                  if(isLoading != null){
                    _isLoading = isLoading;
                  }

                  if (itemIndex != null) {
                    if (mounted) {
                      setState(() {
                        savedSearchesList.removeAt(itemIndex);
                        if (savedSearchesList.isEmpty) {
                          savedSearchesList.clear();
                        }
                      });
                    }
                  }
                },
              ),
              if (_refreshController.isLoading)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: SavedSearchPaginationLoadingWidget(),
                ),
              SavedSearchBottomActionWidget(
                isInternetConnected: isInternetConnected,
                onPressed: () => retryLoadData(),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> getUrlMap(String query) {
    Map<String, dynamic> queryMap = {};
    if (query.isNotEmpty) {
      String cleanContent =
      UtilityMethods.cleanContent(query, decodeComponent: true);

      // print("cleanContent: $cleanContent");

      final split = cleanContent.split('&');

      for (var element in split) {
        final splitString = element.split("=");
        String key = "";
        String value = "";

        if (splitString.isNotEmpty) {
          key = splitString[0].trim();
          if (splitString.length > 1) {
            value = splitString[1].trim();
          }
        }

        switch (key) {
          case (BATHROOMS): {
            List tempList = [];
            if (value.contains(",")) {
              tempList = value.split(",");
            } else {
              tempList.add(value);
            }
            queryMap[key] = tempList;
            break;
          }

          case (BEDROOMS): {
            List tempList = [];
            if (value.contains(",")) {
              tempList = value.split(",");
            } else {
              tempList.add(value);
            }
            queryMap[key] = tempList;
            break;
          }

          case (SEARCH_RESULTS_MAX_AREA): {
            queryMap[AREA_MAX] = value;
            break;
          }

          case (SEARCH_RESULTS_MIN_AREA): {
            queryMap[AREA_MIN] = value;
            break;
          }

          case (SAVE_SEARCH_MAX_AREA): {
            queryMap[AREA_MAX] = value;
            break;
          }

          case (SAVE_SEARCH_MIN_AREA): {
            queryMap[AREA_MIN] = value;
            break;
          }

          case (SEARCH_RESULTS_MAX_PRICE): {
            queryMap[PRICE_MAX] = value;
            break;
          }

          case (SEARCH_RESULTS_MIN_PRICE): {
            queryMap[PRICE_MIN] = value;
            break;
          }

          case (SAVE_SEARCH_MIN_PRICE): {
            queryMap[PRICE_MIN] = value;
            break;
          }

          case (SAVE_SEARCH_MAX_PRICE): {
            queryMap[PRICE_MAX] = value;
            break;
          }

          case ("location[0]"): {
            queryMap[CITY_SLUG] = value;
            queryMap[CITY] = getCityName(value);
            queryMap[CITY_ID] = getCityId(queryMap[CITY]);
            // queryMap[PRICE_MAX] = value;
            break;
          }

          case (metaKeyFiltersKey): {
            String _metaKeyFiltersJson = value;

            // remove back-slashes
            _metaKeyFiltersJson = _metaKeyFiltersJson.replaceAll("\\", "");

            // decode json
            dynamic _decodedJson = jsonDecode(_metaKeyFiltersJson);

            // extract required data
            if (_decodedJson is Map) {
              Map<String, dynamic> _metaQueryMap = {};
              Map<String, dynamic> _metaMap = Map<String, dynamic>.from(_decodedJson);

              // print("Received Saved Searches Map: $_metaMap");

              if (_metaMap[metaKeyFiltersKey] is List
                  && _metaMap[metaKeyFiltersKey].isNotEmpty) {

                List<Map> _metaMapsList = List<Map>.from(_metaMap[metaKeyFiltersKey]);

                for (Map metaQueryItem in _metaMapsList) {
                  String apiKey = metaQueryItem[metaApiKey];
                  String _value = metaQueryItem[metaValueKey] ?? "";

                  if ( _value.isNotEmpty ) {
                    _value = _value.replaceAll("+", ""); // remove '+'
                    _value = _value.replaceAll(" ", ""); // remove white-spaces
                    metaQueryItem[metaValueKey] = _value;
                  }

                  switch (apiKey) {

                    case (favPropertyBedroomsKey): {
                      queryMap.remove(BEDROOMS);
                      break;
                    }

                    case (favPropertyBathroomsKey): {
                      queryMap.remove(BATHROOMS);
                      break;
                    }

                    case (favPropertyPriceKey): {
                      queryMap.remove(PRICE_MAX);
                      queryMap.remove(PRICE_MIN);
                      break;
                    }

                    case (favPropertySizeKey): {
                      queryMap.remove(AREA_MAX);
                      queryMap.remove(AREA_MIN);
                      break;
                    }

                    case (favPropertyGarageKey): {
                      queryMap.remove(SAVE_SEARCH_GARAGE);
                      break;
                    }

                    case (favPropertyYearKey): {
                      queryMap.remove(SAVE_SEARCH_YAER_BUILT);
                      break;
                    }

                    default : {
                      break;
                    }
                  }

                  _metaQueryMap[apiKey] = metaQueryItem;
                }

                queryMap[metaKeyFiltersKey] = _metaQueryMap;
              }
            }

            break;
          }

          case (keywordFiltersKey): {
            String _keywordFiltersJson = value;

            // remove back-slashes
            _keywordFiltersJson = _keywordFiltersJson.replaceAll("\\", "");

            // decode json
            dynamic _decodedJson = jsonDecode(_keywordFiltersJson);

            // extract required data
            if (_decodedJson is Map) {
              Map<String, dynamic> _keywordFiltersQueryMap = {};
              Map<String, dynamic> _keywordFiltersMap = Map<String, dynamic>.from(_decodedJson);

              // print("Received Saved Searches Map: _keywordFiltersMap");

              if (_keywordFiltersMap[keywordFiltersKey] is List
                  && _keywordFiltersMap[keywordFiltersKey].isNotEmpty) {

                List<Map> _keywordFiltersMapsList = List<Map>.from(_keywordFiltersMap[keywordFiltersKey]);

                for (Map keywordFiltersQueryItem in _keywordFiltersMapsList) {
                  String _uniqueId = keywordFiltersQueryItem[keywordFiltersUniqueIdKey];
                  _keywordFiltersQueryMap[_uniqueId] = keywordFiltersQueryItem;
                }

                queryMap[keywordFiltersKey] = _keywordFiltersQueryMap;
              }
            }

            break;
          }

          default: {
            if (key.isNotEmpty && value.isNotEmpty && key != "page"
                && key != "per_page") {
              value = UtilityMethods.cleanContent(value, decodeComponent: true);
              queryMap[key] = value;
            }
          }
        }
      }

      String? priceMin = queryMap[PRICE_MIN];
      String? priceMax = queryMap[PRICE_MAX];
      String price = "";

      if (priceMin != null && priceMin.isNotEmpty) {
        price = price + priceMin;
      }
      if (priceMin != null && priceMin.isNotEmpty &&
          priceMax != null && priceMax.isNotEmpty) {
        price = price + " - ";
      }
      if(priceMax != null && priceMax.isNotEmpty){
        price = price + "$priceMax";
      }
      if(price.isNotEmpty){
        queryMap[QUERY_PRICE] = price;
      }

      var areaMin = queryMap[AREA_MIN];
      var areaMax = queryMap[AREA_MAX];
      String area = "";
      if (areaMin != null && areaMin.isNotEmpty) {
        area = area + "$areaMin";
      }
      if (areaMin != null && areaMin.isNotEmpty &&
          areaMax != null && areaMax.isNotEmpty) {
        area = area + " - ";
      }
      if(areaMax != null && areaMax.isNotEmpty){
        area = area + "$areaMax";
      }
      if(area.isNotEmpty){
        queryMap[QUERY_AREA] = area;
      }

      List statusSlugList = [];
      queryMap.forEach((key, value) {
        if (key.contains("status")) {
          statusSlugList.add(value);
        }
      });
      List<String> statusSlugs = [];
      List<String> statusTerms = [];
      if (statusSlugList.isNotEmpty) {
        for (String statusTerm in statusSlugList) {
          String statusSlug = getStatusName(statusTerm);
          if (statusSlug.isNotEmpty) {
            statusSlugs.add(statusSlug);
          }
          statusTerms.add(UtilityMethods.getLocalizedString(statusTerm));
        }
        queryMap[PROPERTY_STATUS_SLUG] = statusTerms;
        queryMap[PROPERTY_STATUS] = statusSlugs;
        if (queryMap[PROPERTY_STATUS].isNotEmpty) {
          queryMap["query_status"] = queryMap[PROPERTY_STATUS][0];
        }
      }

      List typeSlugList = [];
      queryMap.forEach((key, value) {
        if (key.contains("type")) {
          typeSlugList.add(value);
        }
      });

      if (typeSlugList.isNotEmpty) {
        List<String> queryTypeList = [];
        for (int i = 0; i < typeSlugList.length; i++) {
          queryTypeList.add(UtilityMethods.getLocalizedString(typeSlugList[i]));
        }

        List<dynamic> _selectedTitleList = [];
        List<dynamic> _selectedTitleSlugList = [];
        List<dynamic> _selectedOptionList = [];
        List<dynamic> _selectedOptionSlugList = [];

        for (int i = 0; i < typeSlugList.length; i++) {
          int itemIndex = propertyTypesMetaData
              .indexWhere((element) => element.slug == typeSlugList[i]);
          if (itemIndex != -1) {
            //it might be a parent category.
            int? parentId = propertyTypesMetaData[itemIndex].parent;
            if (parentId != null && parentId == 0) {
              String? title = propertyTypesMetaData[itemIndex].name;
              String? slug = propertyTypesMetaData[itemIndex].slug;
              if(title != null) _selectedTitleList.add(title);
              if(slug != null) _selectedTitleSlugList.add(slug);
            }
            //add type name and slug to the lists.
            String? option = propertyTypesMetaData[itemIndex].name;
            if (option != null && option.isNotEmpty) {
              _selectedOptionList.add(option);
            }
            String? slug = propertyTypesMetaData[itemIndex].slug;
            if (slug != null && slug.isNotEmpty) {
              _selectedOptionSlugList.add(slug);
            }
          }
        }
        //find parent category of selected types from meta data.
        if (_selectedTitleList.isEmpty && _selectedOptionSlugList.isNotEmpty) {
          for (int i = 0; i < _selectedOptionSlugList.length; i++) {
            int itemIndex = propertyTypesMetaData.indexWhere(
                    (element) => element.slug == _selectedOptionSlugList[i]);
            if (itemIndex != -1) {
              int? parentId = propertyTypesMetaData[itemIndex].parent;
              if(parentId != null){
                itemIndex = propertyTypesMetaData
                    .indexWhere((element) => element.id == parentId);
                if (itemIndex != -1) {
                  String? title = propertyTypesMetaData[itemIndex].name;
                  String? slug = propertyTypesMetaData[itemIndex].slug;
                  if(title != null) _selectedTitleList.add(title);
                  if(slug != null) _selectedTitleSlugList.add(slug);
                }
              }
            }
          }
        }

        if (queryTypeList.isNotEmpty) {
          queryMap[QUERY_TYPE] = queryTypeList.join(", ");
        }
        //if we've found selected parent category, then append this to selected option
        //array, because our filter widget consider the first item to be a parent (tabs)
        //and all subsequent items as child (chips).
        if (_selectedTitleList.isNotEmpty && _selectedTitleSlugList.isNotEmpty) {
          // remove the item if already at another index
          _selectedOptionList.remove(_selectedTitleList.first);
          _selectedOptionList.insert(0, _selectedTitleList.first);

          // remove the item-slug if already at another index
          _selectedOptionSlugList.remove(_selectedTitleSlugList.first);
          _selectedOptionSlugList.insert(0, _selectedTitleSlugList.first);
        }
        if (_selectedOptionSlugList.isNotEmpty) {
          queryMap[PROPERTY_TYPE_SLUG] = _selectedOptionSlugList;
        }
        if (_selectedOptionList.isNotEmpty) {
          queryMap[PROPERTY_TYPE] = _selectedOptionList;
        }
        if (queryMap[PROPERTY_TYPE] != null && queryMap[PROPERTY_TYPE].isNotEmpty) {
          queryMap["query_type"] = queryMap[PROPERTY_TYPE][0];
        }
      }
    }

    if (queryMap.isEmpty) {
      queryMap[TEMP_TITLE] = UtilityMethods.getLocalizedString("latest_properties");
    }

    return queryMap;
  }

  String getStatusName(String status) {
    int itemIndex = propertyStatusMetaData.indexWhere((element) => element.slug == status);
    if (itemIndex != -1) {
      String name = propertyStatusMetaData[itemIndex].name ?? "";
      if (name.isNotEmpty) {
        return name;
      }
    }
    return "";
  }

  String getCitySlug(String city) {
    if (citiesMetaDataList.isNotEmpty) {
      String title = city;
      int index =
      citiesMetaDataList.indexWhere((element) => element.name == title);
      if (index != null && index != -1) {
        String slug = citiesMetaDataList[index].slug;
        if (slug != null && slug.isNotEmpty) {
          return slug;
        }
      }
    }

    return "";
  }

  String getCityName(String city) {
    if (citiesMetaDataList.isNotEmpty) {
      String title = city;
      int index =
      citiesMetaDataList.indexWhere((element) => element.slug == title);
      if (index != null && index != -1) {
        String slug = citiesMetaDataList[index].name;
        if (slug != null && slug.isNotEmpty) {
          return slug;
        }
      }
    }

    return "";
  }

  int getCityId(String city) {
    String title = city;
    int index =
    citiesMetaDataList.indexWhere((element) => element.name == title);
    if (index != null && index != -1) {
      int id = citiesMetaDataList[index].id;
      if (id != null) {
        return id;
      }
    }
    return -1;
  }

  String getStatusSlug(String status) {
    int itemIndex =
    propertyStatusMetaData.indexWhere((element) => element.name == status);
    if (itemIndex != null && itemIndex != -1) {
      String slug = propertyStatusMetaData[itemIndex].slug;
      if (slug != null && slug.isNotEmpty) {
        return slug;
      }
    }
    return "";
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

typedef SavedSearchesListWidgetListener = Function({
bool? isLoading,
int? itemIndex,
});

class SavedSearchesListWidget extends StatelessWidget {
  final bool showAppBar;
  final bool shouldLoadMore;
  final Future<List<dynamic>> futureSavedSearchesList;
  final RefreshController refreshController;
  final void Function()? onRefresh;
  final void Function()? onLoading;
  final Map<String, dynamic> Function(String) getQueryMap;

  final SavedSearchesListWidgetListener listener;

  const SavedSearchesListWidget({
    Key? key,
    required this.showAppBar,
    required this.shouldLoadMore,
    required this.futureSavedSearchesList,
    required this.refreshController,
    required this.onRefresh,
    required this.onLoading,
    required this.getQueryMap,

    required this.listener,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: futureSavedSearchesList,
      builder: (context, articleSnapshot) {
        listener(isLoading: false);
        if (articleSnapshot.hasData) {

          if (articleSnapshot.data!.isEmpty) {
            return SavedSearchNoResultFoundWidget(showAppBar: showAppBar);
          }

          List<dynamic> list = articleSnapshot.data!;
          return SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus? mode) {
                Widget body = Container();
                if (mode == LoadStatus.loading) {
                  if (shouldLoadMore) {
                    body = const SavedSearchPaginationLoadingWidget();
                  } else {
                    body = Container();
                  }
                }
                return SizedBox(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            header: const MaterialClassicHeader(),
            controller: refreshController,
            onRefresh: onRefresh,
            onLoading: onLoading,
            child: ListView.builder(
              itemCount: list.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var item = list[index];
                String id = item.id;
                String url = item.url ?? "";
                Map<String, dynamic> queryMap = getQueryMap(url);
                return queryMap.isNotEmpty
                    ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: (() {
                          HiveStorageManager.storeFilterDataInfo(map: queryMap);
                          NavigateToSearchResultScreen(
                            context: context,
                            dataInitializationMap: queryMap,
                          );
                        }),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: AppThemePreferences.roundedCorners(
                              AppThemePreferences
                                  .globalRoundedCornersRadius),
                          elevation:
                          AppThemePreferences.savedSearchElevation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: SearchIconWidget(),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: QueryDataWidget(queryDataMap: queryMap),
                                ),
                                Expanded(
                                  flex: 1,
                                  // child: Container(),
                                  child: QueryOptionsWidget(
                                    queryDataMap: queryMap,
                                    queryItemID: id,
                                    queryItemIndex: index,
                                    listener: ({queryItemIndex}) {
                                      if(queryItemIndex != null){
                                        listener(itemIndex: queryItemIndex);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (index == list.length - 1 && !showAppBar)
                      SizedBox(
                        height: 50,
                      )
                  ],
                )
                    : Container();
              },
            ),
          );
        } else if (articleSnapshot.hasError) {
          return SavedSearchNoResultFoundWidget(showAppBar: showAppBar);
        }
        return SavedSearchLoadingIndicatorWidget();
      },
    );
  }

  void NavigateToSearchResultScreen({
    required BuildContext context,
    required Map<String, dynamic> dataInitializationMap,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResult(
          dataInitializationMap: dataInitializationMap,
          searchPageListener: (Map<String, dynamic> map, String closeOption) {
            if (closeOption == CLOSE) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }
}

class SearchIconWidget extends StatelessWidget {
  const SearchIconWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppThemePreferences.zeroElevation,
      shape: AppThemePreferences.roundedCorners(
        AppThemePreferences.savedPageSearchIconRoundedCornersRadius,
      ),
      color: AppThemePreferences().appTheme.containerBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 25, 15, 25),
        child: Icon(
          AppThemePreferences.searchIcon,
          color: AppThemePreferences.savedSearchDefaultIconColor,
          size: AppThemePreferences.savedPageSearchIconSize,
        ),
      ),
    );
  }
}

class QueryDataWidget extends StatelessWidget {
  final Map<String, dynamic> queryDataMap;

  const QueryDataWidget({
    Key? key,
    required this.queryDataMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          QueryTermsDetailsWidget(queryDataMap: queryDataMap),
          SizedBox(height: 10),
          QueryFeaturesDetailsWidget(queryDataMap: queryDataMap),
        ],
      ),
    );
  }
}