import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houzi_package/files/hooks_files/hooks_configurations.dart';
import 'package:houzi_package/l10n/l10n.dart';


Map<String, dynamic>? _language;

String? stringBy({String key = ""}) {
  return _language?[key].toString() ?? key;
}

class CustomLocalisationDelegate extends LocalizationsDelegate {
  CustomLocalisationDelegate();


  List _supportedLocale = [];
  @override
  bool isSupported(Locale locale) {
    LanguageHook languageHook = HooksConfigurations.languageNameAndCode;
    List<dynamic> languageList = languageHook();
    for (var languageMap in languageList) {
      languageMap.removeWhere((key, value) => value == null || value.isEmpty);
      if (languageMap != null && languageMap.isNotEmpty) {
        _supportedLocale.add(languageMap["languageCode"]);
      }
    }
    // final _supportedLocale = L10n.getAllLanguagesLocale();
    return _supportedLocale.contains(locale.languageCode);
  }

  @override
  Future load(Locale locale) async {
    String jsonString = await rootBundle.loadString('assets/localization/${locale.languageCode}_localization.json');

    _language = jsonDecode(jsonString) as Map<String, dynamic>;
    // print(_language.toString());
    return SynchronousFuture<CustomLocalisationDelegate>(CustomLocalisationDelegate());
  }

  @override
  bool shouldReload(CustomLocalisationDelegate old) => true;
}
