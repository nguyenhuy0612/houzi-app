import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/pages/crm_pages/crm_webservices_manager/crm_repository.dart';
import 'package:houzi_package/pages/crm_pages/crm_leads/lead_detail_page.dart';
import 'package:houzi_package/pages/crm_pages/crm_leads/leads_from_board.dart';
import 'package:houzi_package/pages/crm_pages/crm_model/crm_models.dart';
import 'package:houzi_package/pages/crm_pages/crm_pages_widgets/board_pages_widgets.dart';
import 'package:houzi_package/widgets/app_bar_widget.dart';
import 'package:houzi_package/widgets/data_loading_widget.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';
import 'package:houzi_package/widgets/no_internet_botton_widget.dart';
import 'package:houzi_package/widgets/no_result_error_widget.dart';
import 'package:houzi_package/widgets/review_related_widgets/all_reviews_page.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';

class ActivitiesFromBoard extends StatefulWidget {
  const ActivitiesFromBoard({super.key});

  @override
  _ActivitiesFromBoardState createState() => _ActivitiesFromBoardState();
}

class _ActivitiesFromBoardState extends State<ActivitiesFromBoard> {
  final CRMRepository _crmRepository = CRMRepository();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  List<dynamic> activitiesFromBoardList = [];
  List<dynamic> dealsAndLeadsFromActivityList = [];

  Future<List<dynamic>>? _futureActivitiesFromBoard;
  Future<List<dynamic>>? _futureDealsAndLeadsFromActivity;

  bool isInternetConnected = true;
  int? userId;

  String activeCount = "";
  String wonCount = "";
  String lostCount = "";
  var lastDay;
  var lastTwo;
  var lastWeek;
  var last2Week;
  var lastMonth;
  var last2Month;

  var percentDay;
  String? posOrNegDay;
  var percentWeek;
  String? posOrNegWeek;
  var percentMonth;
  String? posOrNegMonth;

  bool isRefreshing = false;
  bool shouldLoadMore = true;
  bool isLoading = false;
  int page = 1;
  int perPage = 10;

  double bottomPadding = 9.0;

  Map<String, double> dealStatMap = {};

  @override
  void initState() {
    super.initState();
    userId = HiveStorageManager.getUserId();
    loadDataFromApi();
  }

  checkInternetAndLoadData() {
    if (mounted) {
      setState(() {
        isRefreshing = false;
        shouldLoadMore = true;
        isLoading = false;
      });
    }

    userId = HiveStorageManager.getUserId();
    loadDataFromApi();
  }

  loadDataFromApi({bool forPullToRefresh = true}) {
    if (forPullToRefresh) {
      if (isLoading) {
        return;
      }
      if (mounted) {
        setState(() {
          isRefreshing = true;
          isLoading = true;
        });
      }

      page = 1;
      loadLeadAndDealData();
      _futureActivitiesFromBoard = fetchActivitiesFromBoard(page, userId!);
      _refreshController.refreshCompleted();
    } else {
      if (!shouldLoadMore || isLoading) {
        _refreshController.loadComplete();
        return;
      }
      if (mounted) {
        setState(() {
          isRefreshing = false;
          isLoading = true;
        });
      }
      page++;
      _futureActivitiesFromBoard = fetchActivitiesFromBoard(page, userId!);
      _refreshController.loadComplete();
    }
  }

  loadLeadAndDealData() {
    _futureDealsAndLeadsFromActivity = fetchDealsAndLeadsFromActivity();
    _futureDealsAndLeadsFromActivity!.then((value) {
      if (value != null && value.isNotEmpty) {
        if (mounted) {
          setState(() {
            dealsAndLeadsFromActivityList = value;
            CRMDealsAndLeadsFromActivity dealsAndLeadsFromActivity = dealsAndLeadsFromActivityList[0];

            activeCount = dealsAndLeadsFromActivity.activeCount!;
            wonCount = dealsAndLeadsFromActivity.wonCount!;
            lostCount = dealsAndLeadsFromActivity.lostCount!;
            lastDay = dealsAndLeadsFromActivity.lastDay;
            lastTwo = dealsAndLeadsFromActivity.lastTwo;
            lastWeek = dealsAndLeadsFromActivity.lastWeek;
            last2Week = dealsAndLeadsFromActivity.last2Week;
            lastMonth = dealsAndLeadsFromActivity.lastMonth;
            last2Month = dealsAndLeadsFromActivity.last2Month;

            lastTwo = lastTwo - lastDay;
            setPercent(lastTwo, lastDay, DAY);
            last2Week = last2Week - lastWeek;
            setPercent(last2Week, lastWeek, WEEK);
            last2Month = last2Month - lastMonth;
            setPercent(last2Month, lastMonth, MONTH);

            dealStatMap = {
              UtilityMethods.getLocalizedString("lost"): double.parse(lostCount),
              UtilityMethods.getLocalizedString("won"): double.parse(wonCount),
              UtilityMethods.getLocalizedString("active"): double.parse(activeCount),
            };

            isRefreshing = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isRefreshing = false;
          });
        }
      }

      return null;
    });
  }

  void setPercent(oldNumber, newNumber, valueFor) {
    if (oldNumber != 0) {
      double percent = ((newNumber - oldNumber) / oldNumber * 100);
      if (valueFor == DAY) {
        percentDay = percent;
      } else if (valueFor == WEEK) {
        percentWeek = percent;
      } else if (valueFor == MONTH) {
        percentMonth = percent;
      }
    } else {
      if (valueFor == DAY) {
        percentDay = newNumber * 100;
      } else if (valueFor == WEEK) {
        percentWeek = newNumber * 100;
      } else if (valueFor == MONTH) {
        percentMonth = newNumber * 100;
      }
    }

    if (oldNumber > newNumber) {
      if (valueFor == DAY) {
        posOrNegDay = DANGER;
      } else if (valueFor == WEEK) {
        posOrNegWeek = DANGER;
      } else if (valueFor == MONTH) {
        posOrNegMonth = DANGER;
      }
    } else {
      if (valueFor == DAY) {
        posOrNegDay = SUCCESS;
      } else if (valueFor == WEEK) {
        posOrNegWeek = SUCCESS;
      } else if (valueFor == MONTH) {
        posOrNegMonth = SUCCESS;
      }
    }
  }

  Future<List<dynamic>> fetchActivitiesFromBoard(int page, int userId) async {
    if (page == 1) {
      if (mounted) {
        setState(() {
          shouldLoadMore = true;
        });
      }
    }
    List<dynamic> tempList =
        await _crmRepository.fetchActivitiesFromBoard(page, perPage, userId);
    if (tempList == null ||
        (tempList.isNotEmpty && tempList[0] == null) ||
        (tempList.isNotEmpty && tempList[0].runtimeType == Response)) {
      if (mounted) {
        setState(() {
          isInternetConnected = false;
          shouldLoadMore = false;
        });
      }
      return activitiesFromBoardList;
    } else {
      if (mounted) {
        setState(() {
          isInternetConnected = true;
        });
      }
      if (tempList.isEmpty || tempList.length < perPage) {
        if (mounted) {
          setState(() {
            shouldLoadMore = false;
          });
        }
      }

      if (page == 1) {
        activitiesFromBoardList.clear();
      }
      if (tempList.isNotEmpty) {
        activitiesFromBoardList.addAll(tempList);
      }
    }

    return activitiesFromBoardList;
  }

  Future<List<dynamic>> fetchDealsAndLeadsFromActivity() async {
    List<dynamic> tempList = await _crmRepository.fetchDealsAndLeadsFromActivity();

    if (tempList == null ||
        (tempList.isNotEmpty && tempList[0] == null) ||
        (tempList.isNotEmpty && tempList[0].runtimeType == Response)) {
      if (mounted) {
        setState(() {
          isInternetConnected = false;
        });
      }
      return dealsAndLeadsFromActivityList;
    } else {
      if (mounted) {
        setState(() {
          isInternetConnected = true;
        });
      }
      dealsAndLeadsFromActivityList.clear();
      dealsAndLeadsFromActivityList.addAll(tempList);
    }

    return dealsAndLeadsFromActivityList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        appBarTitle: UtilityMethods.getLocalizedString("activities"),
      ),
      body: Stack(
        children: [
          SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: const MaterialClassicHeader(),
            controller: _refreshController,
            onRefresh: loadDataFromApi,
            onLoading: () => loadDataFromApi(forPullToRefresh: false),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus? mode) {
                Widget? body;
                if (mode == LoadStatus.loading) {
                  if (shouldLoadMore) {
                    body = const CRMPaginationLoadingWidget();
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
            child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(
                children: [
                  dealsAndLeadsFromActivityList.isEmpty
                      ? const SizedBox(height: 50)
                      : Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.48,
                                  child: showLeads(),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.48,
                                  height: 220,
                                  child: showDeals(),
                              ),
                            ],
                          ),
                      ),
                  Container(
                    child: showActivitiesList(context, _futureActivitiesFromBoard!),
                  ),
                ],
              ),
            ),
          ),
          if (_refreshController.isLoading)
            const CRMPaginationLoadingWidget(),
          if (isInternetConnected == false) internetConnectionErrorWidget(),
        ],
      ),
    );
  }

  Widget internetConnectionErrorWidget() {
    return Positioned(
      bottom: 0,
      child: SafeArea(
        top: false,
        child: NoInternetBottomActionBarWidget(
          onPressed: () => checkInternetAndLoadData(),
        ),
      ),
    );
  }

  Widget showLeads() {
    return dealsAndLeadsFromActivityList.isEmpty
        ? Container()
        : Card(
            shape: AppThemePreferences.roundedCorners(AppThemePreferences.globalRoundedCornersRadius),
            elevation: AppThemePreferences.boardPagesElevation,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenericTextWidget(
                    UtilityMethods.getLocalizedString("leads"),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: [
                          setLeadDataWidget(percentDay, posOrNegDay!, "last_24_hours", lastDay),
                          const Divider(),
                          setLeadDataWidget(percentWeek, posOrNegWeek!, "last_7_days", lastWeek),
                          const Divider(),
                          setLeadDataWidget(percentMonth, posOrNegMonth!, "last_30_days", lastMonth),
                        ],
                      ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget setLeadDataWidget(percent, String posOrNeg, String time, value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              percentWidget(percent.toStringAsFixed(0) + "%", posOrNeg),
              GenericTextWidget(
                UtilityMethods.getLocalizedString(time),
                style: AppThemePreferences().appTheme.activitySubTitleTextStyle,
              )
            ],
          ),
          const Spacer(),
          GenericTextWidget(
            value.toString(),
            style: AppThemePreferences().appTheme.activityHeadingTextStyle,
          )
          // percentWidget(percentDay.toStringAsFixed(0) + "%", posOrNegDay!),
        ],
      ),
    );
  }

  Widget percentWidget(String textValue, String posNegValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GenericTextWidget(
          textValue,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: posNegValue == 'text-success'
              ? AppThemePreferences().appTheme.risingLeadsTextStyle
              : AppThemePreferences().appTheme.fallingLeadsTextStyle,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Icon(
            posNegValue == 'text-success'
                ? AppThemePreferences.upArrowIcon
                : AppThemePreferences.downArrowIcon,
            color: posNegValue == 'text-success'
                ? AppThemePreferences.risingLeadsColor
                : AppThemePreferences.fallingLeadsColor,
            size: 20,
          ),
        )
      ],
    );
  }

  Widget setLabelWidget(String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 3, right: 0, bottom: 10),
          child: GenericTextWidget(
            label,
            style: AppThemePreferences().appTheme.heading02TextStyle,
          ),
        ),
      ],
    );
  }

  Widget showDeals() {
    if (dealsAndLeadsFromActivityList.isEmpty) {
      return Container();
    } else {
      return Card(
        shape: AppThemePreferences.roundedCorners(AppThemePreferences.globalRoundedCornersRadius),
        elevation: AppThemePreferences.boardPagesElevation,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GenericTextWidget(
                UtilityMethods.getLocalizedString("deals"),
                style: const TextStyle(color: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        dealRowWidget(const Color(0xFF56eec5), "active"),
                        dealRowWidget(const Color(0xFF74b8ff), "won"),
                        dealRowWidget(const Color(0xFFff7674), "lost"),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: PieChart(
                        dataMap: dealStatMap,
                        animationDuration: const Duration(milliseconds: 800),
                        chartLegendSpacing: 50,
                        chartRadius: MediaQuery.of(context).size.width / 6.2,
                        chartType: ChartType.ring,
                        ringStrokeWidth: 20,
                        legendOptions: const LegendOptions(
                            showLegendsInRow: true,
                            legendPosition: LegendPosition.top,
                            showLegends: false,
                            legendTextStyle: TextStyle(fontSize: 9)),
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValueBackground: false,
                          showChartValues: false,
                          showChartValuesInPercentage: false,
                          showChartValuesOutside: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget dealRowWidget(Color color, String text) {
    return Row(
      children: [
        Icon(
          AppThemePreferences.dotIcon,
          size: 15,
          color: color,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: GenericTextWidget(
            UtilityMethods.getLocalizedString(text),
            style: AppThemePreferences().appTheme.activitySubTitleTextStyle,
          ),
        )
      ],
    );
  }


  Widget showActivitiesList(BuildContext context, Future<List<dynamic>> futureActivitiesFromBoard) {
    return FutureBuilder<List<dynamic>>(
        future: futureActivitiesFromBoard,
        builder: (context, articleSnapshot) {
          isLoading = false;
          if (articleSnapshot.hasData) {
            if (articleSnapshot.data!.isEmpty) {
              return noResultFoundPage();
            } else if (articleSnapshot.data!.isNotEmpty) {
              List<dynamic> list = articleSnapshot.data!;

              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  CRMActivity activity = list[index];

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Card(
                      shape: AppThemePreferences.roundedCorners(
                          AppThemePreferences.globalRoundedCornersRadius),
                      elevation: AppThemePreferences.boardPagesElevation,
                      child: InkWell(
                        onTap: () {
                          if (activity.type == kReview) {
                            navigateToPage((context) => AllReviews(
                              id: activity.listingId,
                              fromProperty: activity.reviewPostType == "property" ? true : false,
                              reviewPostType: activity.reviewPostType,
                              title: activity.title,
                            ));
                          } else if (activity.type == kLeadContact) {
                            if (activity.leadPageId != null && activity.leadPageId!.isNotEmpty) {
                              navigateToPage((context) => LeadDetailPage(
                                index: index,
                                idForFetchLead: activity.leadPageId,
                                leadDetailPageListener: (_, __) {},
                              ));
                            }
                          } else if (activity.type == kLead && activity.subtype != kScheduleTour) {
                              navigateToPage((context) => const LeadsFromBoard());
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CRMTypeHeadingWidget(
                                getActivityTypeHeading(activity),
                                activity.time,
                              ),
                              CRMHeadingWidget(
                                activity.type == kReview
                                    ? activity.reviewTitle
                                    : activity.title,
                              ),
                              if (activity.type == kReview)
                                starsWidget("${activity.reviewStar}"),
                              CRMNormalTextWidget(
                                activity.type == kReview
                                    ? activity.reviewContent
                                    : activity.message,
                              ),
                              CRMContactDetail(
                                activity.type == kReview
                                    ? activity.userName
                                    : activity.name,
                                activity.email,
                                activity.phone,
                                () {
                                  takeActionBottomSheet(
                                      context, false, activity.email);
                                },
                                () {
                                  takeActionBottomSheet(
                                      context, true, activity.phone);
                                },
                              ),
                              // activityDetailWidget(activity),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }
          return loadingIndicatorWidget();
        });
  }

  void navigateToPage(WidgetBuilder builder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: builder,
      ),
    );
  }

  Widget starsWidget(String? totalRating) {
    return totalRating == null
        ? Container()
        : Padding(
            padding: EdgeInsets.only(left: 0, right: 0, bottom: bottomPadding),
            child: RatingBar.builder(
              initialRating: double.parse(totalRating),
              minRating: 1,
              itemSize: 20,
              direction: Axis.horizontal,
              allowHalfRating: true,
              ignoreGestures: true,
              itemCount: 5,
              // itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: AppThemePreferences.ratingWidgetStarsColor,
              ),
              onRatingUpdate: (rating) {},
            ),
          );
  }

  Widget noResultFoundPage() {
    return NoResultErrorWidget(
      headerErrorText: UtilityMethods.getLocalizedString("no_result_found"),
      bodyErrorText:
          UtilityMethods.getLocalizedString("oops_activities_not_exist"),
    );
  }

  Widget loadingIndicatorWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 80,
        height: 20,
        child: BallBeatLoadingWidget(),
      ),
    );
  }

}
