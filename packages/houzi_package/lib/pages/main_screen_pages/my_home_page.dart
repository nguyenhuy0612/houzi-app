import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houzi_package/blocs/property_bloc.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/general_notifier.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/files/theme_service_files/theme_notifier.dart';
import 'package:houzi_package/pages/add_property_v2/add_property_v2.dart';
import 'package:houzi_package/providers/state_providers/user_log_provider.dart';
import 'package:houzi_package/pages/demo_expired.dart';
import 'package:houzi_package/pages/home_page_screens/home_screen.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/add_property.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/saved.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/user_related/user_profile.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/user_related/user_signin.dart';
import 'package:houzi_package/pages/main_screen_pages/loading_page.dart';
import 'package:houzi_package/widgets/bottom_nav_bar_widgets/bottom_navigation_bar.dart';
import 'package:houzi_package/widgets/toast_widget.dart';
import 'package:provider/provider.dart';

import 'package:houzi_package/pages/filter_page.dart';
import 'package:houzi_package/pages/search_result.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int homePageIndex = 0;
  int searchPageIndex = 1;
  int savedOrFavSearchesPageIndex = 2;
  int _selectedIndex = 0;
  int page = 1;
  int perPage = 16;
  int bedrooms = 0;
  int bathrooms = 0;
  int? totalResults;

  DateTime? currentBackPressTime;

  List<dynamic> recentSearchesInfoList = [];
  List<Widget> pageList = <Widget>[];

  bool hasInternet = true;
  bool isUserLoggedIn = false;
  bool filterDataLoaded = false;
  bool recentSearchesDataLoaded = false;

  Map<String, dynamic> currentRecentSearchItem = {};
  Map<String, dynamic> previousRecentSearchItem = {};
  Map<String, dynamic> bottomNavBarItemsMap = {};

  VoidCallback? generalNotifierListener;

  Random random = Random();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    bottomNavBarItemsMap = {
      "home" : AppThemePreferences.homeIcon,
      "search" : AppThemePreferences.searchIcon,
      "saved" : AppThemePreferences.savedSearchesIcon,
      "profile" : AppThemePreferences.personIcon,
    };

    checkDemoAndVerify();
    AppThemePreferences().dark(ThemeNotifier().isDarkMode());
    ThemeNotifier().addListener(() {
      AppThemePreferences().dark(ThemeNotifier().isDarkMode());
    });

    Map tempFilterDataMap = HiveStorageManager.readFilterDataInfo() ?? {};
    if(tempFilterDataMap.containsKey(SEARCH_COUNT) && tempFilterDataMap[SEARCH_COUNT] is int){
      totalResults = tempFilterDataMap[SEARCH_COUNT];
    }

    getHomeScreenDesign();
    pageList.add(HomeScreen().getHomeScreen(
      scaffoldKey: _scaffoldKey,
      design: HOME_SCREEN_DESIGN,
    ));
    // pageList.add(Home(scaffoldKey: _scaffoldKey));
    pageList.add(LoadingPage());
    pageList.add(LoadingPage());
    pageList.add(UserProfile(fromBottomNavigator: true));

    if (Provider.of<UserLoggedProvider>(context, listen: false).isLoggedIn!) {
      isUserLoggedIn = true;
      // if (TOUCH_BASE_PAYMENT_ENABLED_STATUS != "no") {
        PropertyBloc().fetchUserPaymentStatus().then((value) {
          if (value.isNotEmpty) {
            HiveStorageManager.storeUserPaymentStatus(value);
            GeneralNotifier().publishChange(GeneralNotifier.USER_PAYMENT_STATUS_UPDATED);
          }
          return null;
        });
      // }
    }

    if(mounted){
      setState(() {
        setSavedSearchesOrFavouritesPage();
      });
    }

    /// General Notifier Listener
    generalNotifierListener = () {
      if (GeneralNotifier().change == GeneralNotifier.FILTER_DATA_LOADING_COMPLETE) {
        debugPrint("Filter Page Data Loaded/Modified...");
        Map tempFilterDataMap = HiveStorageManager.readFilterDataInfo() ?? {};
        if(mounted){
          setState(() {
            if(tempFilterDataMap.containsKey(SEARCH_COUNT) && tempFilterDataMap[SEARCH_COUNT] is int){
              totalResults = tempFilterDataMap[SEARCH_COUNT];
            }
            filterDataLoaded = true;
            setSearchPage();
          });
        }
        tempFilterDataMap.clear();
      }

      if (GeneralNotifier().change == GeneralNotifier.USER_LOGGED_IN){
        debugPrint("User Logged In...");
        if(mounted){
          setState(() {
            isUserLoggedIn = true;
            setSavedSearchesOrFavouritesPage();
          });
        }
      }

      if (GeneralNotifier().change == GeneralNotifier.USER_LOGGED_OUT){
        debugPrint("User Logged Out...");
        if(mounted){
          setState(() {
            isUserLoggedIn = false;
            setSavedSearchesOrFavouritesPage();
          });
        }
      }

      if (GeneralNotifier().change == GeneralNotifier.DEEP_LINK_RECEIVED){
        if(mounted){
          setState(() {
            navigateToPropertyDetailPage(DEEP_LINK);
            DEEP_LINK = "";
          });
        }
      }

      if (GeneralNotifier().change == GeneralNotifier.CHANGE_LOCALIZATION) {
        if(mounted){
          setState(() {
            pageList.removeLast();
            pageList.add(UserProfile(fromBottomNavigator: true));
          });
        }
      }

      if (GeneralNotifier().change == GeneralNotifier.HOME_DESIGN_MODIFIED) {
        debugPrint("Home Design Modified...");
        getHomeScreenDesign();
        if(mounted){
          setState(() {
            setHomePage();
          });
        }
      }
    };

    GeneralNotifier().addListener(generalNotifierListener!);

    List<dynamic> _draftPropertiesList = [];
    _draftPropertiesList = HiveStorageManager.readDraftPropertiesDataMapsList() ?? [];
    // print("_draftPropertiesList: $_draftPropertiesList");
    if(_draftPropertiesList.isNotEmpty){
      // print("Found Some draft properties...");
      int index = -1;
      Map mapItem = {};
      for(Map item in _draftPropertiesList){
        if(item.containsKey(ADD_PROPERTY_DRAFT_PROGRESS_KEY)){
          // print("ItemMap contains Key: $ADD_PROPERTY_DRAFT_PROGRESS_KEY...");
          if(item[ADD_PROPERTY_DRAFT_PROGRESS_KEY] == ADD_PROPERTY_DRAFT_IN_PROGRESS){
            // print("Key: $ADD_PROPERTY_DRAFT_PROGRESS_KEY Matched...");
            mapItem = item;
            index = _draftPropertiesList.indexOf(item);
            // print("Breaking the loop...................");
            break;
          }
        }
      }
      // print("index: $index");
      // print("mapItem: $mapItem");

      if(mapItem.isNotEmpty){
        // print("mapItem Not-Null and Not-Empty...................");
        // print("Map Contains key [$ADD_PROPERTY_DRAFT_PROGRESS_KEY]: ${mapItem.containsKey(ADD_PROPERTY_DRAFT_PROGRESS_KEY)}");
        mapItem.remove(ADD_PROPERTY_DRAFT_PROGRESS_KEY);
        // print("Key: $ADD_PROPERTY_DRAFT_PROGRESS_KEY Removed...");
        // print("Map Contains key [$ADD_PROPERTY_DRAFT_PROGRESS_KEY]: ${mapItem.containsKey(ADD_PROPERTY_DRAFT_PROGRESS_KEY)}");
        if(index != -1){
          // print("Found Some Editable draft properties...");
          // Update Storage
          // print("Updating Storage at index: $index");
          _draftPropertiesList[index] = mapItem;
          HiveStorageManager.storeDraftPropertiesDataMapsList(_draftPropertiesList);
          // print("Opening Add Property Page...");
          navigateToAddPropertyPage(map: UtilityMethods.convertMap(mapItem), index: index);
        }
      }
    }
  }

  navigateToPropertyDetailPage(deepLink){
    if (deepLink == null || deepLink.isEmpty) return;
    Future.delayed(Duration.zero, () {
      UtilityMethods.navigateToPropertyDetailPage(
        context: context, permaLink: deepLink, heroId: "1",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _selectedIndex,
          children: pageList,
        ),
        bottomNavigationBar: BottomNavigationBarWidget(
          design: BOTTOM_NAVIGATION_BAR_DESIGN,
          currentIndex: _selectedIndex,
          itemsMap: bottomNavBarItemsMap,
          onTap: _onItemTapped,
          backgroundColor: AppThemePreferences().appTheme.bottomNavBarBackgroundColor,
          selectedItemColor: AppThemePreferences.bottomNavBarTintColor,
          unselectedItemColor: AppThemePreferences.unSelectedBottomNavBarTintColor,
        ),
      ),
      );
  }

  Future<bool> onWillPop() {
    if(_selectedIndex != 0){
      setState(() {
        _selectedIndex = 0;
      });
      return Future.value(false);
    }
    if(_selectedIndex == 0) {
      if (_scaffoldKey.currentState!.isDrawerOpen) {
        Navigator.of(context).pop();
        return Future.value(false);
      }

      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
        currentBackPressTime = now;
        _showToastToExitApp(context);
        return Future.value(false);
      }
    }
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
    return Future.value(true);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // if(_selectedIndex == searchPageIndex && totalResults != null && totalResults == 0){
      //   filterDataLoaded = true;
      //   setSearchPage();
      // }
    });
  }

  _showToastToExitApp(BuildContext context) {
    ShowToastWidget(
      buildContext: context,
      text: UtilityMethods.getLocalizedString("press_again_to_exit"),
    );
  }

  checkDemoAndVerify() async {
    if(!APP_IS_IN_CLIENT_DEMO_MODE) {
      return;
    }
    var dio = Dio();
    Response<String> response = await dio.get('https://raw.githubusercontent.com/AdilSoomro/houzi-app-for-houzez/master/orbit.json');
    Map<String, dynamic>? dataMap = json.decode(response.data!);
    List<dynamic> planets = [];
    if(dataMap != null && dataMap.isNotEmpty){
      planets = dataMap["planet"] ?? [];
    }

    if (planets.isNotEmpty && planets.contains(APP_DEMO_ID)) {
      //everything is fine
      //navigateToDemoExpired();
    } else {
      navigateToDemoExpired();
    }

  }
  navigateToDemoExpired(){
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => DemoExpired()),
            (Route<dynamic> route) => false);
  }

  void getHomeScreenDesign(){
    String tempHomeDesign = HiveStorageManager.readSelectedHomeOption() ?? home0SectionType;
    if(mounted) setState(() {
      if(tempHomeDesign == homeSectionType || tempHomeDesign == home0SectionType){
        HOME_SCREEN_DESIGN = DESIGN_01;
      }else if(tempHomeDesign == home01SectionType){
        HOME_SCREEN_DESIGN = DESIGN_02;
      }else if(tempHomeDesign == home02SectionType){
        HOME_SCREEN_DESIGN = DESIGN_03;
      }else if(tempHomeDesign == home03SectionType){
        HOME_SCREEN_DESIGN = DESIGN_04;
      }
    });

  }

  void setHomePage(){
    loadLoadingPage(homePageIndex);
    pageList[homePageIndex] = HomeScreen().getHomeScreen(
      scaffoldKey: _scaffoldKey,
      design: HOME_SCREEN_DESIGN,
    );
  }

  void setSearchPage(){
    Map<String, dynamic> filterDataMap = HiveStorageManager.readFilterDataInfo() ?? {};
    if(filterDataLoaded && filterDataMap.isNotEmpty &&
        totalResults != null && totalResults! > 0){
      // if(recentSearchesInfoList.isNotEmpty &&
      //     recentSearchesInfoList.first.isNotEmpty && totalResults != null &&
      //     totalResults! > 0){
      //   print("Navigating to Search Page................................................");
        loadLoadingPage(searchPageIndex);
        doSearch(filterDataMap);
      }else{
        // print("Replace Filter Page................................................");
        loadLoadingPage(searchPageIndex);
        loadFilterPage();
      }
      filterDataLoaded = false;
  }
  // void setSearchPage(){
  //   recentSearchesInfoList = HiveStorageManager.readRecentSearchesInfo() ?? [];
  //   if(filterDataLoaded){
  //     if(recentSearchesInfoList.isNotEmpty &&
  //         recentSearchesInfoList.first.isNotEmpty && totalResults != null &&
  //         totalResults! > 0){
  //       print("Recent Searches found, Search Page Navigation()................................................");
  //       // loadLoadingPage(searchPageIndex);
  //       loadRecentSearchResults(recentSearchesInfoList);
  //     }else{
  //       print("Replace Filter Page................................................");
  //       loadLoadingPage(searchPageIndex);
  //       loadFilterPage();
  //     }
  //     filterDataLoaded = false;
  //   }
  // }

  void loadLoadingPage(int pageIndex){
    if(mounted){
      setState(() {
        pageList[pageIndex] = LoadingPage(
          key: ObjectKey(random.nextInt(100)),
          showAppBar: false,
        );
      });
    }
  }

  void loadFilterPage() {
    pageList[searchPageIndex] = SHOW_MAP_INSTEAD_FILTER
        ? SearchResult(
            key: ObjectKey(random.nextInt(100)),
            dataInitializationMap: {},
            searchPageListener: (Map<String, dynamic> map, String closeOption) {
              if (closeOption == CLOSE) {
                //Navigator.of(context).pop();
              }
            },
          )
        : FilterPage(
            key: ObjectKey(random.nextInt(100)),
            mapInitializeData: HiveStorageManager.readFilterDataInfo() ?? {},
            hasBottomNavigationBar: true,
            filterPageListener: (Map<String, dynamic> dataMap, String closeOption) {
              if (closeOption == DONE) {
                var searchResult = SearchResult(
                  hasBottomNavigationBar: true,
                  dataInitializationMap: HiveStorageManager.readFilterDataInfo() ?? {},
                  searchPageListener: (Map<String, dynamic> map, String closeOption) {
                    if (closeOption == CLOSE) {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    }
                    if (map.isNotEmpty && map.containsKey(SEARCH_COUNT)) {
                      if (mounted) {
                        setState(() {
                          totalResults = map[SEARCH_COUNT];
                        });
                      }
                    }
                  },
                );
                if (mounted) {
                  setState(() {
                    pageList[searchPageIndex] = searchResult;
                  });
                }
              } else if (closeOption == CLOSE) {
                if (mounted) {
                  setState(() {
                    _selectedIndex = 0;
                  });
                }
              }
            },
          );
  }

  // void loadRecentSearchResults(List<dynamic> recentSearchesList){
  //   var result = recentSearchesList.first;
  //   /// We get Map<dynamic, dynamic> from Storage, convert it to
  //   /// Map<String, dynamic> as follows:
  //   currentRecentSearchItem = UtilityMethods.convertMap(result);
  //   loadLoadingPage(searchPageIndex);
  //   doSearch(currentRecentSearchItem);
  //   // if(!mapEquals(currentRecentSearchItem, previousRecentSearchItem)){
  //   //   previousRecentSearchItem = currentRecentSearchItem;
  //   //   loadLoadingPage(searchPageIndex);
  //   //   doSearch(currentRecentSearchItem);
  //   // }
  // }

  void doSearch(Map<String, dynamic> mapFromFilterScreen) {
    // Future.delayed(Duration(seconds: 2));
    // loadLoadingPage(searchPageIndex);
    // Future.delayed(Duration(seconds: 5));

    var filteredSearchResult = SearchResult(
      key: ObjectKey(random.nextInt(100)),
      hasBottomNavigationBar: true,
      dataInitializationMap: mapFromFilterScreen,
      searchPageListener: (Map<String, dynamic> map, String closeOption) {
        if(closeOption == CLOSE){
          setState(() {
            _selectedIndex = 0;
          });
        }

        if(map.isNotEmpty && map.containsKey(SEARCH_COUNT)){
          if(mounted) {
            setState(() {
              totalResults = map[SEARCH_COUNT];
            });
          }
        }
      },
    );
    if(mounted){
      setState(() {
        pageList[searchPageIndex] = filteredSearchResult;
      });
    }
  }

  void setSavedSearchesOrFavouritesPage(){
    if (isUserLoggedIn) {
      pageList[savedOrFavSearchesPageIndex] = Saved((String closeOption) {
            if (closeOption == CLOSE) {
              if (mounted) {
                setState(() {
                  _selectedIndex = 0;
                });
              }
            }
          }
      );
    } else {
      pageList[savedOrFavSearchesPageIndex] = UserSignIn(
            (String closeOption) {
          if (closeOption == CLOSE) {
            if (mounted) {
              setState(() {
                _selectedIndex = 0;
              });
            }
          }
        },fromBottomNavigator: true,
      );
    }
  }

  navigateToAddPropertyPage({required Map map, required int index}){
    if (map.isEmpty) return;
    Future.delayed(Duration.zero, () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPropertyV2(
          // builder: (context) => AddProperty(
            draftPropertyIndex: index,
            isDraftProperty: true,
            propertyDataMap: map,
          ),
        ),
      );

    });
  }
}