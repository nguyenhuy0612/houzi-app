import 'dart:convert';
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/models/api_response.dart';
import 'package:houzi_package/models/custom_fields.dart';
import 'package:houzi_package/models/user_membership_package.dart';
import 'package:houzi_package/providers/api_providers/houzez_api_provider.dart';
import 'package:houzi_package/providers/api_providers/property_api_provider.dart';

import '../common/constants.dart';

class PropertyRepository {
  // PropertyApiProvider propertyApiProvider = PropertyApiProvider(EPLApiProvider());
  PropertyApiProvider propertyApiProvider =
      PropertyApiProvider(HOUZEZApiProvider());

  Future<List> fetchLatestArticlesList(int page) async {
    List<dynamic> latestArticles = [];
    final response = await propertyApiProvider.fetchLatestArticlesResponse(page);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304) &&
        response.data is Map &&
        response.data.containsKey("result")) {
      dynamic data = response.data["result"];
      List<dynamic> articles = data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList();
      latestArticles.addAll(articles);
    } else {
      if (response.statusCode == null) {
        latestArticles = [response];
      }
    }

    return latestArticles;
  }

  Future<Map<String, dynamic>> fetchFilteredArticlesList(
      Map<String, dynamic> dataMap) async {
    Map<String, dynamic> articleMap = Map();
    final response =
        await propertyApiProvider.fetchFilteredArticlesResponse(dataMap);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304) &&
        response.data is Map &&
        response.data.containsKey("result")) {
      articleMap["count"] = response.data["count"];
      articleMap["result"] = response.data["result"]
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList();
    } else {
      if (response.statusCode == null) {
        articleMap["response"] = response;
      }
    }

    return articleMap;
  }

  Future<List> fetchSimilarArticlesList(int propertyId) async {
    List<dynamic> similarArticles = [];
    final response =
        await propertyApiProvider.fetchSimilarPropertiesResponse(propertyId);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304) &&
        response.data is Map &&
        response.data.containsKey("result")) {
      similarArticles.addAll(response.data['result']
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        similarArticles = [response];
      }
    }
    return similarArticles;
  }

  Future<List> fetchMultipleArticles(String propertiesId) async {
    List<dynamic> multipleArticles = [];
    final response =
        await propertyApiProvider.fetchMultipleArticlesResponse(propertiesId);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      multipleArticles.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        multipleArticles = [response];
      }
    }
    return multipleArticles;
  }

  Future<List> fetchFeaturedArticlesList(int page) async {
    List<dynamic> featuredArticles = [];
    final response =
        await propertyApiProvider.fetchFeaturedArticlesResponse(page);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      featuredArticles.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        featuredArticles = [response];
      }
    }

    return featuredArticles;
  }

  Future<List> fetchSingleArticleList(int id, {bool forEditing = false}) async {
    List<dynamic> singleArticle = [];
    final response = await propertyApiProvider.fetchSingleArticleResponse(id,
        forEditing: forEditing);
    if (response != null &&
        response.data != null &&
        ((response.statusCode == 200 || response.statusCode == 304) ||
            response.statusCode == 304)) {
      singleArticle.add(
          propertyApiProvider.getCurrentParser().parseArticle(response.data));
    } else {
      if (response.statusCode == null) {
        singleArticle = [response];
      }
    }

    return singleArticle;
  }

  Future<Map<String, dynamic>> fetchPropertyMetaData() async {
    Map<String, dynamic> touchBaseDataMap = {};

    dynamic dataHolder;
    List<dynamic> listDataHolder = [];

    final response = await propertyApiProvider.fetchPropertyMetaDataApi();
    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 304) &&
        response.data != null &&
        response.data is Map) {
      touchBaseDataMap = UtilityMethods.convertMap(response.data);
      if (touchBaseDataMap.isNotEmpty) {
        // City Meta Data
        dataHolder = UtilityMethods.getListItemValueFromMap(
                inputMap: touchBaseDataMap, key: propertyCityDataType) ??
            [];
        listDataHolder = parseMetaDataList(dataHolder);
        if (listDataHolder.isNotEmpty) {
          HiveStorageManager.storeCitiesMetaData(listDataHolder);
        }
        // Property Type Meta Data
        dataHolder = UtilityMethods.getListItemValueFromMap(
                inputMap: touchBaseDataMap, key: propertyTypeDataType) ??
            [];
        listDataHolder = parseMetaDataList(dataHolder);
        if (listDataHolder.isNotEmpty) {
          HiveStorageManager.storePropertyTypesMetaData(listDataHolder);
        }
        // Property Type Meta Data
        dataHolder = UtilityMethods.getListItemValueFromMap(
                inputMap: touchBaseDataMap, key: propertyTypeDataType) ??
            [];
        listDataHolder = parseMetaDataList(dataHolder);
        if (listDataHolder.isNotEmpty) {
          HiveStorageManager.storePropertyTypesMetaData(listDataHolder);
          dataHolder = UtilityMethods.getParentAndChildCategorizedMap(
              metaDataList: listDataHolder);
          if (dataHolder.isNotEmpty) {
            HiveStorageManager.storePropertyTypesMapData(dataHolder);
          }
        }
        // Property Country Meta Data
        dataHolder = UtilityMethods.getListItemValueFromMap(
                inputMap: touchBaseDataMap, key: propertyCountryDataType) ??
            [];
        listDataHolder = parseMetaDataList(dataHolder);
        if (listDataHolder.isNotEmpty) {
          HiveStorageManager.storePropertyCountriesMetaData(listDataHolder);
        }
        // Property State Meta Data
        dataHolder = UtilityMethods.getListItemValueFromMap(
                inputMap: touchBaseDataMap, key: propertyStateDataType) ??
            [];
        listDataHolder = parseMetaDataList(dataHolder);
        if (listDataHolder.isNotEmpty) {
          HiveStorageManager.storePropertyStatesMetaData(listDataHolder);
        }
        // Property Area Meta Data
        dataHolder = UtilityMethods.getListItemValueFromMap(
                inputMap: touchBaseDataMap, key: propertyAreaDataType) ??
            [];
        listDataHolder = parseMetaDataList(dataHolder);
        if (listDataHolder.isNotEmpty) {
          HiveStorageManager.storePropertyAreaMetaData(listDataHolder);
        }
        // Property Label Meta Data
        dataHolder = UtilityMethods.getListItemValueFromMap(
                inputMap: touchBaseDataMap, key: propertyLabelDataType) ??
            [];
        listDataHolder = parseMetaDataList(dataHolder);
        if (listDataHolder.isNotEmpty) {
          HiveStorageManager.storePropertyLabelsMetaData(listDataHolder);
        }
        // Property Status Meta Data
        dataHolder = UtilityMethods.getListItemValueFromMap(
                inputMap: touchBaseDataMap, key: propertyStatusDataType) ??
            [];
        listDataHolder = parseMetaDataList(dataHolder);
        if (listDataHolder.isNotEmpty) {
          HiveStorageManager.storePropertyStatusMetaData(listDataHolder);
          dataHolder = UtilityMethods.getParentAndChildCategorizedMap(
              metaDataList: listDataHolder);
          if (dataHolder.isNotEmpty) {
            HiveStorageManager.storePropertyStatusMapData(dataHolder);
          }
        }
        // Property Features Meta Data
        dataHolder = UtilityMethods.getListItemValueFromMap(
                inputMap: touchBaseDataMap, key: propertyFeatureDataType) ??
            [];
        listDataHolder = parseMetaDataList(dataHolder);
        if (listDataHolder.isNotEmpty) {
          HiveStorageManager.storePropertyFeaturesMetaData(listDataHolder);
        }
        // Schedule Time Slots Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
            inputMap: touchBaseDataMap, key: scheduleTimeSlotsKey);
        if (dataHolder != null) {
          HiveStorageManager.storeScheduleTimeSlotsInfoData(dataHolder);
        }
        // Default Currency Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
            inputMap: touchBaseDataMap, key: defaultCurrencyKey);
        if (dataHolder != null) {
          HiveStorageManager.storeDefaultCurrencyInfoData(dataHolder);
        }
        // Enquiry Type Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
            inputMap: touchBaseDataMap, key: enquiryTypeKey);
        if (dataHolder != null) {
          HiveStorageManager.storeInquiryTypeInfoData(dataHolder);
        }
        // User Roles Meta Data
        dataHolder = UtilityMethods.getListItemValueFromMap(
            inputMap: touchBaseDataMap, key: userRolesKey);
        if (dataHolder != null) {
          HiveStorageManager.storeUserRoleListData(dataHolder);
        }
        // All User Roles Meta Data
        dataHolder = UtilityMethods.getListItemValueFromMap(
            inputMap: touchBaseDataMap, key: allUserRolesKey);
        if (dataHolder != null) {
          HiveStorageManager.storeAdminUserRoleListData(dataHolder);
        }
        // Property Reviews Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
                inputMap: touchBaseDataMap, key: propertyReviewsKey) ??
            "";
        if (dataHolder.isNotEmpty && dataHolder == "1") {
          SHOW_REVIEWS = true;
        } else {
          SHOW_REVIEWS = false;
        }
        // Currency Position Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
                inputMap: touchBaseDataMap, key: currencyPositionKey) ??
            "";
        if (dataHolder.isNotEmpty) {
          CURRENCY_POSITION = dataHolder;
        }
        // Thousands Separator Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
                inputMap: touchBaseDataMap, key: thousandsSeparatorKey) ??
            "";
        if (dataHolder.isNotEmpty) {
          THOUSAND_SEPARATOR = dataHolder;
        }
        // Decimal Point Separator Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
                inputMap: touchBaseDataMap, key: decimalPointSeparatorKey) ??
            "";
        if (dataHolder.isNotEmpty) {
          DECIMAL_POINT_SEPARATOR = dataHolder;
        }
        // Add Property GDPR Enabled Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
                inputMap: touchBaseDataMap, key: addPropGDPREnabledKey) ??
            "";
        if (dataHolder.isNotEmpty) {
          ADD_PROP_GDPR_ENABLED = dataHolder;
        }
        // Measurement Unit Global Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
                inputMap: touchBaseDataMap, key: measurementUnitGlobalKey) ??
            "";
        if (dataHolder.isNotEmpty) {
          MEASUREMENT_UNIT_GLOBAL = dataHolder;
        }
        // Measurement Unit Text Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
                inputMap: touchBaseDataMap, key: measurementUnitTextKey) ??
            "";
        if (dataHolder.isNotEmpty) {
          MEASUREMENT_UNIT_TEXT = dataHolder;
        }
        // Radius Unit Text Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
                inputMap: touchBaseDataMap, key: radiusUnitKey) ??
            "";
        if (dataHolder.isNotEmpty) {
          RADIUS_UNIT = dataHolder;
        }
        // Payment status Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
                inputMap: touchBaseDataMap, key: paymentEnabledStatusKey) ??
            "";
        if (dataHolder != null && dataHolder.isNotEmpty) {
          TOUCH_BASE_PAYMENT_ENABLED_STATUS = dataHolder;
        }
        // Make Featured google play store product id
        dataHolder = UtilityMethods.getStringItemValueFromMap(
                inputMap: touchBaseDataMap,
                key: googlePlayStoreFeaturedProductIdKey) ??
            "";
        if (dataHolder != null && dataHolder.isNotEmpty) {
          MAKE_FEATURED_ANDROID_PRODUCT_ID = dataHolder;
        }
        // Make Featured apple appstore product id
        dataHolder = UtilityMethods.getStringItemValueFromMap(
                inputMap: touchBaseDataMap,
                key: appleAppStoreFeaturedProductIdKey) ??
            "";
        if (dataHolder != null && dataHolder.isNotEmpty) {
          MAKE_FEATURED_IOS_PRODUCT_ID = dataHolder;
        }
        // Per listing google play store product id
        dataHolder = UtilityMethods.getStringItemValueFromMap(
                inputMap: touchBaseDataMap,
                key: googlePlayStorePerListingProductIdKey) ??
            "";
        if (dataHolder != null && dataHolder.isNotEmpty) {
          PER_LISTING_ANDROID_PRODUCT_ID = dataHolder;
        }
        // Per listing apple appstore product id
        dataHolder = UtilityMethods.getStringItemValueFromMap(
                inputMap: touchBaseDataMap,
                key: appleAppStorePerListingProductIdKey) ??
            "";
        if (dataHolder != null && dataHolder.isNotEmpty) {
          PER_LISTING_IOS_PRODUCT_ID = dataHolder;
        }
        // Enquiry type Text Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
            inputMap: touchBaseDataMap, key: enquiryTypeKey);
        if (dataHolder != null) {
          HiveStorageManager.storeInquiryTypeInfoData(dataHolder);
        }
        // Lead prefix Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
            inputMap: touchBaseDataMap, key: leadPrefixKey);
        if (dataHolder != null) {
          HiveStorageManager.storeLeadPrefixInfoData(dataHolder);
        }
        // Lead Source Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
            inputMap: touchBaseDataMap, key: leadSourceKey);
        if (dataHolder != null) {
          HiveStorageManager.storeLeadSourceInfoData(dataHolder);
        }
        // Deal Status Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
            inputMap: touchBaseDataMap, key: dealStatusKey);
        if (dataHolder != null) {
          HiveStorageManager.storeDealStatusInfoData(dataHolder);
        }
        // Deal Next Action Meta Data
        dataHolder = UtilityMethods.getStringItemValueFromMap(
            inputMap: touchBaseDataMap, key: dealNextActionKey);
        if (dataHolder != null) {
          HiveStorageManager.storeDealNextActionInfoData(dataHolder);
        }

        if (touchBaseDataMap.containsKey("custom_fields")) {
          var data = touchBaseDataMap["custom_fields"];
          if (data != null && data.isNotEmpty) {
            final custom = customFromJson(response.toString());
            HiveStorageManager.storeCustomFieldsDataMaps(customToJson(custom));
          }
        }
      }
    } else {
      if (response.statusCode == null) {
        touchBaseDataMap["response"] = response;
      }
    }

    // dis-allocating the variables
    dataHolder = null;
    listDataHolder = [];

    return touchBaseDataMap;
  }

  List<dynamic> parseMetaDataList(List? inputList) {
    List parsedList = [];

    if (inputList != null && inputList.isNotEmpty) {
      parsedList = inputList
          .map(
              (m) => propertyApiProvider.getCurrentParser().parseMetaDataMap(m))
          .toList();
    }

    return parsedList;
  }

  Future<List> fetchSingleAgencyInfoList(int id) async {
    List<dynamic> singleAgencyInfo = [];
    final response = await propertyApiProvider.fetchSingleAgencyInfoApi(id);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      singleAgencyInfo.add(propertyApiProvider
          .getCurrentParser()
          .parseAgencyInfo(response.data));
    } else {
      if (response.statusCode == null) {
        singleAgencyInfo = [response];
      }
    }

    return singleAgencyInfo;
  }

  Future<List> fetchSingleAgentInfoList(int id) async {
    List<dynamic> singleAgentInfo = [];
    final response = await propertyApiProvider.fetchSingleAgentInfoApi(id);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      singleAgentInfo.add(
          propertyApiProvider.getCurrentParser().parseAgentInfo(response.data));
    } else {
      if (response.statusCode == null) {
        singleAgentInfo = [response];
      }
    }

    return singleAgentInfo;
  }

  Future<List> fetchAgencyAgentInfoList(int id) async {
    List<dynamic> agencyAgentInfo = [];
    final response = await propertyApiProvider.fetchAgencyAgentInfoApi(id);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      agencyAgentInfo.add(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseAgentInfo(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        agencyAgentInfo = [response];
      }
    }

    return agencyAgentInfo;
  }

  Future<List> fetchAgencyAllAgentList(int id) async {
    List<dynamic> agencyAgentInfo = [];
    final response = await propertyApiProvider.fetchAgencyAllAgentListApi(id);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      agencyAgentInfo.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseAgentInfo(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        agencyAgentInfo = [response];
      }
    }

    return agencyAgentInfo;
  }

  Future<List> fetchPropertiesByAgencyList(
      int id, int page, int perPage) async {
    List<dynamic> propertiesByAgencyList = [];
    final response =
        await propertyApiProvider.fetchPropertiesByAgencyApi(id, page, perPage);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      propertiesByAgencyList.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        propertiesByAgencyList = [response];
      }
    }

    return propertiesByAgencyList;
  }

  Future<List> fetchPropertiesByAgentList(int id, int page, int perPage) async {
    List<dynamic> propertiesByAgentList = [];
    final response =
        await propertyApiProvider.fetchPropertiesByAgentApi(id, page, perPage);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      propertiesByAgentList.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        propertiesByAgentList = [response];
      }
    }

    return propertiesByAgentList;
  }

  Future<List> fetchAllAgentsInfoList(int page, int perPage) async {
    List<dynamic> allAgentsInfo = [];
    final response = await propertyApiProvider.fetchAllAgentsApi(page, perPage);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      allAgentsInfo.add(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseAgentInfo(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        allAgentsInfo = [response];
      }
    }

    return allAgentsInfo;
  }

  Future<List> fetchAllAgenciesInfoList(int page, int perPage) async {
    List<dynamic> allAgenciesInfo = [];
    final response =
        await propertyApiProvider.fetchAllAgenciesApi(page, perPage);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      allAgenciesInfo.add(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseAgencyInfo(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        allAgenciesInfo = [response];
      }
    }

    return allAgenciesInfo;
  }

  Future<List> fetchPropertiesInCityList(int id, int page, int perPage) async {
    List<dynamic> propertiesInCityArticles = [];
    final response =
        await propertyApiProvider.fetchPropertiesInCityApi(id, page, perPage);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      propertiesInCityArticles.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        propertiesInCityArticles = [response];
      }
    }

    return propertiesInCityArticles;
  }

  Future<List> fetchPropertiesByTypeList(int id, int page, int perPage) async {
    List<dynamic> propertiesByTypeArticles = [];
    final response =
        await propertyApiProvider.fetchPropertiesByTypeApi(id, page, perPage);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      propertiesByTypeArticles.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        propertiesByTypeArticles = [response];
      }
    }

    return propertiesByTypeArticles;
  }

  Future<List> fetchPropertiesInCityByTypeList(
      int cityId, int typeId, int page, int perPage) async {
    List<dynamic> propertiesInCityByTypeArticles = [];
    final response = await propertyApiProvider.fetchPropertiesInCityByTypeApi(
        cityId, typeId, page, perPage);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      propertiesInCityByTypeArticles.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        propertiesInCityByTypeArticles = [response];
      }
    }

    return propertiesInCityByTypeArticles;
  }

  Future<Response> fetchContactRealtorResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response =
        await propertyApiProvider.fetchContactRealtorResponse(dataMap, nonce);
    return response;
  }

  Future<Response> fetchContactDeveloperResponse(
      Map<String, dynamic> dataMap) async {
    final response =
        await propertyApiProvider.fetchContactDeveloperResponse(dataMap);
    return response;
  }

  Future<Response> fetchLoginResponse(Map<String, dynamic> dataMap) async {
    final response = await propertyApiProvider.fetchLoginResponse(dataMap);
    return response;
  }

  Future<Response> fetchScheduleATourResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response =
        await propertyApiProvider.fetchScheduleATourResponse(dataMap, nonce);
    return response;
  }

  Future<Response> fetchAddPropertyResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response =
        await propertyApiProvider.fetchAddPropertyResponse(dataMap, nonce);
    return response;
  }

  Future<Response> fetchSigupResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response =
        await propertyApiProvider.fetchSignUpResponse(dataMap, nonce);
    return response;
  }

  Future<List<dynamic>> fetchAllProperties(
      String status, int page, int perPage, int userId) async {
    List<dynamic> _propertiesList = [];
    final response = await propertyApiProvider.fetchAllProperties(
        status, page, perPage, userId);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      _propertiesList.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        _propertiesList = [response];
      }
    }

    return _propertiesList;
  }

  Future<Response> statusOfProperty(
      Map<String, dynamic> dataMap, int id) async {
    final response = await propertyApiProvider.statusOfProperty(dataMap, id);
    return response;
  }

  Future<Response> deleteProperty(int id) async {
    final response = await propertyApiProvider.deleteProperty(id);
    return response;
  }

  Uri provideSavePropertyImagesApi() {
    var uri = propertyApiProvider.provideSavePropertyImagesApi();
    return uri;
  }

  Future<List<dynamic>> fetchMyProperties(
      String status, int page, int perPage, int userId) async {
    List<dynamic> _propertiesList = [];
    final response = await propertyApiProvider.fetchMyProperties(
        status, page, perPage, userId);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304) &&
        response.data["success"]) {
      _propertiesList.addAll(response.data["result"]
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        _propertiesList = [response];
      }
    }

    return _propertiesList;
  }

  Future<Response> fetchForgetPasswordResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response =
        await propertyApiProvider.fetchForgetPasswordResponse(dataMap, nonce);
    return response;
  }

  Future<List> fetchTermData(dynamic termData) async {
    Map<String, dynamic> metaDataMap = {};
    List<dynamic> metaDataList = [];
    final response = await propertyApiProvider.fetchTermDataApi(termData);
    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      metaDataMap = response.data;
      if (metaDataMap != null) {
        if (termData is List) {
          for (var dataTypeItem in termData) {
            List<dynamic> tempList =
                validateAndStoreTermData(metaDataMap, dataTypeItem);
            if (tempList != null && tempList.isNotEmpty) {
              metaDataList.addAll(tempList);
            }
          }
        } else if (termData is String) {
          List<dynamic> tempList =
              validateAndStoreTermData(metaDataMap, termData);
          if (tempList != null && tempList.isNotEmpty) {
            metaDataList.addAll(tempList);
          }
        }
      }
    } else {
      if (response.statusCode == null) {
        metaDataList = [response];
      }
    }

    return metaDataList;
  }

  List<dynamic> validateAndStoreTermData(
      Map<String, dynamic> metaDataMap, String dataTypeItem) {
    List<dynamic> metaDataList = [];
    if (metaDataMap.containsKey(dataTypeItem)) {
      var tempMetaData = metaDataMap[dataTypeItem];
      if (tempMetaData != null &&
          tempMetaData is Map &&
          tempMetaData.isNotEmpty) {
        if (tempMetaData.containsKey("errors")) {
          if (dataTypeItem == propertyAreaDataType) {
            SHOW_NEIGHBOURHOOD_FIELD = false;
          } else if (dataTypeItem == propertyStateDataType) {
            SHOW_STATE_COUNTY_FIELD = false;
          } else if (dataTypeItem == propertyCountryDataType) {
            SHOW_COUNTRY_NAME_FIELD = false;
          } else if (dataTypeItem == propertyCityDataType) {
            SHOW_LOCALITY_FIELD = false;
          }
        }
      } else if (tempMetaData != null &&
          tempMetaData is List &&
          tempMetaData.isNotEmpty) {
        List<dynamic> tempMetaDataList = [];
        tempMetaDataList = tempMetaData
            .map((m) =>
                propertyApiProvider.getCurrentParser().parseMetaDataMap(m))
            .toList();
        if (tempMetaDataList != null && tempMetaDataList.isNotEmpty) {
          metaDataList.addAll(tempMetaDataList);
          if (dataTypeItem == propertyAreaDataType) {
            HiveStorageManager.storePropertyAreaMetaData(tempMetaDataList);
          } else if (dataTypeItem == propertyStateDataType) {
            HiveStorageManager.storePropertyStatesMetaData(tempMetaDataList);
          } else if (dataTypeItem == propertyCountryDataType) {
            HiveStorageManager.storePropertyCountriesMetaData(tempMetaDataList);
          } else if (dataTypeItem == propertyCityDataType) {
            HiveStorageManager.storeCitiesMetaData(tempMetaDataList);
          } else if (dataTypeItem == propertyFeatureDataType) {
            HiveStorageManager.storePropertyFeaturesMetaData(tempMetaDataList);
          } else if (dataTypeItem == propertyTypeDataType) {
            HiveStorageManager.storePropertyTypesMetaData(tempMetaDataList);
            Map<String, dynamic> tempDataMap = {};
            tempDataMap = UtilityMethods.getParentAndChildCategorizedMap(
                metaDataList: tempMetaDataList);
            HiveStorageManager.storePropertyTypesMapData(tempDataMap);
          } else if (dataTypeItem == propertyLabelDataType) {
            HiveStorageManager.storePropertyLabelsMetaData(tempMetaDataList);
          } else if (dataTypeItem == propertyStatusDataType) {
            HiveStorageManager.storePropertyStatusMetaData(tempMetaDataList);
            Map<String, dynamic> tempDataMap = {};
            tempDataMap = UtilityMethods.getParentAndChildCategorizedMap(
                metaDataList: tempMetaDataList);
            HiveStorageManager.storePropertyStatusMapData(tempDataMap);
          }
        }
      }
    }

    return metaDataList;
  }

  Future<Response> fetchAddOrRemoveFromFavResponse(
      Map<String, dynamic> dataMap) async {
    final response =
        await propertyApiProvider.fetchAddOrRemoveFromFavResponse(dataMap);
    return response;
  }

  Future<Uri> fetchPrintPdfPropertyResponse(Map<String, dynamic> dataMap) {
    final response = propertyApiProvider.fetchPrintPdfPropertyResponse(dataMap);
    return response;
  }

  Future<List<dynamic>> fetchFavProperties(
      int page, int perPage, String userIdStr) async {
    List<dynamic> _propertiesList = [];
    final response =
        await propertyApiProvider.fetchFavProperties(page, perPage, userIdStr);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304) &&
        response.data["success"]) {
      _propertiesList.addAll(response.data['result'].map((m) {
        if (m is Map<dynamic, dynamic>) {
          m = UtilityMethods.convertMap(m);
        }
        return propertyApiProvider.getCurrentParser().parseArticle(m);
      }).toList());
    } else {
      if (response.statusCode == null) {
        _propertiesList = [response];
      }
    }

    return _propertiesList;
  }

  Future<Response> fetchUpdatePropertyResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response =
        await propertyApiProvider.fetchUpdatePropertyResponse(dataMap, nonce);
    return response;
  }

  Future<List> fetchLatLongArticles(
      String lat, String long, String radius) async {
    List<dynamic> latestArticles = [];
    final response = await propertyApiProvider.fetchLatLongArticlesResponse(
        lat, long, radius);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      latestArticles.addAll(response.data["result"]
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        latestArticles = [response];
      }
    }

    return latestArticles;
  }

  Future<Response> fetchDeleteImageFromEditProperty(
      Map<String, dynamic> dataMap, String nonce) async {
    final response = await propertyApiProvider.fetchDeleteImageFromEditProperty(
        dataMap, nonce);
    return response;
  }

  Future<Response> fetchAddSavedSearch(
      Map<String, dynamic> dataMap, String nonce) async {
    final response =
        await propertyApiProvider.fetchAddSavedSearch(dataMap, nonce);
    return response;
  }

  Future<List<dynamic>> fetchSavedSearches(int page, int perPage,
      {String? leadId, bool fetchLeadSavedSearches = false}) async {
    List<dynamic> savedSearchList = [];
    final response = await propertyApiProvider.fetchSavedSearches(page, perPage,
        leadId: leadId, fetchLeadSavedSearches: fetchLeadSavedSearches);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      var results = response.data["results"];
      dynamic mapped = results.map((m) {
        return propertyApiProvider.getCurrentParser().parseSavedSearch(m);
      });
      savedSearchList.addAll(mapped.toList());
    } else {
      if (response.statusCode == null) {
        savedSearchList = [response];
      }
    }

    return savedSearchList;
  }

  Future<Response> fetchDeleteSavedSearch(Map<String, dynamic> dataMap) async {
    final response = await propertyApiProvider.fetchDeleteSavedSearch(dataMap);
    return response;
  }

  Future<List> fetchSavedSearchArticles(Map<String, dynamic> dataMap) async {
    List<dynamic> filteredArticles = [];
    final response =
        await propertyApiProvider.fetchSavedSearchArticlesResponse(dataMap);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      filteredArticles.addAll(response.data["result"]
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        filteredArticles = [response];
      }
    }

    return filteredArticles;
  }

  Future<Response> fetchAddReviewResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response =
        await propertyApiProvider.fetchAddReviewResponse(dataMap, nonce);
    return response;
  }

  Future<Response> fetchReportContentResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response =
        await propertyApiProvider.fetchReportContentResponse(dataMap, nonce);
    return response;
  }

  Future<List> fetchArticlesReviews(int id, String page, String perPage) async {
    List<dynamic> articlesReviews = [];
    final response = await propertyApiProvider.fetchArticlesReviewsResponse(
        id, page, perPage);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      articlesReviews.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        articlesReviews = [response];
      }
    }

    return articlesReviews;
  }

  Future<List<dynamic>> fetchAgentAgencyAuthorReviews(
      int id, String page, String perPage, String type) async {
    List<dynamic> articlesReviews = [];
    final response = await propertyApiProvider
        .fetchAgentAgencyAuthorReviewsResponse(id, page, perPage, type);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      articlesReviews.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        articlesReviews = [response];
      }
    }

    return articlesReviews;
  }

  Future<List> fetchUserInfo() async {
    List<dynamic> userInfo = [];
    final response = await propertyApiProvider.fetchUserInfoResponse();

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      var data;
      if (response.data is String) {
        Map<String, dynamic> map = json.decode(response.data);
        data = propertyApiProvider.getCurrentParser().parseUserInfo(map);
      } else {
        data =
            propertyApiProvider.getCurrentParser().parseUserInfo(response.data);
      }
      userInfo.add(data);
    } else {
      if (response.statusCode == null) {
        userInfo = [response];
      }
    }

    return userInfo;
  }

  Future<Response> fetchUpdateUserProfileResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response = await propertyApiProvider.fetchUpdateUserProfileResponse(
        dataMap, nonce);
    return response;
  }

  Future<Response> fetchUpdateUserProfileImageResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response = await propertyApiProvider
        .fetchUpdateUserProfileImageResponse(dataMap, nonce);
    return response;
  }

  Future<List> fetchSearchAgentsList(int page, int perPage, String search,
      String agentCity, String agentCategory) async {
    List<dynamic> allAgentsInfo = [];
    final response = await propertyApiProvider.fetchSearchAgentsApi(
        page, perPage, search, agentCity, agentCategory);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      allAgentsInfo.add(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseAgentInfo(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        allAgentsInfo = [response];
      }
    }

    return allAgentsInfo;
  }

  Future<List> fetchSearchAgenciesList(
      int page, int perPage, String search) async {
    List<dynamic> allAgenciesInfo = [];
    final response =
        await propertyApiProvider.fetchSearchAgenciesApi(page, perPage, search);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      allAgenciesInfo.add(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseAgencyInfo(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        allAgenciesInfo = [response];
      }
    }

    return allAgenciesInfo;
  }

  Future<Response> fetchFixProfileImageResponse() async {
    final response = await propertyApiProvider.fetchFixProfileImageResponse();
    return response;
  }

  Future<Response> fetchIsFavProperty(String listingId) async {
    final response = await propertyApiProvider.fetchIsFavPropertyApi(listingId);
    return response;
  }

  Future<Response> fetchSocialSignOnResponse(
      Map<String, dynamic> dataMap) async {
    final response =
        await propertyApiProvider.fetchSocialSignOnResponse(dataMap);
    return response;
  }

  Future<List> fetchPropertiesByType(int page, int id, String type) async {
    List<dynamic> propertiesByType = [];
    final response =
        await propertyApiProvider.fetchPropertiesByTypeResponse(page, id, type);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      propertiesByType.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        propertiesByType = [response];
      }
    }

    return propertiesByType;
  }

  Future<List> fetchRealtorInfoList(int page, String type) async {
    List<dynamic> realtorInfo = [];
    final response = await propertyApiProvider.fetchRealtorInfoApi(page, type);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      if (type == REST_API_AGENT_ROUTE) {
        realtorInfo.add(response.data
            .map(
                (m) => propertyApiProvider.getCurrentParser().parseAgentInfo(m))
            .toList());
      } else {
        realtorInfo.add(response.data
            .map((m) =>
                propertyApiProvider.getCurrentParser().parseAgencyInfo(m))
            .toList());
      }
    } else {
      if (response.statusCode == null) {
        realtorInfo = [response];
      }
    }

    return realtorInfo;
  }

  Future<Response> fetchDeleteUserAccountResponse() async {
    final response = await propertyApiProvider.fetchDeleteUserAccountResponse();
    return response;
  }

  Future<Response> fetchUpdateUserPasswordResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response = await propertyApiProvider.fetchUpdateUserPasswordResponse(
        dataMap, nonce);
    return response;
  }

  Future<List> fetchSingleArticleViaPermaLink(String permaLink) async {
    List<dynamic> singleArticle = [];
    final response = await propertyApiProvider
        .fetchSingleArticleViaPermaLinkResponse(permaLink);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      singleArticle.add(
          propertyApiProvider.getCurrentParser().parseArticle(response.data));
    } else {
      if (response.statusCode == null) {
        singleArticle = [response];
      }
    }

    return singleArticle;
  }

  Future<Response> fetchAddRequestPropertyResponse(
      Map<String, dynamic> dataMap) async {
    final response =
        await propertyApiProvider.fetchAddRequestPropertyResponse(dataMap);
    return response;
  }

  Future<List> fetchPropertiesAds() async {
    List<dynamic> propertiesByType = [];
    final response = await propertyApiProvider.fetchPropertiesAdsResponse();

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      propertiesByType.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        propertiesByType = [response];
      }
    }
    return propertiesByType;
  }

  Future<Response> fetchAddAgentResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response =
        await propertyApiProvider.fetchAddAgentResponse(dataMap, nonce);
    return response;
  }

  Future<Response> fetchEditAgentResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response =
        await propertyApiProvider.fetchEditAgentResponse(dataMap, nonce);
    return response;
  }

  Future<Response> fetchDeleteAgentResponse(
      Map<String, dynamic> dataMap, String nonce) async {
    final response =
        await propertyApiProvider.fetchDeleteAgentResponse(dataMap, nonce);
    return response;
  }

  Future<List<dynamic>> fetchUsers(int page, int perPage, String search) async {
    List<dynamic> usersList = [];
    final response =
        await propertyApiProvider.fetchUsersResponse(page, perPage, search);

    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      usersList.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        usersList = [response];
      }
    }

    return usersList;
  }

  Future<Map> fetchUserPaymentStatus() async {
    Map userPaymentStatusMap = {};
    Response response =
        await propertyApiProvider.fetchUserPaymentStatusResponse();
    if (response != null &&
        response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      userPaymentStatusMap = response.data;
    } else {
      if (response.statusCode == null) {
        userPaymentStatusMap = {};
      }
    }

    return userPaymentStatusMap;
  }

  Future<ApiResponse> fetchContactRealtorNonceResponse() async {
    final response =
        await propertyApiProvider.fetchContactRealtorNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchAddAgentNonceResponse() async {
    final response = await propertyApiProvider.fetchAddAgentNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchEditAgentNonceResponse() async {
    final response = await propertyApiProvider.fetchEditAgentNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchDeleteAgentNonceResponse() async {
    final response = await propertyApiProvider.fetchDeleteAgentNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchScheduleATourNonceResponse() async {
    final response =
        await propertyApiProvider.fetchScheduleATourNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchContactPropertyAgentNonceResponse() async {
    final response =
        await propertyApiProvider.fetchContactPropertyAgentNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchAddPropertyNonceResponse() async {
    final response = await propertyApiProvider.fetchAddPropertyNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchUpdatePropertyNonceResponse() async {
    final response =
        await propertyApiProvider.fetchUpdatePropertyNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchAddImageNonceResponse() async {
    final response = await propertyApiProvider.fetchAddImageNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchDeleteImageNonceResponse() async {
    final response = await propertyApiProvider.fetchDeleteImageNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchAddReviewNonceResponse() async {
    final response = await propertyApiProvider.fetchAddReviewNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchSaveSearchNonceResponse() async {
    final response = await propertyApiProvider.fetchSaveSearchNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchSignUpNonceResponse() async {
    final response = await propertyApiProvider.fetchSignUpNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchResetPasswordNonceResponse() async {
    final response =
        await propertyApiProvider.fetchResetPasswordNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchUpdatePasswordNonceResponse() async {
    final response =
        await propertyApiProvider.fetchUpdatePasswordNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchUpdateProfileNonceResponse() async {
    final response =
        await propertyApiProvider.fetchUpdateProfileNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchUpdateProfileImageNonceResponse() async {
    final response =
        await propertyApiProvider.fetchUpdateProfileImageNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchSignInNonceResponse() async {
    final response = await propertyApiProvider.fetchSignInNonceResponse();
    return response;
  }

  Future<ApiResponse> fetchReportContentNonceResponse() async {
    final response =
        await propertyApiProvider.fetchReportContentNonceResponse();
    return response;
  }

  Future<List> fetchPartnersList() async {
    List<dynamic> partnersList = [];

    var response = await propertyApiProvider.fetchPartnersListResponse();
    if (response.data != null &&
        (response.statusCode == 200 || response.statusCode == 304)) {
      partnersList.addAll(response.data
          .map((json) =>
              propertyApiProvider.getCurrentParser().parsePartnerJson(json))
          .toList());
    } else {
      if (response.statusCode == null) {
        partnersList = [response];
      }
    }

    return partnersList;
  }

  Uri provideDirectionsApi(String platform, String lat, String lng) {
    var uri = propertyApiProvider.provideDirectionsApi(platform, lat, lng);
    return uri;
  }

  Future<List> fetchMembershipPackages() async {
    List<dynamic> membershipPlanPackageList = [];
    final response =
        await propertyApiProvider.fetchMembershipPackagesResponse();

    if (response != null &&
        response.data != null &&
        response.statusCode == 200) {
      membershipPlanPackageList.addAll(response.data
          .map((m) => propertyApiProvider.getCurrentParser().parseArticle(m))
          .toList());
    } else {
      if (response.statusCode == null) {
        membershipPlanPackageList = [response];
      }
    }

    return membershipPlanPackageList;
  }

  Future<ApiResponse> fetchProceedWithPaymentsResponse(
      Map<String, dynamic> dataMap) async {
    final response =
        await propertyApiProvider.fetchProceedWithPaymentsResponse(dataMap);
    return response;
  }

  Future<ApiResponse> fetchMakePropertyFeaturedResponse(
      Map<String, dynamic> dataMap) async {
    final response =
        await propertyApiProvider.fetchMakePropertyFeaturedResponse(dataMap);
    return response;
  }

  Future<ApiResponse> fetchRemoveFromFeaturedResponse(
      Map<String, dynamic> dataMap) async {
    final response =
        await propertyApiProvider.fetchRemoveFromFeaturedResponse(dataMap);
    return response;
  }

  Future<UserMembershipPackage> fetchUserMembershipPackageResponse() async {
    final response =
        await propertyApiProvider.fetchUserMembershipPackageResponse();
    UserMembershipPackage userMembershipPackage = propertyApiProvider
        .getCurrentParser()
        .parseUserMembershipPackageResponse(response.data);
    return userMembershipPackage;
  }
}
