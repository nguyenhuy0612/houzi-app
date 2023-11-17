import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:houzi_package/blocs/property_bloc.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/pages/add_property_v2/add_property_utilities.dart';
import 'package:houzi_package/models/api_response.dart';
import 'package:houzi_package/pages/add_property_v2/add_property_v2.dart';
import 'package:houzi_package/pages/in_app_purchase/payment_page.dart';
import 'package:houzi_package/providers/api_providers/houzez_api_provider.dart';
import 'package:houzi_package/providers/api_providers/property_api_provider.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/models/article.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/add_property.dart';
import 'package:houzi_package/widgets/app_bar_widget.dart';
import 'package:houzi_package/widgets/article_box_widgets/article_box_design_for_properties.dart';
import 'package:houzi_package/widgets/data_loading_widget.dart';
import 'package:houzi_package/widgets/dialog_box_widget.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';
import 'package:houzi_package/widgets/no_internet_error_widget.dart';
import 'package:houzi_package/widgets/no_result_error_widget.dart';
import 'package:houzi_package/widgets/toast_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:houzi_package/widgets/article_box_widgets/article_box_design_for_drafts.dart';
import 'package:houzi_package/widgets/generic_bottom_sheet_widget/generic_bottom_sheet_widget.dart';


class Properties extends StatefulWidget {
  @override
  _PropertiesState createState() => _PropertiesState();
}

class _PropertiesState extends State<Properties> with TickerProviderStateMixin {
  List<dynamic> allPropertiesList = [];
  Future<List<dynamic>>? _futureAllProperties;

  List<dynamic> myPropertiesList = [];
  Future<List<dynamic>>? _futureMyProperties;

  bool isInternetConnected = true;
  bool isMyPropertiesLoaded = true;
  bool isAllPropertiesLoaded = true;

  bool shouldLoadMoreMyProperties = true;
  bool isLoadingMyProperties = false;
  
  bool shouldLoadMoreAllProperties = true;
  bool isLoadingAllProperties = false;

  String userRole = "";
  int? userId;

  String status = "any";
  int pageForAllProperties = 1;
  int pageForMyProperties = 1;
  int perPage = 10;

  final PropertyBloc _propertyBloc = PropertyBloc();
  final PropertyApiProvider _propertyApiProvider = PropertyApiProvider(HOUZEZApiProvider());

  final RefreshController _refreshControllerForAllProperties = RefreshController(initialRefresh: false);
  final RefreshController _refreshControllerForMyProperties = RefreshController(initialRefresh: false);
  final RefreshController _refreshControllerForDraftProperties = RefreshController(initialRefresh: false);

  TabController? _tabController;

  List<dynamic> _draftPropertiesList = [];

  int _tabControllerLength = 2;

  List<Widget> _tabsChildrenList = [];

  Map userPaymentStatusMap = {};

  @override
  void initState() {
    super.initState();
    userId = HiveStorageManager.getUserId();
    userRole = HiveStorageManager.getUserRole();

    getUserPaymentStatus();
    loadData();
  }

  getUserPaymentStatus() async {
    userPaymentStatusMap = await _propertyBloc.fetchUserPaymentStatus();
    print(userPaymentStatusMap);
  }

  checkInternetAndLoadData(){
    if(!isMyPropertiesLoaded){
      if(mounted){
        setState(() {
          shouldLoadMoreMyProperties = true;
          isLoadingMyProperties = false;
          loadDataFromApiMyProperties();
        });
      }
    }
    if(!isAllPropertiesLoaded){
      if(mounted){
        setState(() {
          shouldLoadMoreAllProperties = true;
          isLoadingAllProperties = false;
          loadDataFromApiAllProperties();
        });
      }
    }
    // loadData();
  }

  loadData(){
    /// Load Draft Properties
    _draftPropertiesList = HiveStorageManager.readDraftPropertiesDataMapsList() ?? [];

    /// if Admin is Logged, Load All Properties
    if(userRole == ROLE_ADMINISTRATOR){
      loadDataFromApiAllProperties();
      if(SHOW_DRAFTS){
        if(mounted){
          setState(() {
            _tabControllerLength = 3;
          });
        }
      }
    }
    /// Load User's Properties
    loadDataFromApiMyProperties();

    _tabController = TabController(length: _tabControllerLength, vsync: this);
  }

  @override
  dispose() {
    if(_tabController != null){
      _tabController!.dispose();
    }
    super.dispose();
  }

  loadDataFromApiMyProperties({bool forPullToRefresh = true}) {
    if (forPullToRefresh) {
      if (isLoadingMyProperties) {
        return;
      }
      setState(() {
        isLoadingMyProperties = true;
      });

      pageForMyProperties = 1;
      _futureMyProperties = fetchMyProperties(pageForMyProperties);
      _refreshControllerForMyProperties.refreshCompleted();
    } else {
      if (!shouldLoadMoreMyProperties || isLoadingMyProperties) {
        _refreshControllerForMyProperties.loadComplete();
        return;
      }
      setState(() {
        // isRefreshing = false;
        shouldLoadMoreMyProperties = true;
      });
      pageForMyProperties++;
      _futureMyProperties = fetchMyProperties(pageForMyProperties);
      _refreshControllerForMyProperties.loadComplete();

    }
  }

  Future<List<dynamic>> fetchMyProperties(int page) async {
    if (page == 1) {
      setState(() {
        shouldLoadMoreMyProperties = true;
      });
    }
    List<dynamic> tempList = await _propertyBloc.fetchMyProperties(status, page, perPage, userId!);
    if(tempList == null || (tempList.isNotEmpty && tempList[0] == null) || (tempList.isNotEmpty && tempList[0].runtimeType == Response)){
      if(mounted){
        setState(() {
          isMyPropertiesLoaded = false;
          shouldLoadMoreMyProperties = false;
        });
      }
      return myPropertiesList;
    }else{
      if (mounted) {
        setState(() {
          isMyPropertiesLoaded = true;
          isInternetConnected = true;
        });
      }
      if(tempList.isEmpty || tempList.length < perPage){
        if(mounted){
          setState(() {
            shouldLoadMoreMyProperties = false;
          });
        }
      }

      if (page == 1) {
        myPropertiesList.clear();
      }
      if (tempList.isNotEmpty) {
        myPropertiesList.addAll(tempList);
      }
    }

    return myPropertiesList;
  }

  loadDataFromApiAllProperties({bool forPullToRefresh = true}) {
    if (forPullToRefresh) {
      if (isLoadingAllProperties) {
        return;
      }
      setState(() {
        //isRefreshing = true;
        isLoadingAllProperties = true;
      });

      pageForAllProperties = 1;
      _futureAllProperties = fetchAllProperties(pageForAllProperties);
      _refreshControllerForAllProperties.refreshCompleted();
    } else {
      if (!shouldLoadMoreAllProperties || isLoadingAllProperties) {
        _refreshControllerForAllProperties.loadComplete();
        return;
      }
      setState(() {
        // isRefreshing = false;
        shouldLoadMoreAllProperties = true;
      });
      pageForAllProperties++;
      _futureAllProperties = fetchAllProperties(pageForAllProperties);
      _refreshControllerForAllProperties.loadComplete();

    }
  }

  Future<List<dynamic>> fetchAllProperties(int page) async {
    if (page == 1) {
      setState(() {
        shouldLoadMoreAllProperties = true;
      });
    }
    List<dynamic> tempList = await _propertyBloc.fetchAllProperties(status, page, perPage, userId!);
    if(tempList == null || (tempList.isNotEmpty && tempList[0] == null) || (tempList.isNotEmpty && tempList[0].runtimeType == Response)){
      if(mounted){
        setState(() {
          isAllPropertiesLoaded = false;
          shouldLoadMoreAllProperties = false;
        });
      }
      return allPropertiesList;
    }else{
      if (mounted) {
        setState(() {
          isAllPropertiesLoaded = true;
          isInternetConnected = true;
        });
      }
      if(tempList.isEmpty || tempList.length < perPage){
        if(mounted){
          setState(() {
            shouldLoadMoreAllProperties = false;
          });
        }
      }

      if (page == 1) {
        allPropertiesList.clear();
      }
      if (tempList.isNotEmpty) {
        allPropertiesList.addAll(tempList);
      }
    }

    return allPropertiesList;
  }

  @override
  Widget build(BuildContext context) {
    _tabsChildrenList = isMyPropertiesLoaded == false ? [noInternetWidget()] :
    [showPropertiesList(context,_futureMyProperties!, fromMyProperties: true)];

    if (userRole == ROLE_ADMINISTRATOR) {
      isAllPropertiesLoaded == false ? _tabsChildrenList.insert(0, noInternetWidget()) :
      _tabsChildrenList.insert(0, showPropertiesList(context,_futureAllProperties!, fromMyProperties: false));
    }

    if(SHOW_DRAFTS){
      _tabsChildrenList.add(draftPropertiesWidget(_draftPropertiesList));
    }

    return SHOW_DRAFTS ? propertiesWithDrafts() : propertiesWithOutDrafts();
  }

  Widget propertiesWithDrafts(){
    return DefaultTabController(
      length: _tabsChildrenList.length,
      child: Scaffold(
        appBar: appBarForDraftsWidget(), //appBarWithoutDraftsWidget()
        body: isInternetConnected == false
            ? Align(
                alignment: Alignment.topCenter,
                child: NoInternetConnectionErrorWidget(onPressed: () {
                  checkInternetAndLoadData();
                }),
              )
            : TabBarView(
                controller: _tabController,
                children: _tabsChildrenList,
              ),
      ),
    );
  }

  Widget noInternetWidget(){
    return Align(
      alignment: Alignment.topCenter,
      child: NoInternetConnectionErrorWidget(
        onPressed: () {
        checkInternetAndLoadData();
      }),
    );
  }

  Widget propertiesWithOutDrafts(){
    return (userRole == ROLE_ADMINISTRATOR)
        ? DefaultTabController(
            length: _tabsChildrenList.length,
            child: propertiesWithOutDraftsBodyWidget(),
          )
        : propertiesWithOutDraftsBodyWidget();
  }

  Widget propertiesWithOutDraftsBodyWidget(){
    return Scaffold(
      appBar: appBarWithoutDraftsWidget(),
      body: isInternetConnected == false ? Align(
        alignment: Alignment.topCenter,
        child: NoInternetConnectionErrorWidget(onPressed: () {
          checkInternetAndLoadData();
        }),
      ) : (userRole == ROLE_ADMINISTRATOR) ? TabBarView(
        controller: _tabController,
        children: _tabsChildrenList,
      ) : showPropertiesList(context, _futureMyProperties!, fromMyProperties: true),
    );
  }

  PreferredSizeWidget appBarWithoutDraftsWidget() {
    List<Widget> _tabsList = [
      genericTabWidget(label: UtilityMethods.getLocalizedString("all_properties")),
      genericTabWidget(label: UtilityMethods.getLocalizedString("my_properties")),
    ];

    return AppBarWidget(
      appBarTitle: userRole == ROLE_ADMINISTRATOR ?
      UtilityMethods.getLocalizedString("properties") :
      UtilityMethods.getLocalizedString("my_properties"),
      bottom: userRole == ROLE_ADMINISTRATOR ? TabBar(
        controller: _tabController,
        indicatorColor: AppThemePreferences.tabBarIndicatorColor,
        tabs: _tabsList,
      ) : null,
    );
  }

  PreferredSizeWidget appBarForDraftsWidget() {
    List<Widget> _tabsList = [
      genericTabWidget(label: UtilityMethods.getLocalizedString("my_properties")),
      genericTabWidget(label: UtilityMethods.getLocalizedString("draft_properties")),
    ];
    if (userRole == ROLE_ADMINISTRATOR) {
      _tabsList.insert(0, genericTabWidget(label: UtilityMethods.getLocalizedString("all_properties")));
    }

    return AppBarWidget(
      appBarTitle: UtilityMethods.getLocalizedString("properties"),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppThemePreferences.tabBarIndicatorColor,
        tabs: _tabsList,
      ),
    );
  }

  Widget genericTabWidget({required String label}){
    return Tab(child: GenericTextWidget(label, style: AppThemePreferences().appTheme.genericTabBarTextStyle));
  }

  Widget showPropertiesList(BuildContext context, Future<List<dynamic>> futureInquiriesFromBoard, {required bool fromMyProperties}) {
    return FutureBuilder<List<dynamic>>(
      future: futureInquiriesFromBoard,
      builder: (context, articleSnapshot) {
        if(fromMyProperties){
          isLoadingMyProperties = false;
        }else{
          isLoadingAllProperties = false;
        }
        if (articleSnapshot.hasData) {
          if (articleSnapshot.data!.isEmpty) {
            return noResultFoundPage();
          }

          List<dynamic> list = articleSnapshot.data!;

          return SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus? mode) {
                Widget body = Container();
                if (mode == LoadStatus.loading) {
                  if (fromMyProperties) {
                    if (shouldLoadMoreMyProperties) {
                      body = paginationLoadingWidget();
                    } else {
                      body = Container();
                    }
                  } else {
                    if (shouldLoadMoreAllProperties) {
                      body = paginationLoadingWidget();
                    } else {
                      body = Container();
                    }
                  }
                }
                return SizedBox(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            header: const MaterialClassicHeader(),
            controller: fromMyProperties
                ? _refreshControllerForMyProperties
                : _refreshControllerForAllProperties,
            onRefresh: fromMyProperties
                ? loadDataFromApiMyProperties
                : loadDataFromApiAllProperties,
            onLoading: fromMyProperties
                ? () => loadDataFromApiMyProperties(forPullToRefresh: false)
                : () => loadDataFromApiAllProperties(forPullToRefresh: false),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                Article item = list[index];
                var _propertyId = item.id;
                int? _author = item.author;
                String? _status = item.status;
                Map<String,dynamic> actionButtonMap = {
                  "item" : item,
                  "userId":userId,
                  "userRole":userRole,
                  "_status":_status,
                  "_propertyId":_propertyId,
                  "index":index,
                  "_author":_author
                };
                return propertiesArticleBoxDesign(
                    context: context,
                    actionButtonMap: actionButtonMap,
                    item: item,
                    onTap: () {
                      UtilityMethods.navigateToPropertyDetailPage(
                        context: context,
                        article: item,
                        propertyID: item.id,
                        heroId: item.id.toString() + RELATED,
                      );
                    },
                    propertiesArticleBoxDesignWidgetListener: (Map<String,dynamic> actionButtonMap){
                      _actionBottomSheet(context,actionButtonMap);
                    });
              },
            ),
          );
        } else if (articleSnapshot.hasError) {
          return noResultFoundPage();
        }
        return loadingIndicatorWidget();
      },
    );
  }

  void _actionBottomSheet(context, Map<String,dynamic> actionButtonMap) {
    showModalBottomSheet(
      useSafeArea: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (BuildContext bc) {
          Article article = actionButtonMap["item"];
          bool isFeatured = article.propertyInfo?.isFeatured ?? false;
          bool showPayNow = false;
          if (TOUCH_BASE_PAYMENT_ENABLED_STATUS == perListing && actionButtonMap["_status"] != STATUS_PUBLISH) {
            String paymentStatus = article.propertyInfo!.paymentStatus ?? "";
            if (paymentStatus == "not_paid") {
              showPayNow = true;
            }
          }

          return SafeArea(
            child: Wrap(
              children: [
                if (actionButtonMap["_author"] == userId)
                  genericOptionsOfBottomSheet(
                    actionButtonMap["_propertyId"],
                    UtilityMethods.getLocalizedString("edit"),
                    propertyListIndex: actionButtonMap["index"],
                    article: actionButtonMap["item"],
                    onPressed: editProperty,
                  ),
                if (actionButtonMap["_author"] == userId || userRole == ROLE_ADMINISTRATOR)
                  genericOptionsOfBottomSheet(
                    actionButtonMap["_propertyId"],
                    UtilityMethods.getLocalizedString("delete"),
                    propertyListIndex: actionButtonMap["index"],
                    article: actionButtonMap["item"],
                    onPressed: deleteProperty,
                    style: AppThemePreferences().appTheme.bottomSheetNegativeOptionsTextStyle!,
                  ),
                if (userRole == ROLE_ADMINISTRATOR)
                  if (actionButtonMap["_author"] == userId && actionButtonMap["_status"] != STATUS_ON_HOLD)
                    genericOptionsOfBottomSheet(
                      actionButtonMap["_propertyId"],
                      UtilityMethods.getLocalizedString("put_on_hold"),
                      propertyListIndex: actionButtonMap["index"],
                      article: actionButtonMap["item"],
                      onPressedForStatus: changeStatusProperty,
                      changeStatusValue: STATUS_ON_HOLD,
                    )
                  else Container()
                else if(actionButtonMap["_status"] != STATUS_ON_HOLD)
                  genericOptionsOfBottomSheet(
                    actionButtonMap["_propertyId"],
                    UtilityMethods.getLocalizedString("put_on_hold"),
                    propertyListIndex: actionButtonMap["index"],
                    article: actionButtonMap["item"],
                    onPressedForStatus: changeStatusProperty,
                    changeStatusValue: STATUS_ON_HOLD,
                  ),
                if (userRole == ROLE_ADMINISTRATOR &&
                    (actionButtonMap["_status"] == STATUS_ON_PENDING
                        || actionButtonMap["_status"] == STATUS_ON_HOLD))
                  genericOptionsOfBottomSheet(
                    actionButtonMap["_propertyId"],
                    UtilityMethods.getLocalizedString("publish_property"),
                    propertyListIndex: actionButtonMap["index"],
                    article: actionButtonMap["item"],
                    onPressedForStatus: changeStatusProperty,
                    changeStatusValue: STATUS_PUBLISH,
                  )
                else Container(),
                if (actionButtonMap["_author"] == userId
                    && userPaymentStatusMap[enablePaidSubmissionKey] == freePaidListing
                    && actionButtonMap["_status"] == STATUS_PUBLISH
                    && !isFeatured
                )
                  genericOptionsOfBottomSheet(
                    actionButtonMap["_propertyId"],
                    UtilityMethods.getLocalizedString("upgrade_featured"),
                    propertyListIndex: actionButtonMap["index"],
                    article: actionButtonMap["item"],
                    onPressed: upgradeToFeatured,
                  ),
                if (actionButtonMap["_author"] == userId
                    && userPaymentStatusMap[enablePaidSubmissionKey] == perListing
                    && actionButtonMap["_status"] == STATUS_PUBLISH
                    && !isFeatured
                )
                  genericOptionsOfBottomSheet(
                    actionButtonMap["_propertyId"],
                    UtilityMethods.getLocalizedString("upgrade_featured"),
                    propertyListIndex: actionButtonMap["index"],
                    article: actionButtonMap["item"],
                    onPressed: upgradeToFeatured,
                  ),
                if (actionButtonMap["_author"] == userId
                    && userPaymentStatusMap[enablePaidSubmissionKey] == perListing && showPayNow)
                  genericOptionsOfBottomSheet(
                    actionButtonMap["_propertyId"],
                    UtilityMethods.getLocalizedString("pay_now"),
                    propertyListIndex: actionButtonMap["index"],
                    article: actionButtonMap["item"],
                    onPressed: payNow,
                  ),
                if (actionButtonMap["_author"] == userId
                    && userPaymentStatusMap[enablePaidSubmissionKey] == membership
                      && actionButtonMap["_status"] == STATUS_PUBLISH
                      && !isFeatured
                  )
                  genericOptionsOfBottomSheet(
                    actionButtonMap["_propertyId"],
                    UtilityMethods.getLocalizedString("set_featured"),
                    propertyListIndex: actionButtonMap["index"],
                    article: actionButtonMap["item"],
                    onPressed: setAsFeatured,
                  ),
                if (actionButtonMap["_author"] == userId
                    && userPaymentStatusMap[enablePaidSubmissionKey] == membership
                      && actionButtonMap["_status"] == STATUS_PUBLISH
                      && isFeatured
                  )
                  genericOptionsOfBottomSheet(
                    actionButtonMap["_propertyId"],
                    UtilityMethods.getLocalizedString("remove_featured"),
                    propertyListIndex: actionButtonMap["index"],
                    article: actionButtonMap["item"],
                    onPressed: removeFromFeatured,
                  ),
              ],
            ),
          );
        }
    );
  }

  Widget genericOptionsOfBottomSheet(
      int propertyId,
      String label,
      {
        Article? article,
        int? propertyListIndex,
        Function(int?,int?)? onPressed,
        Function(int?, int?, Article?,String?)? onPressedForStatus,
        String? changeStatusValue,
        TextStyle? style,
        bool showDivider = true,
      }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Container(
        decoration: !showDivider? null : AppThemePreferences.dividerDecoration(),
        child: TextButton(
          child: GenericTextWidget(
              label,
              style: style ??
                  AppThemePreferences().appTheme.bottomSheetOptionsTextStyle,
          ),
          onPressed: () async {
            if (label == UtilityMethods.getLocalizedString("put_on_hold") ||
                label == UtilityMethods.getLocalizedString("publish_property")) {
              onPressedForStatus!(
                  propertyId,
                  propertyListIndex,
                  article,
                  changeStatusValue,
              );
            } else {
              onPressed!(propertyId, propertyListIndex);
            }
          },
        ),
      ),
    );
  }

  Future<void> editProperty(int? propertyId, int? propertyListIndex) async {
    final _articleResponseList =
        await _propertyBloc.fetchSingleArticle(propertyId!, forEditing: true);

    if (_articleResponseList.isEmpty) {
      print("Edit Property Error: Empty list received as response");
    } else {
      Map<String, dynamic> dataMapForUpdateProperty = {};

      dataMapForUpdateProperty[UPDATE_PROPERTY_ID] = '$propertyId';
      dataMapForUpdateProperty[ADD_PROPERTY_USER_ID] = '$userId';
      dataMapForUpdateProperty.addAll(AddPropertyUtilities.convertArticleToMapForEditing(_articleResponseList[0]));

      Navigator.pop(context);
      UtilityMethods.navigateToRoute(
        context: context,
        builder: (context) => AddPropertyV2(
          isPropertyForUpdate: true,
          propertyDataMap: dataMapForUpdateProperty,
        ),
        // builder: (context) => AddProperty(
        //   isPropertyForUpdate: true,
        //   propertyDataMap: dataMapForUpdateProperty,
        // ),
      );
    }
  }

  Future<void> deleteProperty(int? propertyId,int? propertyListIndex) async {
    ShowDialogBoxWidget(
      context,
      title: UtilityMethods.getLocalizedString("delete"),
      content: GenericTextWidget(UtilityMethods.getLocalizedString("delete_confirmation")),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: GenericTextWidget(UtilityMethods.getLocalizedString("cancel")),
        ),
        TextButton(
          onPressed: () async {
            final response = await _propertyBloc.deleteProperty(propertyId!);
            Navigator.pop(context);
            if (response.statusCode == 200) {
              setState(() {
                if (userRole == ROLE_ADMINISTRATOR) {
                  if (_tabController!.index == 0) {
                    allPropertiesList.removeAt(propertyListIndex!);
                    if (allPropertiesList.isEmpty) {
                      allPropertiesList.clear();
                    }
                  }
                  if (_tabController!.index == 1) {
                    myPropertiesList.removeAt(propertyListIndex!);
                    if (myPropertiesList.isEmpty) {
                      myPropertiesList.clear();
                    }
                  }
                } else {
                  myPropertiesList.removeAt(propertyListIndex!);
                  if (myPropertiesList.isEmpty) {
                    myPropertiesList.clear();
                  }
                }
              });
              Navigator.pop(context);
            }
          },
          child: GenericTextWidget(UtilityMethods.getLocalizedString("yes")),
        ),
      ],
    );
  }

  Future<void>? changeStatusProperty(int? propertyId,int? propertyListIndex,Article? article,String? changeStatusValue) async {
    Map<String, dynamic> status = {
      "status": changeStatusValue,
    };
    final response = await _propertyBloc.statusOfProperty(status, propertyId!);

    if (response.statusCode == 200) {
      Article item = _propertyApiProvider.getCurrentParser().parseArticle(response.data);
      setState(() {
        article = item;
        if(userRole == ROLE_ADMINISTRATOR){
          if (_tabController!.index == 0) {
            allPropertiesList[propertyListIndex!] = article;
          }
          if (_tabController!.index == 1) {
            myPropertiesList[propertyListIndex!] = article;
          }
        } else {
          myPropertiesList[propertyListIndex!] = article;
        }

      });
      Navigator.pop(context);
    }
  }

  Future<void> upgradeToFeatured(int? propertyId, int? propertyListIndex) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          productIds: Platform.isAndroid ? [MAKE_FEATURED_ANDROID_PRODUCT_ID] : [MAKE_FEATURED_IOS_PRODUCT_ID],
          propId: propertyId.toString(),
          isMembership: false,
          isFeaturedForPerListing: userPaymentStatusMap[enablePaidSubmissionKey] == perListing ? true : false
        ),
      ),
    ).then((value) {
      Navigator.pop(context);
      loadDataFromApiMyProperties();
      loadDataFromApiAllProperties();
      return null;
    });
  }

  Future<void> payNow(int? propertyId, int? propertyListIndex) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          productIds: Platform.isAndroid ? [PER_LISTING_ANDROID_PRODUCT_ID] : [PER_LISTING_IOS_PRODUCT_ID],
          propId: propertyId.toString(),
          isMembership: false,
        ),
      ),
    ).then((value) {
      Navigator.pop(context);
      loadDataFromApiMyProperties();
      loadDataFromApiAllProperties();
      return null;
    });
  }

  Future<void> setAsFeatured(int? propertyId,int? propertyListIndex) async {
    int featuredRemaining = int.tryParse(userPaymentStatusMap[featuredRemainingListingKey]) ?? 0;
    if (featuredRemaining > 0 ) {
      Map<String,dynamic> dataMap = {
        "propid" : propertyId,
        "prop_type": "membership"
      };
      ApiResponse response = await _propertyBloc.fetchMakePropertyFeaturedResponse(dataMap);
      if (response.success) {
        Article? article;
        if(userRole == ROLE_ADMINISTRATOR){
          if (_tabController!.index == 0) {
            article = allPropertiesList[propertyListIndex!];
          }
          if (_tabController!.index == 1) {
            article = myPropertiesList[propertyListIndex!];
          }
        } else {
          article = myPropertiesList[propertyListIndex!];
        }

        article!.propertyInfo!.isFeatured = true;


        if(userRole == ROLE_ADMINISTRATOR){
          if (_tabController!.index == 0) {
            allPropertiesList[propertyListIndex!] = article;
          }
          if (_tabController!.index == 1) {
            myPropertiesList[propertyListIndex!] = article;
          }
        } else {
          myPropertiesList[propertyListIndex!] = article;
        }

        setState(() {});

      } else {
        ShowToastWidget(buildContext: context, text: response.message);
      }
    } else {
      ShowToastWidget(buildContext: context, text: UtilityMethods.getLocalizedString("You have used all the Featured listings in your package"));
    }
    Navigator.pop(context);

  }

  Future<void> removeFromFeatured(int? propertyId,int? propertyListIndex) async {
    ApiResponse response = await _propertyBloc.fetchRemoveFromFeaturedResponse({"propid" : propertyId,});
    if (response.success) {
      Article? article;
      if(userRole == ROLE_ADMINISTRATOR){
        if (_tabController!.index == 0) {
          article = allPropertiesList[propertyListIndex!];
        }
        if (_tabController!.index == 1) {
          article = myPropertiesList[propertyListIndex!];
        }
      } else {
        article = myPropertiesList[propertyListIndex!];
      }

      article!.propertyInfo!.isFeatured = false;


      if(userRole == ROLE_ADMINISTRATOR){
        if (_tabController!.index == 0) {
          allPropertiesList[propertyListIndex!] = article;
        }
        if (_tabController!.index == 1) {
          myPropertiesList[propertyListIndex!] = article;
        }
      } else {
        myPropertiesList[propertyListIndex!] = article;
      }

      setState(() {});

    } else {
      ShowToastWidget(buildContext: context, text: response.message);
    }

    Navigator.pop(context);

  }

  Widget loadingIndicatorWidget() {
    return Container(
      height: (MediaQuery.of(context).size.height) / 2,
      margin: const EdgeInsets.only(top: 50),
      alignment: Alignment.center,
      child: SizedBox(
        width: 80,
        height: 20,
        child: BallBeatLoadingWidget(),
      ),
    );
  }

  Widget noResultFoundPage({
    bool hideGoBackButton = false,
    String? headerText,
    String? bodyText,
  }) {
    return NoResultErrorWidget(
      headerErrorText: headerText != null && headerText.isNotEmpty ? headerText : UtilityMethods.getLocalizedString("no_result_found"),
      bodyErrorText: bodyText != null && bodyText.isNotEmpty ? bodyText : UtilityMethods.getLocalizedString("no_properties_error_message"),
      hideGoBackButton: hideGoBackButton,
    );
  }

  Widget paginationLoadingWidget() {
    return Container(
      color: Theme.of(context).backgroundColor,
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 50,
            child: BallRotatingLoadingWidget(),
          ),
        ],
      ),
    );
  }

  Widget draftPropertiesWidget(List draftPropertiesList){
    return SmartRefresher(
      enablePullDown: true,
      header: const MaterialClassicHeader(),
      controller: _refreshControllerForDraftProperties,
      onRefresh: (){
        List tempList = HiveStorageManager.readDraftPropertiesDataMapsList() ?? [];
        setState(() {
          _draftPropertiesList = tempList;
        });
        _refreshControllerForDraftProperties.refreshCompleted();
      },
      child: draftPropertiesList == null || draftPropertiesList.isEmpty ? noResultFoundPage(
        hideGoBackButton: true,
        headerText: UtilityMethods.getLocalizedString("draft_properties_no_result_found_header_message"),
        bodyText: UtilityMethods.getLocalizedString("draft_properties_no_result_found_body_message"),
      ) :
      SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: draftPropertiesList.map((item) {
            int itemIndex = draftPropertiesList.indexOf(item);
            return draftPropertiesArticleBoxDesign(
              context: context,
              article: convertDraftMapItemToArticle(item),
              heroID: "Hero $itemIndex",
              onTap: ()=> _onEditDraftPressed(itemIndex: itemIndex, dataMap: UtilityMethods.convertMap(item)),
              onActionButtonTap: ()=> onActionButtonPressed(context: context, itemIndex: itemIndex, dataMap: item),
            );
          }).toList(),
        ),
      ),
    );
  }

  convertDraftMapItemToArticle(Map? itemMap){
    List? tempImageList = itemMap![ADD_PROPERTY_PENDING_IMAGES_LIST];
    String _featuredImageLocalId = '';
    String featuredImagePath = '';
    if(tempImageList != null && tempImageList.isNotEmpty){
      _featuredImageLocalId = itemMap[ADD_PROPERTY_FEATURED_IMAGE_LOCAL_ID];
      for (var item in tempImageList) {
        Map<String, dynamic> _imageMap = UtilityMethods.convertMap(item);
        if (_featuredImageLocalId == _imageMap[PROPERTY_MEDIA_IMAGE_ID]) {
          featuredImagePath = _imageMap[PROPERTY_MEDIA_IMAGE_PATH];
        }
      }
    }
    Article _article = Article(
      title: itemMap[ADD_PROPERTY_TITLE],
      image: featuredImagePath,
    );

    Features _features = Features(
      landArea: itemMap[ADD_PROPERTY_SIZE],
      landAreaUnit: itemMap[ADD_PROPERTY_SIZE_PREFIX],
      bedrooms: itemMap[ADD_PROPERTY_BEDROOMS],
      bathrooms: itemMap[ADD_PROPERTY_BATHROOMS],
    );

    PropertyInfo _propertyInfo = PropertyInfo(
      price: itemMap[ADD_PROPERTY_PRICE],
    );

    _article.features = _features;
    _article.propertyInfo = _propertyInfo;
    _article.propertyDetailsMap![PRICE] = itemMap[ADD_PROPERTY_PRICE] ?? "";

    return _article;
  }

  Future onActionButtonPressed({
    required BuildContext context,
    required int itemIndex,
    required Map dataMap
  }) {
    return genericBottomSheetWidget(
      context: context,
      children: <Widget>[
        GenericBottomSheetOptionWidget(
          label: UtilityMethods.getLocalizedString("edit"),
          style: AppThemePreferences().appTheme.bottomSheetOptionsTextStyle!,
          onPressed: ()=> _onEditDraftPressed(itemIndex: itemIndex, dataMap: dataMap, closeBottomSheet: true),
        ),
        GenericBottomSheetOptionWidget(
          label: UtilityMethods.getLocalizedString("delete"),
          showDivider: false,
          style: AppThemePreferences().appTheme.bottomSheetNegativeOptionsTextStyle!,
          onPressed: ()=> _onDeletePropertyPressed(itemIndex: itemIndex),
        ),
      ],
    );
  }

  _onEditDraftPressed({required int itemIndex, required Map dataMap, bool closeBottomSheet = false}){
    // Close Bottom Menu Sheet
    if(closeBottomSheet){
      Navigator.pop(context);
    }
    // Edit Property
    UtilityMethods.navigateToRoute(
      context: context,
      builder: (context) => AddPropertyV2(
      // builder: (context) => AddProperty(
        isDraftProperty: true,
        draftPropertyIndex: itemIndex,
        propertyDataMap: UtilityMethods.convertMap(dataMap),
        // propertyDataMap: dataMap,
      ),
    );
  }

  _onDeletePropertyPressed({required int itemIndex}){
    List<dynamic> _draftPropertiesDataMapsList = HiveStorageManager.readDraftPropertiesDataMapsList() ?? [];
    _draftPropertiesDataMapsList.removeAt(itemIndex);
    setState(() {
      _draftPropertiesList = _draftPropertiesDataMapsList;
    });

    HiveStorageManager.storeDraftPropertiesDataMapsList(_draftPropertiesList);
    // Close Bottom Menu Sheet
    Navigator.pop(context);
  }
}
