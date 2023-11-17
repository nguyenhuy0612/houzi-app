import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/providers/state_providers/locale_provider.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/general_notifier.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/pages/city_picker.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';
import 'package:houzi_package/widgets/toast_widget.dart';
import 'package:provider/provider.dart';

typedef HomeElegantScreenTopBarWidgetListener = void Function({Map<String, dynamic>? filterDataMap});

class HomeElegantScreenTopBarWidget extends StatefulWidget {
  final String selectedCity;
  final Widget? rightBarButtonIdWidget;
  final HomeElegantScreenTopBarWidgetListener? homeElegantScreenTopBarWidgetListener;

  const HomeElegantScreenTopBarWidget({
    Key? key,
    required this.selectedCity,
    this.rightBarButtonIdWidget,
    this.homeElegantScreenTopBarWidgetListener,
  }) : super(key: key);

  @override
  _HomeElegantScreenTopBarWidgetState createState() => _HomeElegantScreenTopBarWidgetState();
}

class _HomeElegantScreenTopBarWidgetState extends State<HomeElegantScreenTopBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, locale, child) {
        return Container(
          padding: const EdgeInsets.only(top: 5.0, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HomeElegantScreenLocationWidget(
                selectedCity: widget.selectedCity,
                homeElegantScreenTopBarWidgetListener: ({filterDataMap}) {
                  widget.homeElegantScreenTopBarWidgetListener!(filterDataMap: filterDataMap);
                },
              ),
              if (widget.rightBarButtonIdWidget != null)
                widget.rightBarButtonIdWidget!,
            ],
          ),
        );
      },
    );
  }
}

class HomeElegantScreenLocationWidget extends StatefulWidget {
  final String selectedCity;
  final HomeElegantScreenTopBarWidgetListener? homeElegantScreenTopBarWidgetListener;
  const HomeElegantScreenLocationWidget({
    Key? key,
    required this.selectedCity,
    this.homeElegantScreenTopBarWidgetListener,
  }) : super(key: key);

  @override
  State<HomeElegantScreenLocationWidget> createState() => _HomeElegantScreenLocationWidgetState();
}

class _HomeElegantScreenLocationWidgetState extends State<HomeElegantScreenLocationWidget> {

  String selectedCity = "";
  List<dynamic> citiesMetaDataList = [];
  VoidCallback? generalNotifierLister;

  @override
  void initState() {
    super.initState();
    citiesMetaDataList = HiveStorageManager.readCitiesMetaData() ?? [];
    selectedCity = widget.selectedCity;

    generalNotifierLister = () {
      if (GeneralNotifier().change == GeneralNotifier.CITY_DATA_UPDATE) {
        Map map = HiveStorageManager.readSelectedCityInfo();
        if (map.isNotEmpty) {
          selectedCity = map[CITY] ?? UtilityMethods.getLocalizedString("please_select");
        } else {
          selectedCity = UtilityMethods.getLocalizedString("please_select");
        }
        if (mounted) {
          setState(() {});
        }
      }
    };

    GeneralNotifier().addListener(generalNotifierLister!);
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
                    filterDataMap[CITY] = [pickedCity];
                    filterDataMap[CITY_ID] = [pickedCityId];
                    filterDataMap[CITY_SLUG] = [pickedCitySlug];
                    HiveStorageManager.storeFilterDataInfo(map: filterDataMap);

                    widget.homeElegantScreenTopBarWidgetListener!(filterDataMap: filterDataMap);
                  }),
            ),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 35),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GenericTextWidget(
                  UtilityMethods.getLocalizedString("current_location"),
                  strutStyle: const StrutStyle(forceStrutHeight: true),
                  style: AppThemePreferences().appTheme.subTitleTextStyle
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Row(
                  children: [
                    AppThemePreferences().appTheme.homeScreenTopBarLocationFilledIcon!,
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0,top: 2),
                      child: GenericTextWidget(
                        UtilityMethods.getLocalizedString(selectedCity),
                        strutStyle: const StrutStyle(forceStrutHeight: true),
                        style:  AppThemePreferences().appTheme.titleTextStyle,
                      ),
                    ),
                    AppThemePreferences().appTheme.homeScreenTopBarDownArrowIcon!,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}