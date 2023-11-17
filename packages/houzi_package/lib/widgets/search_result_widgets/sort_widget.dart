import 'package:flutter/material.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';

typedef SortMenuWidgetListener = Function({
  int? currentSortValue,
  int? previousSortValue,
  bool? sortFlag,
});

class SortMenuWidget extends StatefulWidget {
  final Map<String, dynamic> sortByMenuOptions;
  final int currentPropertyListSortValue;
  final int previousPropertyListSortValue;
  final SortMenuWidgetListener listener;

  const SortMenuWidget({
    Key? key,
    required this.currentPropertyListSortValue,
    required this.previousPropertyListSortValue,
    required this.sortByMenuOptions,
    required this.listener,
  }) : super(key: key);

  @override
  State<SortMenuWidget> createState() => _SortMenuWidgetState();
}

class _SortMenuWidgetState extends State<SortMenuWidget> {

  int currentSortValue = 0;
  int previousSortValue = -1;


  @override
  void initState() {
    currentSortValue = widget.currentPropertyListSortValue;
    previousSortValue = widget.previousPropertyListSortValue;

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter state) {
          return ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 300,
              maxHeight: 320,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Card(
                  color: Theme.of(context).backgroundColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 25, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// DROP DOWN MENU TITLE
                        const Expanded(
                          flex: 2,
                          child: Icon(
                            Icons.sort_outlined,
                            size: 30,
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: GenericTextWidget(
                            UtilityMethods.getLocalizedString("sort_by"),
                            style: AppThemePreferences().appTheme.bottomSheetMenuTitleTextStyle,
                          ),
                        ),

                        // ICON: TICK MARK => DONE
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: AppThemePreferences().appTheme.bottomNavigationMenuIcon!,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // DROP DOWN MENU GENERATION
                Container(
                  color: Theme.of(context).backgroundColor,
                  padding: const EdgeInsets.only(top: 20, left: 10, bottom: 5, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.sortByMenuOptions.entries.map<Widget>((item) => Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Icon(
                            item.value,
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: GestureDetector(
                            child: GenericTextWidget(
                              UtilityMethods.getLocalizedString(item.key), // KEY CONTAINS THE OPTION
                              style: AppThemePreferences().appTheme.bottomNavigationMenuItemsTextStyle,
                            ),
                            onTap: () {
                              onSortItemTap(item);
                              state(() {
                                onSortRadioItemTap(item);
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Radio(
                            activeColor: AppThemePreferences.radioActiveColor,
                            value: widget.sortByMenuOptions.entries
                                .map((e) => e.key)
                                .toList()
                                .indexWhere((element) =>
                            item.key == element),
                            groupValue: currentSortValue,
                            onChanged: (value) {
                              onSortItemTap(item);
                              state(() {
                                onSortRadioItemTap(item);
                              });
                            },
                          ),
                        ),
                      ],
                    )).toList(),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void onSortItemTap(item){
    if(mounted) {
      setState(() {
        if (currentSortValue != previousSortValue) {
          previousSortValue = currentSortValue;
          widget.listener(
            sortFlag: true,
            previousSortValue: previousSortValue,
          );
        }
        currentSortValue = widget.sortByMenuOptions.entries
            .map((e) => e.key)
            .toList()
            .indexWhere((element) =>
        item.key == element);

        widget.listener(currentSortValue: currentSortValue);
      });
    }
  }

  void onSortRadioItemTap(item){
    currentSortValue = widget.sortByMenuOptions.entries
        .map((e) => e.key)
        .toList()
        .indexWhere((element) =>
    item.key == element);

    widget.listener(currentSortValue: currentSortValue);
  }
}
