import 'package:flutter/material.dart';
import 'package:houzi_package/providers/state_providers/locale_provider.dart';
import 'package:houzi_package/files/generic_methods/general_notifier.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/files/theme_service_files/theme_notifier.dart';
import 'package:houzi_package/models/property_meta_data.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';
import 'package:provider/provider.dart';

import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/pages/search_result.dart';


class TermWithIconsWidget extends StatefulWidget {
  const TermWithIconsWidget({Key? key}) : super(key: key);

  @override
  State<TermWithIconsWidget> createState() => _TermWithIconsWidgetState();
}

class _TermWithIconsWidgetState extends State<TermWithIconsWidget> {

  List<Term> dataList = [];

  final Map<String, dynamic> _iconMap = UtilityMethods.iconMap;

  VoidCallback? generalNotifierListener;

  @override
  void initState() {
    super.initState();

    generalNotifierListener = () {
      if (GeneralNotifier().change == GeneralNotifier.FILTER_DATA_LOADING_COMPLETE) {
        if(mounted){
          setState(() {
            loadData();
          });
        }
      }
    };
    GeneralNotifier().addListener(generalNotifierListener!);

    loadData();
  }

  void loadData() {
    List<Term> propertyStatusDataList = HiveStorageManager.readPropertyStatusMetaData() ?? [];
    List<Term> propertyTypesDataList = HiveStorageManager.readPropertyTypesMetaData() ?? [];

    dataList = [...removeChildTypesStatus(propertyStatusDataList), ...removeChildTypesStatus(propertyTypesDataList)];
  }


  removeChildTypesStatus(List<Term> dataList) {
    dataList.removeWhere((element) => element.parent != 0 || element.totalPropertiesCount! <= 0);
    return dataList;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    double boxSize = (width / 4) - 5;

    return dataList.isEmpty
        ? Container()
        : Consumer<ThemeNotifier>(
            builder: (context, theme, child) {
              return Consumer<LocaleProvider>(
                builder: (context, locale, child) {
                  loadData();
                  return Container(
                    height: boxSize,
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.only(left: 5),
                    child: ListView.builder(
                      itemCount: dataList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        Term propertyMetaData = dataList[index];
                        return TermWithIconsBodyWidget(
                          propertyMetaData: propertyMetaData,
                          boxSize: boxSize,
                          iconMap: _iconMap,
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
  }
}

class TermWithIconsBodyWidget extends StatelessWidget {
  final Term propertyMetaData;
  final double boxSize;
  final Map<String, dynamic> iconMap;

  const TermWithIconsBodyWidget({
    required this.boxSize,
    required this.iconMap,
    required this.propertyMetaData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Map<String, dynamic> map = {
          "${propertyMetaData.taxonomy}_slug" : [propertyMetaData.slug],
          "${propertyMetaData.taxonomy}" : [propertyMetaData.name]
        };

        HiveStorageManager.storeFilterDataInfo(map: map);

        GeneralNotifier().publishChange(GeneralNotifier.FILTER_DATA_LOADING_COMPLETE);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResult(
              dataInitializationMap: map,
              searchPageListener: (Map<String, dynamic> map, String closeOption) {
                if (closeOption == CLOSE) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        );

      },
      child: Container(
        width: boxSize,
        padding: EdgeInsets.only(left: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: AppThemePreferences.zeroElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppThemePreferences.propertyDetailFeaturesRoundedCornersRadius),
              ),
              color: AppThemePreferences().appTheme.containerBackgroundColor,
              child: _buildIconWidget(propertyMetaData.slug!),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: GenericTextWidget(
                  UtilityMethods.getLocalizedString(propertyMetaData.name!),
                  strutStyle: StrutStyle(height: AppThemePreferences.genericTextHeight, forceStrutHeight: true),
                  style: AppThemePreferences().appTheme.label01TextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconWidget(String slug) {
    if (iconMap.containsKey(slug)) {
      final icon = iconMap[slug];
      if (icon is IconData) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Icon(
            icon,
            size: AppThemePreferences.propertyDetailsFeaturesIconSize,
          ),
        );
      } else if (icon is Widget) {
        return SizedBox(
          width: boxSize - 40,
          height: boxSize - 40,
          child: icon,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Icon(
        AppThemePreferences.homeIcon,
        size: AppThemePreferences.propertyDetailsFeaturesIconSize,
      ),
    );
  }
}

