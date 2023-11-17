import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/saved_searches.dart';
import 'package:houzi_package/widgets/app_bar_widget.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';

import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'favorites.dart';

typedef SavedPageListener = void Function(String closeOption);

class Saved extends StatefulWidget {

  final SavedPageListener savedPageListener;

  Saved(this.savedPageListener,);

  @override
  _SavedState createState() => _SavedState();
}

class _SavedState extends State<Saved> with AutomaticKeepAliveClientMixin<Saved>  {

  TabController? _tabController;

  @override
  void initState() {
    super.initState();

  }

  @override
  dispose() {
    if (_tabController != null) {
      _tabController!.dispose();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () {
        widget.savedPageListener(CLOSE);
        return Future.value(false);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: appBarForTabWidget(),
          body: TabBarView(
            controller: _tabController,
            children: [
              Favorites(),
              SavedSearches(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget appBarForTabWidget() {
    return AppBarWidget(
      appBarTitle: "",
      toolbarHeight: 0.0,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        tabs: [
          Tab(
            child: GenericTextWidget(
              UtilityMethods.getLocalizedString("favorites"), style: AppThemePreferences().appTheme.genericTabBarTextStyle,
            ),
          ),
          Tab(
            child: GenericTextWidget(
              UtilityMethods.getLocalizedString("saved_searches"), style: AppThemePreferences().appTheme.genericTabBarTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}