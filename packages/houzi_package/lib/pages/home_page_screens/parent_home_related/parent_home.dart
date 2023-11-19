import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:houzi_package/blocs/property_bloc.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/generic_methods/general_notifier.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/files/property_manager_files/property_manager.dart';
import 'package:houzi_package/pages/add_property_v2/add_property_v2.dart';
import 'package:houzi_package/providers/state_providers/user_log_provider.dart';
import 'package:houzi_package/pages/home_page_screens/home_screen.dart';
import 'package:houzi_package/pages/home_page_screens/parent_home_related/home_screen_widgets/home_screen_listing_widgets/generic_home_screen_listings.dart';
import 'package:houzi_package/pages/home_page_screens/parent_home_related/home_screen_widgets/home_screen_sliver_app_bar_widgets/home_screen_sliver_app_bar_widget.dart';
import 'package:houzi_package/pages/home_page_screens/parent_home_related/home_screen_widgets/home_screen_drawer_widgets/home_screen_drawer_widget.dart';
import 'package:houzi_package/widgets/button_widget.dart';
import 'package:houzi_package/widgets/no_internet_botton_widget.dart';
import 'package:houzi_package/widgets/toast_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState<T extends Home> extends State<T> {

  bool _isFree = false;
  bool _isLoggedIn = false;
  bool errorWhileDataLoading = false;
  bool needToRefresh = false; //false //true
  
  int? _selectedCityId;
  int? uploadedPropertyId;
  
  String _selectedCity = "";
  String _userImage = "";
  String _userName = "";
  String? _userRole;

  List<dynamic> homeConfigList = [];
  List<dynamic> drawerConfigList = [];
  List<dynamic> propertyStatusListWithData = [];

  Map<String, dynamic> filterDataMap = {};

  VoidCallback? propertyUploadListener;
  VoidCallback? generalNotifierListener;

  final PropertyBloc _propertyBloc = PropertyBloc();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  set scaffoldKey(GlobalKey<ScaffoldState> value) {
    _scaffoldKey = value;
  }

  String get userName => _userName;

  @override
  void initState() {
    super.initState();
    clearMetaData();
    loadData();
    getHomeConfigFile();
    getDrawerConfigFile();
  }

  checkInternetAndLoadData(){
    needToRefresh = true;
    errorWhileDataLoading = false;
    loadData();
    if(mounted){
      setState(() {});
    }
  }

  void loadData(){
    /// Load Data From Storage
    filterDataMap = HiveStorageManager.readFilterDataInfo() ?? {};
    _userRole = HiveStorageManager.getUserRole() ?? "";
    _userName = HiveStorageManager.getUserName() ?? "";
    _userImage = HiveStorageManager.getUserAvatar() ?? "";

    /// General Notifier Listener
    generalNotifierListener = () {
      if (GeneralNotifier().change == GeneralNotifier.USER_PROFILE_UPDATE) {
        if(mounted) {
          setState(() {
            _userName = HiveStorageManager.getUserName() ?? "";
            _userImage = HiveStorageManager.getUserAvatar() ?? "";
          });
        }
      }

      if (GeneralNotifier().change == GeneralNotifier.APP_CONFIGURATIONS_UPDATED) {
        if(mounted) {
          setState(() {
            getHomeConfigFile();
            getDrawerConfigFile();
          });
        }
      }
    };

    /// Property Upload Listener
    propertyUploadListener = () {
      if(mounted) {
        setState(() {
          _isFree = PropertyManager().isPropertyUploaderFree;
          uploadedPropertyId = PropertyManager().uploadedPropertyId;
        });
      }

      if(uploadedPropertyId != null) {
        int propertyId = uploadedPropertyId!;
        ShowToastWidget(
            buildContext: context,
            showButton: true,
            buttonText: UtilityMethods.getLocalizedString("view_property"),
            text: UtilityMethods.getLocalizedString("property_uploaded"),
            toastDuration: 4,
            onButtonPressed: (){
              UtilityMethods.navigateToPropertyDetailPage(
                context: context,
                propertyID: propertyId,
                heroId: '$propertyId$SINGLE',
              );
            }
        );
        PropertyManager().uploadedPropertyId = null;
      }
    };
    PropertyManager().addListener(propertyUploadListener!);

    GeneralNotifier().addListener(generalNotifierListener!);

    if(Provider.of<UserLoggedProvider>(context,listen: false).isLoggedIn ?? false){
      PropertyManager().uploadProperty();
      if(mounted) {
        setState(() {
          _isLoggedIn = true;
        });
      }
    }

    /// Fetch the last selected City Data form Filter Data
    if(filterDataMap.isNotEmpty){
      if(mounted) {
        setState(() {
          if (filterDataMap.containsKey(CITY) && filterDataMap[CITY] != null) {
            if(filterDataMap[CITY] is List && filterDataMap[CITY].isNotEmpty){
              _selectedCity = filterDataMap[CITY][0];
            }else if(filterDataMap[CITY] is String){
              _selectedCity = filterDataMap[CITY];
            }
          }

          if (filterDataMap.containsKey(CITY_ID) && filterDataMap[CITY_ID] != null) {
            if(filterDataMap[CITY_ID] is List && filterDataMap[CITY_ID].isNotEmpty &&
                filterDataMap[CITY_ID][0] is int){
              _selectedCityId = filterDataMap[CITY_ID][0];
            }else if(filterDataMap[CITY_ID] is int){
              _selectedCityId = filterDataMap[CITY_ID];
            }
          }
        });
      }
    }

    loadRemainingData();

  }

  void loadRemainingData() {
    fetchPropertyMetaData().then((value) {
      if(value['response'].runtimeType == Response){
        errorWhileDataLoading = true;
      }else if(value != null && value.isNotEmpty){
        UtilityMethods.updateTouchBaseDataAndConfigurations(value);
      }

      if(needToRefresh){
        GeneralNotifier().publishChange(GeneralNotifier.TOUCH_BASE_DATA_LOADED);
      }

      // needToRefresh = false;
      if(mounted){
        setState(() {});
      }
      return null;
    });
  }

  @override
  void dispose() {
    super.dispose();

    filterDataMap = {};
    if (propertyUploadListener != null) {
      PropertyManager().removeListener(propertyUploadListener!);
    }
    if (generalNotifierListener != null) {
      GeneralNotifier().removeListener(generalNotifierListener!);
    }
  }

  clearMetaData(){
    HiveStorageManager.clearData();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: HomeScreen().getSystemUiOverlayStyle(design: HOME_SCREEN_DESIGN),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          key: _scaffoldKey,
          drawer: HomeScreenDrawerWidget(
            drawerConfigDataList: drawerConfigList,
            userInfoData: {
              USER_PROFILE_NAME : _userName,
              USER_PROFILE_IMAGE : _userImage,
              USER_ROLE : _userRole,
              USER_LOGGED_IN : _isLoggedIn,
            },
            homeScreenDrawerWidgetListener: (bool loginInfo){
              if(mounted){
                setState(() {
                  _isLoggedIn = loginInfo;
                });
              }
            },
          ),
          body: getBodyWidget(),
        ),
      ),
    );
  }

  Widget getSliverAppBarWidget(){
    return HomeScreenSliverAppBarWidget(
      onLeadingIconPressed: () => _scaffoldKey.currentState!.openDrawer(),
      selectedCity: getSelectedCity(),
      selectedStatusIndex: getSelectedStatusIndex(),
      homeScreenSliverAppBarListener: ({filterDataMap}){
        if(filterDataMap != null && filterDataMap.isNotEmpty){
          updateData(filterDataMap);
        }
      },
    );
  }

  Widget getListingsWidget(dynamic item){
    return HomeScreenListingsWidget(
      homeScreenData: item,
      refresh: needToRefresh,
      homeScreenListingsWidgetListener: (bool errorOccur, bool dataRefresh){
        if(mounted){
          setState(() {
            errorWhileDataLoading = errorOccur;
            needToRefresh = dataRefresh;
          });
        }
      },
    );
  }

  onRefresh() {
    setState(() {
      clearMetaData();
      needToRefresh = true;
    });
    loadData();
  }

  Widget getBodyWidget(){
    return RefreshIndicator(
      edgeOffset: 200.0,
      onRefresh: () async => onRefresh(),
      child: Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              /// Home Screen Sliver App Bar Widget
              getSliverAppBarWidget(),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: 1,
                  (BuildContext context, int index) {
                    // return Column(
                    //   children: [
                    //     ButtonWidget(
                    //       text: "Expire Token",
                    //       onPressed: () async {
                    //         // print("Expiring Token.....................");
                    //         // Map _userLoginInfo = HiveStorageManager.readUserLoginInfoData();
                    //         // // print("_userLoginInfo: $_userLoginInfo");
                    //         // if (_userLoginInfo.isNotEmpty) {
                    //         //   _userLoginInfo["token"] = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3Byb3B0aXNnaC5jb20iLCJpYXQiOjE2Nzc3NzA3OTgsIm5iZiI6MTY3Nzc3MDc5OCwiZXhwIjoxNjc4Mzc1NTk4LCJkYXRhIjp7InVzZXIiOnsiaWQiOiIzOSJ9fX0.q-0il8idwk0tPD3KH77uyuiJ-fXICX0kTszChnB5Wk8";
                    //         //   HiveStorageManager.storeUserLoginInfoData(_userLoginInfo);
                    //         // }
                    //       },
                    //     ),
                    //     Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: homeConfigList.map((item) {
                    //         return getListingsWidget(item);
                    //       }).toList(),
                    //     )
                    //   ],
                    // );


                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: homeConfigList.map((item) {
                        return getListingsWidget(item);
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
          if(errorWhileDataLoading) internetConnectionErrorWidget(),
        ],
      ),
    );
  }

  Widget internetConnectionErrorWidget(){
    return Positioned(
        bottom: 0,
        child: SafeArea(
            top: false,
            child: NoInternetBottomActionBarWidget(onPressed: ()=> checkInternetAndLoadData())));
  }

  Future<Map<String, dynamic>> fetchPropertyMetaData() async {
    Map<String, dynamic> _metaDataMap = {};
    _metaDataMap = await _propertyBloc.fetchPropertyMetaData();
    return _metaDataMap;
  }

  String getSelectedCity(){
    if(filterDataMap.isNotEmpty && filterDataMap[CITY] != null && filterDataMap[CITY].isNotEmpty){
      if(filterDataMap[CITY] is List){
        return filterDataMap[CITY][0];
      }else if(filterDataMap[CITY] is String){
        return filterDataMap[CITY];
      }
    } else if(_selectedCity.isNotEmpty){
      return _selectedCity;
    }

    return UtilityMethods.getLocalizedString("please_select");
  }

  int getSelectedStatusIndex(){
    if(filterDataMap.isNotEmpty && filterDataMap.containsKey(PROPERTY_STATUS_SLUG)
        && filterDataMap[PROPERTY_STATUS_SLUG] != null &&
        filterDataMap[PROPERTY_STATUS_SLUG].isNotEmpty){
      int index = propertyStatusListWithData.indexWhere((element) => element.slug == filterDataMap[PROPERTY_STATUS_SLUG]);
      if(index != -1){
        return index;
      }
    }

    return 0;
  }

  updateData(Map<String, dynamic> map) {
    if (mounted) {
      setState(() {
        filterDataMap = map;

        if(filterDataMap[CITY] is List){
          _selectedCity = filterDataMap[CITY][0] ?? UtilityMethods.getLocalizedString("please_select");
        }else if(filterDataMap[CITY] is String){
          _selectedCity = filterDataMap[CITY] ?? UtilityMethods.getLocalizedString("please_select");
        }
        _selectedCityId = filterDataMap[CITY_ID] is List ? filterDataMap[CITY_ID][0] : filterDataMap[CITY_ID];

        Map cityData = HiveStorageManager.readSelectedCityInfo();
        if(cityData.isNotEmpty){
          var oldSelectedCityId = cityData[CITY_ID];

          if (oldSelectedCityId != _selectedCityId) {
            if(filterDataMap[CITY] is List){
              saveSelectedCityInfo(_selectedCityId, _selectedCity, filterDataMap[CITY_SLUG][0]);
            }else if(filterDataMap[CITY] is String){
              saveSelectedCityInfo(_selectedCityId, _selectedCity, filterDataMap[CITY_SLUG]);
            }
          }
        } else {
          if(filterDataMap[CITY] is List){
            saveSelectedCityInfo(_selectedCityId, _selectedCity, filterDataMap[CITY_SLUG][0]);
          }else if(filterDataMap[CITY] is String){
            saveSelectedCityInfo(_selectedCityId, _selectedCity, filterDataMap[CITY_SLUG]);
          }
        }
        GeneralNotifier().publishChange(GeneralNotifier.FILTER_DATA_LOADING_COMPLETE);
      });
    }
  }

  void saveSelectedCityInfo(int? cityId, String cityName, String citySlug){
    HiveStorageManager.storeSelectedCityInfo(data:
    {
      CITY : cityName,
      CITY_ID : cityId,
      CITY_SLUG: citySlug,
    }
    );
    GeneralNotifier().publishChange(GeneralNotifier.CITY_DATA_UPDATE);
  }

  getHomeConfigFile() {
    if(mounted) {
      setState(() {
        homeConfigList = UtilityMethods.readHomeConfigFile();
      });
    }
  }

  getDrawerConfigFile() {
    if(mounted) {
      setState(() {
        drawerConfigList = UtilityMethods.readDrawerConfigFile();
      });
    }
  }
}