import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:houzi_package/blocs/property_bloc.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/files/theme_service_files/theme_notifier.dart';
import 'package:houzi_package/widgets/app_bar_widget.dart';
import 'package:houzi_package/widgets/article_box_widgets/article_box_design_for_favourites.dart';
import 'package:houzi_package/widgets/data_loading_widget.dart';
import 'package:houzi_package/widgets/no_internet_botton_widget.dart';
import 'package:houzi_package/widgets/no_result_error_widget.dart';
import 'package:houzi_package/widgets/toast_widget.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../files/generic_methods/general_notifier.dart';
import '../../files/generic_methods/utility_methods.dart';

typedef FavoritesPageListener = void Function(String closeOption);

class Favorites extends StatefulWidget {
  final bool showAppBar;
  final FavoritesPageListener? favoritesPageListener;

  Favorites({this.showAppBar = false , this.favoritesPageListener});

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> with AutomaticKeepAliveClientMixin<Favorites> {

  int page = 1;
  int perPage = 10;

  int? userId;
  String userIdStr = "";

  bool shouldLoadMore = true;
  bool isLoading = false;
  bool isInternetConnected = true;

  List<dynamic> favoritesPropertiesList = [];

  Future<List<dynamic>>? _futureFavoritesProperties;

  VoidCallback? generalNotifierLister;

  final PropertyBloc _propertyBloc = PropertyBloc();

  final RefreshController _refreshController = RefreshController(initialRefresh: false);



  @override
  void initState() {
    loadData();

    generalNotifierLister = () {
      if (GeneralNotifier().change == GeneralNotifier.NEW_FAV_ADDED_REMOVED) {
        loadDataFromApi();
      }
    };
    GeneralNotifier().addListener(generalNotifierLister!);

    super.initState();
  }

  loadData() {
    userId = HiveStorageManager.getUserId();
    if (userId != null) {
      userIdStr = userId.toString();
      loadDataFromApi();
      if(mounted){
        setState(() {});
      }
    }
  }

  retryLoadData() {
    isLoading = false;
    loadData();
  }


  loadDataFromApi({bool forPullToRefresh = true}) {
    if (forPullToRefresh) {
      if (isLoading) {
        return;
      }

      if(mounted){
        setState(() {
          isLoading = true;
        });
      }

      page = 1;
      _futureFavoritesProperties = fetchFavProperties(page, userIdStr);
      _refreshController.refreshCompleted();
    } else {
      if (!shouldLoadMore || isLoading) {
        _refreshController.loadComplete();
        return;
      }
      if(mounted){
        setState(() {
          // isRefreshing = false;
          isLoading = true;
        });
      }

      page++;
      _futureFavoritesProperties = fetchFavProperties(page, userIdStr);
      _refreshController.loadComplete();
    }
  }

  Future<List<dynamic>> fetchFavProperties(int page, String userIdStr) async {
    if (page == 1) {
      if(mounted){
        setState(() {
          shouldLoadMore = true;
        });
      }
    }

    List<dynamic> tempList = await _propertyBloc.fetchFavProperties(page,perPage,userIdStr);
    if(tempList == null || (tempList.isNotEmpty && tempList[0] == null)
        || (tempList.isNotEmpty && tempList[0].runtimeType == Response)) {
      if (mounted) {
        setState(() {
          isInternetConnected = false;
          shouldLoadMore = false;
        });
      }
      return favoritesPropertiesList;
    } else {
      if (mounted) {
        setState(() {
          isInternetConnected = true;
        });
      }

      if(tempList.isEmpty || tempList.length < perPage) {
        if(mounted){
          setState(() {
            shouldLoadMore = false;
          });
        }
      }

      if (page == 1) {
        favoritesPropertiesList.clear();
      }
      if (tempList.isNotEmpty) {
        favoritesPropertiesList.addAll(tempList);
      }
    }

    return favoritesPropertiesList;
  }

  void onBackPressed() {
    widget.favoritesPageListener!(CLOSE);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) {
        return WillPopScope(
          onWillPop: () {
            widget.favoritesPageListener!(CLOSE);
            return Future.value(false);
          },
          child: Scaffold(
            appBar: widget.showAppBar ? AppBarWidget(
              onBackPressed: onBackPressed,
              appBarTitle: UtilityMethods.getLocalizedString("favorites"),
            ) : null,
            body: Stack(
              children: [
                showFavoritesList(context, _futureFavoritesProperties),
                if (_refreshController.isLoading)
                  Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: paginationLoadingWidget(),
                  ),
                bottomActionBarWidget(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget showFavoritesList(BuildContext context, Future<List<dynamic>>? futureFavProperties) {
    return FutureBuilder<List<dynamic>>(
      future: futureFavProperties,
      builder: (context, articleSnapshot) {
        isLoading = false;
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
                  if (shouldLoadMore) {
                    body = SizedBox(height: 55.0, child: paginationLoadingWidget());
                  } else {
                    body = Container();
                  }
                }
                return Center(child: body);
              },
            ),
            header: const MaterialClassicHeader(),
            controller: _refreshController,
            onRefresh: loadDataFromApi,
            onLoading: () => loadDataFromApi(forPullToRefresh: false),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                var item = list[index];
                String heroId = item.id.toString() + FAVOURITES;
                return favouritesArticleBoxDesign(
                    context: context,
                    item: item,
                    propertyListIndex: index,
                    onTap: () {
                      UtilityMethods.navigateToPropertyDetailPage(
                        context: context,
                        article: item,
                        propertyID: item.id,
                        heroId: heroId,
                      );
                    },
                    favouritesArticleBoxDesignWidgetListener: (
                        int propertyListIndex,
                        Map<String, dynamic> addOrRemoveFromFavInfo) {
                      removeFromFavoritesList(propertyListIndex, addOrRemoveFromFavInfo);
                    });
              })
          );
        }
        else if (!articleSnapshot.hasData) {
          return noResultFoundPage();
        }
        else if (articleSnapshot.hasError) {
          return noResultFoundPage();
        }

        return loadingIndicatorWidget();
      },
    );
  }

  Widget bottomActionBarWidget() {
    return Positioned(
      bottom: 0.0,
      child: SafeArea(
        child: Column(
          children: [
            if(!isInternetConnected) NoInternetBottomActionBarWidget(onPressed: ()=> retryLoadData()),
          ],
        ),
      ),
    );
  }

  Future<void> removeFromFavoritesList(int propertyListIndex, Map<String, dynamic> addOrRemoveFromFavInfo) async {
    final response = await _propertyBloc.fetchAddOrRemoveFromFavResponse(addOrRemoveFromFavInfo);

    String tempResponseString = response.toString().split("{")[1];
    Map map = jsonDecode("{${tempResponseString.split("}")[0]}}");
    if(map['added'] == false){
      setState(() {
        favoritesPropertiesList.removeAt(propertyListIndex);
        if (favoritesPropertiesList.isEmpty) {
          favoritesPropertiesList.clear();
        }
      });
      // _showToast(context, map['msg']);
    }
    else{
      _showToast(context, UtilityMethods.getLocalizedString("error_occurred"));
    }
  }

  Widget loadingIndicatorWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      alignment: Alignment.center,
      child: SizedBox(
        width: 80,
        height: 20,
        child: BallBeatLoadingWidget(),
      ),
    );
  }

  _showToast(BuildContext context, String msg) {
    ShowToastWidget(
      buildContext: context,
      text: msg,
    );
  }

  Widget noResultFoundPage() {
    return NoResultErrorWidget(
      headerErrorText: UtilityMethods.getLocalizedString("no_result_found"),
      bodyErrorText: UtilityMethods.getLocalizedString("no_fav_found"),
      hideGoBackButton: !widget.showAppBar
    );
  }

  Widget paginationLoadingWidget() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Column(
        children: const [
          SizedBox(
            width: 60,
            height: 50,
            child: BallRotatingLoadingWidget(),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
