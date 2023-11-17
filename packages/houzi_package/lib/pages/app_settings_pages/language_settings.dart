import 'package:flutter/material.dart';
import 'package:houzi_package/files/hooks_files/hooks_configurations.dart';
import 'package:houzi_package/providers/state_providers/locale_provider.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/l10n/l10n.dart';
import 'package:houzi_package/widgets/app_bar_widget.dart';
import 'package:houzi_package/widgets/generic_radio_list_tile.dart';
import 'package:houzi_package/widgets/header_widget.dart';
import 'package:provider/provider.dart';
import 'package:houzi_package/pages/main_screen_pages/my_home_page.dart';

class LanguageSettings extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => LanguageSettingsState();
}

class LanguageSettingsState extends State<LanguageSettings> {

  Locale? locale;
  LocaleProvider? provider;

  List list = [];

  String? _selectedLanguage;


  @override
  void initState() {
    super.initState();
    DefaultLanguageCodeHook defaultLanguageCodeHook = HooksConfigurations.defaultLanguageCode;
    // String defaultLanguage = defaultLanguageCodeHook().isEmpty ? "en" : defaultLanguageCodeHook();
    String defaultLanguage = defaultLanguageCodeHook();
    String localeFromStorage = HiveStorageManager.readLanguageSelection() ?? defaultLanguage;
    Locale tempLocale = Locale(localeFromStorage);
    final tempFlag = L10n.getLanguageName(tempLocale.languageCode);
    _selectedLanguage = tempFlag;
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBarWidget(
        appBarTitle: UtilityMethods.getLocalizedString("language_label"),
      ),
      body: Column(
        children: [
          headingWidget(text: UtilityMethods.getLocalizedString("select_language")),
          selectLanguageWidget(),
        ],
      ),
    );
  }

  Widget headingWidget({required String text}){
    return HeaderWidget(
      text: text,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppThemePreferences().appTheme.dividerColor!),
        ),
      ),
    );
  }

  Widget selectLanguageWidget(){
    return Column(
      children: L10n.all.map((locale) {
        final flag = L10n.getLanguageName(locale.languageCode);
        return  GenericRadioListTile(
          title: flag,
          value: flag,
          groupValue: _selectedLanguage!,
          onChanged: (value) {
            if(mounted) setState(() {
              _selectedLanguage = value;
            });
            provider = Provider.of<LocaleProvider>(context, listen: false);
            provider!.setLocale(locale);
            UtilityMethods.navigateToRouteByPushAndRemoveUntil(context: context, builder: (context) => const MyHomePage());
          },
        );
      }).toList(),
    );
  }
}
