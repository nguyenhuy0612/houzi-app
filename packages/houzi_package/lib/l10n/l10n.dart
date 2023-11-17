import 'package:flutter/material.dart';
import 'package:houzi_package/files/hooks_files/hooks_configurations.dart';
import 'package:collection/collection.dart';


class L10n {
  static List<Locale> all = getAllLanguagesLocale();

  static String getLanguageName(String code) {
    // if (code == 'en') {
    //   return 'English';
    // } else {
    //   if (code.isNotEmpty) {
        String languageName = findFromLanguageHook(code);
        // if (languageName.isNotEmpty) {
          return languageName;
        // }
      // }

    //   return 'English';
    // }
  }

  static getAllLanguagesLocale() {
    LanguageHook languageHook = HooksConfigurations.languageNameAndCode;
    List<Locale> localeList = [
      // const Locale('en'),
    ];

    List<dynamic> languageList = languageHook();
    for (var languageMap in languageList) {
      languageMap.removeWhere((key, value) => value == null || value.isEmpty);
      if (languageMap != null && languageMap.isNotEmpty) {
        localeList.add(Locale(languageMap["languageCode"]));
      }
    }

    return localeList;
  }

  static String findFromLanguageHook(String code) {
    LanguageHook languageHook = HooksConfigurations.languageNameAndCode;
    List<dynamic> languageList = languageHook();
    Map<String, dynamic>? map = languageList.firstWhereOrNull(
        (element) => element["languageCode"] == code);
    if (map != null) {
      return map["languageName"];
    }

    return "";
  }
}
