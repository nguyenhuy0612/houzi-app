import 'package:flutter/material.dart';
import 'package:houzi_package/pages/home_page_screens/parent_home_related/parent_home.dart';

import 'related_widgets/home_elegant_sliver_app_bar.dart';
import 'related_widgets/home_elegant_widgets_listings.dart';

class HomeElegant extends Home {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const HomeElegant({
    Key? key,
    this.scaffoldKey
  }) : super(key: key);

  @override
  _HomeElegantState createState() => _HomeElegantState();
}

class _HomeElegantState extends HomeState<HomeElegant> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

  }

  @override
  Widget getSliverAppBarWidget(){
    return HomeElegantSliverAppBarWidget(
      onLeadingIconPressed: () => widget.scaffoldKey!.currentState!.openDrawer(),
      selectedCity: super.getSelectedCity(),
      selectedStatusIndex: super.getSelectedStatusIndex(),
      homeElegantSliverAppBarListener: ({filterDataMap}){
        if(filterDataMap != null && filterDataMap.isNotEmpty){
          super.updateData(filterDataMap);
        }
      },
    );
  }

  @override
  Widget getListingsWidget(dynamic item){
    return HomeElegantListingsWidget(
      homeScreenData: item,
      refresh: super.needToRefresh,
      homeScreen02ListingsWidgetListener: (bool errorOccur, bool dataRefresh){
        if(mounted){
          setState(() {
            super.errorWhileDataLoading = errorOccur;
            super.needToRefresh = dataRefresh;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if(widget.scaffoldKey != null){
      super.scaffoldKey = widget.scaffoldKey!;
    }

    return super.build(context);
  }
}
