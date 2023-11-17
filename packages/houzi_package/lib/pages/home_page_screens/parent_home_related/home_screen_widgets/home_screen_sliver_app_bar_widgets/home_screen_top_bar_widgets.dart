import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/hooks_files/hooks_configurations.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/pages/city_picker.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';
import 'package:houzi_package/widgets/toast_widget.dart';

typedef HomeScreenTopBarWidgetListener = void Function({Map<String, dynamic>? filterDataMap});

class HomeScreenTopBarWidget extends StatefulWidget {
  final String selectedCity;
  final HomeScreenTopBarWidgetListener? homeScreenTopBarWidgetListener;

  const HomeScreenTopBarWidget({
    Key? key,
    required this.selectedCity,
    this.homeScreenTopBarWidgetListener,
  }) : super(key: key);

  @override
  State<HomeScreenTopBarWidget> createState() => _HomeScreenTopBarWidgetState();
}

class _HomeScreenTopBarWidgetState extends State<HomeScreenTopBarWidget> {

  HomeRightBarButtonWidgetHook? rightBarButtonIdWidgetHook = HooksConfigurations.homeRightBarButtonWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5.0, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          HomeScreenLocationWidget(
            selectedCity: widget.selectedCity,
            homeScreenLocationWidgetListener: ({filterDataMap, loadProperties}){
              widget.homeScreenTopBarWidgetListener!(filterDataMap: filterDataMap);
            },
          ),
          rightBarButtonIdWidgetHook!(context) ?? Container(),
        ],
      ),
    );
  }
}

class HomeScreenLocationWidget extends StatefulWidget {
  final String selectedCity;
  final HomeScreenTopBarWidgetListener? homeScreenLocationWidgetListener;
  const HomeScreenLocationWidget({
    Key? key,
    required this.selectedCity,
    this.homeScreenLocationWidgetListener,
  }) : super(key: key);

  @override
  State<HomeScreenLocationWidget> createState() => _HomeScreenLocationWidgetState();
}

class _HomeScreenLocationWidgetState extends State<HomeScreenLocationWidget> {
  List<dynamic> citiesMetaDataList = [];


  @override
  void initState() {
    super.initState();
    citiesMetaDataList = HiveStorageManager.readCitiesMetaData() ?? [];
  }


  @override
  void dispose() {
    super.dispose();
    citiesMetaDataList = [];
  }

  @override
  Widget build(BuildContext context) {
    if(citiesMetaDataList.isEmpty){
      citiesMetaDataList = HiveStorageManager.readCitiesMetaData() ?? [];
    }

    return GestureDetector(
      onTap: () {
        if(citiesMetaDataList.isEmpty){
          ShowToastWidget(buildContext: context, text: UtilityMethods.getLocalizedString("data_loading"));
        }else{
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CityPicker(
                  citiesMetaDataList: citiesMetaDataList,
                  cityPickerListener: (String pickedCity, int? pickedCityId, String pickedCitySlug) {
                    Map<String, dynamic> filterDataMap = HiveStorageManager.readFilterDataInfo() ?? {};
                    filterDataMap[CITY_ID] = [pickedCityId];
                    filterDataMap[CITY] = [pickedCity];
                    filterDataMap[CITY_SLUG] = [pickedCitySlug];
                    HiveStorageManager.storeFilterDataInfo(map: filterDataMap);

                    widget.homeScreenLocationWidgetListener!(filterDataMap: filterDataMap);
                  }),
            ),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 35),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: AppThemePreferences().appTheme.homeScreenTopBarLocationIcon,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenericTextWidget(
                  UtilityMethods.getLocalizedString("location"),
                  strutStyle: const StrutStyle(forceStrutHeight: true),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: GenericTextWidget(
                    widget.selectedCity,
                    strutStyle: const StrutStyle(forceStrutHeight: true),
                    style:  AppThemePreferences().appTheme.locationWidgetTextStyle,
                  ),
                ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(left: 5, top: 20),
              child: CircleAvatar(
                radius: 7,
                backgroundColor: AppThemePreferences().appTheme.homeScreenTopBarRightArrowBackgroundColor,
                child: AppThemePreferences().appTheme.homeScreenTopBarRightArrowIcon,
              )),
        ],
      ),
    );
  }
}