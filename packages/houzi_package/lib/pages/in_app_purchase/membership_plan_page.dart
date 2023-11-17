import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:houzi_package/blocs/property_bloc.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/files/hooks_files/hooks_configurations.dart';
import 'package:houzi_package/models/article.dart';
import 'package:houzi_package/models/user_membership_package.dart';
import 'package:houzi_package/pages/in_app_purchase/payment_page.dart';
import 'package:houzi_package/widgets/app_bar_widget.dart';
import 'package:houzi_package/widgets/button_widget.dart';
import 'package:houzi_package/widgets/data_loading_widget.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';
import 'package:houzi_package/widgets/no_result_error_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../common/constants.dart';

class MembershipPlanPage extends StatefulWidget {
  final bool fetchMembershipDetail;

  const MembershipPlanPage({this.fetchMembershipDetail = false, Key? key})
      : super(key: key);

  @override
  State<MembershipPlanPage> createState() => _MembershipPlanPageState();
}

class _MembershipPlanPageState extends State<MembershipPlanPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  List<dynamic> membershipPackageList = [];
  Future<List<dynamic>>? _futureMembershipPackage;
  UserMembershipPackage? userMembershipPackage;

  bool isRefreshing = false;
  bool shouldLoadMore = true;
  bool isLoading = false;
  bool loadMembershipDetail = false;
  int perPage = 10;

  MembershipPlanHook membershipPlanHook = HooksConfigurations.membershipPlanHook;

  @override
  void initState() {
    super.initState();
    isRefreshing = true;
    loadDataFromApi();
  }

  loadDataFromApi({bool forPullToRefresh = true}) {
    if (forPullToRefresh) {
      if (isLoading) {
        return;
      }
      setState(() {
        isRefreshing = true;
        isLoading = true;
      });

      _futureMembershipPackage = fetchMembershipPackages();
      _refreshController.refreshCompleted();
    } else {
      if (!shouldLoadMore || isLoading) {
        _refreshController.loadComplete();
        return;
      }
      setState(() {
        isRefreshing = false;
        isLoading = true;
      });
      _futureMembershipPackage = fetchMembershipPackages();
      _refreshController.loadComplete();
    }
  }

  Future<List<dynamic>> fetchMembershipPackages() async {
    List<dynamic> tempList = [];
    if (widget.fetchMembershipDetail) {
      tempList = [await PropertyBloc().fetchUserMembershipPackageResponse()];
    } else {
      tempList = await PropertyBloc().fetchMembershipPackages();
    }

    if (tempList == null ||
        (tempList.isNotEmpty && tempList[0] == null) ||
        (tempList.isNotEmpty && tempList[0].runtimeType == Response)) {
      if (mounted) {
        setState(() {
          shouldLoadMore = false;
        });
      }
      return membershipPackageList;
    } else {
      if (tempList.isEmpty || tempList.length < perPage) {
        if (mounted) {
          setState(() {
            shouldLoadMore = false;
          });
        }
      }

      if (tempList.isNotEmpty) {
        membershipPackageList.addAll(tempList);
      }
    }

    return membershipPackageList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        appBarTitle: UtilityMethods.getLocalizedString("Membership Plan"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureMembershipPackage,
        builder: (context, articleSnapshot) {
          isLoading = false;
          if (articleSnapshot.hasData) {
            if (articleSnapshot.data!.isEmpty) {
              return noResultFoundPage();
            }

            List<dynamic> list = articleSnapshot.data!;
            if (widget.fetchMembershipDetail) {
              UserMembershipPackage userMembershipPackage = list[0];
              return SizedBox(
                // width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    MembershipPlanDetail(
                      label: "Your Current Package",
                      title: userMembershipPackage.packTitle,
                    ),
                    Divider(),
                    MembershipPlanDetail(
                      label: "Listings Included:",
                      title: userMembershipPackage.packListings,
                    ),
                    Divider(),
                    MembershipPlanDetail(
                      label: "Listings Remaining:",
                      title: userMembershipPackage.remainingListings == "-1"
                          ? "Unlimited"
                          : userMembershipPackage.remainingListings,
                    ),
                    Divider(),
                    MembershipPlanDetail(
                      label: "Featured Included:",
                      title: userMembershipPackage.packFeaturedListings,
                    ),
                    Divider(),
                    MembershipPlanDetail(
                      label: "Featured Remaining:",
                      title:
                          userMembershipPackage.packFeaturedRemainingListings,
                    ),
                    Divider(),
                    MembershipPlanDetail(
                      label: "Ends On",
                      title: userMembershipPackage.expiredDate,
                    ),
                  ],
                ),
              );
            } else {
              return membershipPlanHook(context,list) ??
               PageView.builder(
                itemCount: list.length,
                controller: PageController(viewportFraction: 0.9),
                itemBuilder: (context, index) {
                  Article article = list[index];
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: MembershipPlanWidget(article),
                  );
                },
              );
            }
          } else if (articleSnapshot.hasError) {
            return noResultFoundPage();
          }
          return loadingIndicatorWidget();
        },
      ),
    );
  }

  Widget loadingIndicatorWidget() {
    return Container(
      height: (MediaQuery.of(context).size.height) / 2,
      margin: const EdgeInsets.only(top: 50),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 80,
        height: 20,
        child: BallBeatLoadingWidget(),
      ),
    );
  }

  Widget noResultFoundPage() {
    return NoResultErrorWidget(
      headerErrorText: UtilityMethods.getLocalizedString("no_result_found"),
      bodyErrorText: UtilityMethods.getLocalizedString("oops_membership_not_exist"),
    );
  }
}

class MembershipPlanWidget extends StatelessWidget {
  final Article article;

  const MembershipPlanWidget(this.article, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return article.membershipPlanDetails == null
        ? Container()
        : Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.symmetric(vertical: 38.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            // width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MembershipPlanTitle(article.title!),
                MembershipPlanPrice(article.membershipPlanDetails!.packagePrice!),
                SizedBox(
                  height: 20,
                ),
                Card(
                  elevation: AppThemePreferences.zeroElevation,
                  shape: AppThemePreferences.roundedCorners(AppThemePreferences
                      .propertyDetailPageRoundedCornersRadius),
                  color:
                      AppThemePreferences().appTheme.containerBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        MembershipPlanDetail(
                          label: "Duration:",
                          title:
                              "${article.membershipPlanDetails!.billingUnit!} ${article.membershipPlanDetails!.billingTimeUnit!}",
                        ),
                        Divider(),
                        MembershipPlanDetail(
                          title: article.membershipPlanDetails!
                                      .unlimitedListings ==
                                  "1"
                              ? "Unlimited"
                              : article.membershipPlanDetails!.packageListings!,
                          label:
                              "Properties",
                        ),
                        Divider(),
                        MembershipPlanDetail(
                          title:
                              "${article.membershipPlanDetails!.packageFeaturedListings}",
                          label:
                              "Featured Listings:",
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: ButtonWidget(
                      text: UtilityMethods.getLocalizedString("Get Started"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentPage(
                              productIds: Platform.isAndroid
                                  ? [
                                      article.membershipPlanDetails!
                                          .androidIAPProductId!
                                    ]
                                  : [
                                      article.membershipPlanDetails!
                                          .iosIAPProductId!
                                    ],
                              packageId: article.id.toString(),
                              isMembership: true,
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          );
  }
}

class MembershipPlanTitle extends StatelessWidget {
  final String title;

  const MembershipPlanTitle(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0, top: 10),
      child: GenericTextWidget(
        title,
        style: AppThemePreferences().appTheme.membershipTitleTextStyle,
      ),
    );
  }
}

class MembershipPlanPrice extends StatelessWidget {
  final String price;

  const MembershipPlanPrice(this.price, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GenericTextWidget(
          HiveStorageManager.readDefaultCurrencyInfoData(),
          style: AppThemePreferences().appTheme.membershipTitleTextStyle,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 38.0),
          child: GenericTextWidget(
            price,
            style: AppThemePreferences().appTheme.membershipPriceTextStyle,
          ),
        ),
      ],
    );
  }
}

class MembershipPlanDetail extends StatelessWidget {
  final String? title;
  final String? label;

  const MembershipPlanDetail({required this.title, this.label, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon(AppThemePreferences.checkCircleIcon),
          GenericTextWidget(UtilityMethods.getLocalizedString(label ?? "")),
          GenericTextWidget(
            UtilityMethods.getLocalizedString(title ?? ""),
            style: TextStyle(fontWeight: FontWeight.bold),
          )
          // SizedBox(
          //   height: 20,
          //   width: 10,
          // ),
          // label != null
          //     ? GenericTextWidget("$label $title")
          //     : GenericTextWidget(title ?? ""),
        ],
      ),
    );
  }
}
