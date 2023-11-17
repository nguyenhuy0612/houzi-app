import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/interfaces/api_parser_interface.dart';
import 'package:houzi_package/models/api_response.dart';
import 'package:houzi_package/models/partner.dart';
import 'package:houzi_package/models/realtor_model.dart';
import 'package:houzi_package/models/article.dart';
import 'package:houzi_package/models/floor_plans.dart';
import 'package:houzi_package/models/property_meta_data.dart';
import 'package:houzi_package/models/saved_search.dart';
import 'package:houzi_package/models/user.dart';
import 'package:houzi_package/models/user_membership_package.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

import 'package:houzi_package/models/custom_fields.dart';

class HouzezParser implements ApiParserInterface {

  @override
  Article parseArticle(Map<String, dynamic> json) {
    return HouzezParser.parseArticleMap(json);
  }

  @override
  Term parseMetaDataMap(Map<String, dynamic> json) {
    return HouzezParser.parsePropertyMetaDataMap(json);
  }

  @override
  Agency parseAgencyInfo(Map<String, dynamic> json) {
    return HouzezParser.parseAgencyInformation(json);
  }

  @override
  Agent parseAgentInfo(Map<String, dynamic> json) {
    return HouzezParser.parseAgentInformation(json);
  }

  @override
  SavedSearch parseSavedSearch(Map<String, dynamic> json) {
    return HouzezParser.parseSavedSearchMap(json);
  }

  @override
  User parseUserInfo(Map<String, dynamic> json) {
    return HouzezParser.parseUserInfoMap(json);
  }

  // @override
  // UserMembershipPackage parseUserMembershipPackageResponse(Map<String, dynamic> json) {
  //   return HouzezParser.parseparseUserMembershipPackageResponseMap(json);
  // }

  static Address parseAddressMap(Map<String, dynamic> json) {
    String tempAddress = "";
    String tempLat = "";
    String tempLng = "";
    String tempCoordinates = "";
    String tempPostalCode = "";
    String tempCity = "";
    String tempCountry = "";
    String tempState = "";
    String tempArea = "";

    dynamic dataHolder;
    Map<String, dynamic> mapDataHolder = {};

    tempAddress = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "address") ?? "";
    tempLat = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "lat") ?? "";
    tempLng = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "lng") ?? "";

    Map tempMap = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "property_meta") ?? {};

    if(tempMap.isNotEmpty){
      mapDataHolder = UtilityMethods.convertMap(tempMap);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_map_address");
      tempAddress = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
      if(tempAddress.isEmpty) {
        dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_address");
        tempAddress = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
      }

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "houzez_geolocation_lat");
      tempLat = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "houzez_geolocation_long");
      tempLng = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_location");
      tempCoordinates = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_zip");
      tempPostalCode = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
    }

    tempMap = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "property_address") ?? {};
    if(tempMap.isNotEmpty){
      mapDataHolder = UtilityMethods.convertMap(tempMap);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "property_city");
      tempCity = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "property_country");
      tempCountry = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "property_state");
      tempState = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "property_area");
      tempArea = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
    }

    // Dis-allocating the variables
    dataHolder = null;
    mapDataHolder = {};
    tempMap = {};

    return Address(
      city: tempCity,
      country: tempCountry,
      state: tempState,
      area: tempArea,
      address: tempAddress,
      coordinates: tempCoordinates,
      lat: tempLat,
      long: tempLng,
      postalCode: tempPostalCode,
    );
  }

  static Features parseFeaturesMap(Map<String, dynamic> json) {
    String tempLandArea = "";
    String tempLandAreaUnit = "";
    String tempBedrooms = "";
    String tempBathrooms = "";
    String tempGarage = "";
    String tempGarageSize = "";
    String tempYearBuilt = "";
    String tempMultiUnitsListingIDs = "";

    List<String> featuresList = [];
    List<String> imageIdsList = [];
    List<dynamic> tempFeaturesList = [];
    List<dynamic> tempImagesIdList = [];
    List<dynamic> tempMultiUnitsList = [];
    List<dynamic> tempFloorPlansList = [];
    List<dynamic> tempAdditionalDetailsList = [];
    List<Map<String, dynamic>> tempMultiUnitsPlan = [];
    List<Map<String, dynamic>> tempFloorPlan = [];
    List<Map<String, dynamic>> attachments = [];
    List<Attachment> tempAttachments = [];
    List<dynamic>? propertyStatusList = [];
    List<dynamic>? propertyTypeList = [];
    List<dynamic>? propertyLabelList = [];

    dynamic dataHolder;
    Map<String, dynamic> mapDataHolder = {};

    tempFeaturesList = UtilityMethods.getListItemValueFromMap(inputMap: json, key: "property_features") ?? [];
    if(tempFeaturesList.isNotEmpty){
      featuresList = List<String>.from(tempFeaturesList);
    }
    propertyStatusList = UtilityMethods.getListItemValueFromMap(inputMap: json, key: "property_status_text") ?? [];
    propertyTypeList = UtilityMethods.getListItemValueFromMap(inputMap: json, key: "property_type_text") ?? [];
    propertyLabelList = UtilityMethods.getListItemValueFromMap(inputMap: json, key: "property_label_text") ?? [];

    dataHolder = UtilityMethods.getListItemValueFromMap(inputMap: json, key: "attachments") ?? [];
    if (dataHolder.isNotEmpty) {
      for (var item in dataHolder) {
        if (item is Map &&
            UtilityMethods.isValidString(item[attachmentsUrl]) &&
            UtilityMethods.isValidString(item[attachmentsName]) &&
            UtilityMethods.isValidString(item[attachmentsSize])) {
          tempAttachments.add(
            Attachment(
              size: item[attachmentsSize],
              name: item[attachmentsName],
              url: item[attachmentsUrl],
            ),
          );
        }
      }
    }

    Map tempMap = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "property_meta") ?? {};
    if(tempMap.isNotEmpty) {
      mapDataHolder = UtilityMethods.convertMap(tempMap);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_size");
      tempLandArea = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_size_prefix");
      tempLandAreaUnit = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_bedrooms");
      tempBedrooms = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_bathrooms");
      tempBathrooms = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_garage");
      tempGarage = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_garage_size");
      tempGarageSize = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_year");
      tempYearBuilt = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_multi_units_ids");
      tempMultiUnitsListingIDs = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      tempImagesIdList = UtilityMethods.getListItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_images") ?? [];
      if(tempImagesIdList.isNotEmpty){
        tempImagesIdList.removeWhere((element) => element is !String || element == "null");
        if(tempImagesIdList.isNotEmpty){
          imageIdsList = List<String>.from(tempImagesIdList);
        }
      }

      dataHolder = UtilityMethods.getListItemValueFromMap(inputMap: mapDataHolder, key: "floor_plans") ?? [];
      if(dataHolder.isNotEmpty && dataHolder[0] is Map){
        tempFloorPlan = List<Map<String, dynamic>>.from(dataHolder);
        if(tempFloorPlan.isNotEmpty){
          tempFloorPlansList = getParsedDataInList(
            inputList: tempFloorPlan,
            function: parseFloorPlansMap,
          );
        }
      }

      dataHolder = UtilityMethods.getListItemValueFromMap(inputMap: mapDataHolder, key: "fave_multi_units") ?? [];
      if(dataHolder.isNotEmpty && dataHolder[0] is Map){
        tempMultiUnitsPlan = List<Map<String, dynamic>>.from(dataHolder);
        if(tempMultiUnitsPlan.isNotEmpty){
          tempMultiUnitsList = getParsedDataInList(
            inputList: tempMultiUnitsPlan,
            function: parseMultiUnitsMap,
          );
        }
      }

      dataHolder = UtilityMethods.getListItemValueFromMap(inputMap: mapDataHolder, key: "additional_features") ?? [];
      if(dataHolder.isNotEmpty){
        for(var item in dataHolder){
          if(item is Map &&
              UtilityMethods.isValidString(item[faveAdditionalFeatureTitle]) &&
              UtilityMethods.isValidString(item[faveAdditionalFeatureValue])){
            tempAdditionalDetailsList.add(
                AdditionalDetail(
                  title: item[faveAdditionalFeatureTitle],
                  value: item[faveAdditionalFeatureValue],
                )
            );
          }
        }
      }
    }


    // Dis-allocating the variables
    dataHolder = null;
    mapDataHolder = {};
    tempMap = {};
    tempFeaturesList = [];
    tempImagesIdList = [];
    tempFloorPlan = [];
    tempMultiUnitsPlan = [];

    return Features(
      featuresList: featuresList,
      landArea: tempLandArea,
      landAreaUnit: tempLandAreaUnit,
      bedrooms: tempBedrooms,
      bathrooms: tempBathrooms,
      garage: tempGarage,
      garageSize: tempGarageSize,
      yearBuilt: tempYearBuilt,
      floorPlansList: tempFloorPlansList,
      imagesIdList: imageIdsList,
      additionalDetailsList: tempAdditionalDetailsList,
      multiUnitsList: tempMultiUnitsList,
      multiUnitsListingIDs: tempMultiUnitsListingIDs,
      propertyLabelList: propertyLabelList,
      propertyStatusList: propertyStatusList,
      propertyTypeList: propertyTypeList,
      attachments: tempAttachments,
    );
  }

  static PropertyInfo parsePropertyInfoMap(Map<String, dynamic> json) {
    String tempPropertyType = "";
    String tempPropertyStatus = "";
    String tempPropertyLabel = "";
    String tempPrice = "";
    String tempPaymentStatus = "";
    String tempFirstPrice = "";
    String tempSecondPrice = "";
    String tempPriceCurrency = "";
    String tempCurrency = "";
    String tempUniqueId = "";
    String tempPricePostfix = "";
    String tempPropertyVirtualTourLink = "";
    String tempAgentDisplayOption = "";
    String tempAddressHideMap = "";
    String tempFeatured = "";
    String tempTotalRating = "";
    bool requiredLogin = false;
    bool tempIsFeatured = false;
    List<String> tempAgentList = [];
    List<String> tempAgencyList = [];
    Map<String, String> customFieldsMap = {};
    Map<String, dynamic> customFieldsMapForEditing = {};
    Map<String, dynamic> tempAgentInfoMap = {};

    dynamic dataHolder;
    Map<String, dynamic> mapDataHolder = {};
    Map tempMap = {};

    tempMap = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "property_attr") ?? {};
    if(tempMap.isNotEmpty){
      mapDataHolder = UtilityMethods.convertMap(tempMap);

      tempPropertyType = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder, key: "property_type") ?? "";
      tempPropertyStatus = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder, key: "property_status") ?? "";
      tempPropertyLabel = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder, key: "property_label") ?? "";
    }else{
      tempPropertyType = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "property_type") ?? "";
    }

    tempMap = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "property_meta") ?? {};
    if(tempMap.isNotEmpty) {
      mapDataHolder = UtilityMethods.convertMap(tempMap);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_featured");
      tempFeatured = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
      if(tempFeatured.isNotEmpty && tempFeatured == '1'){
        tempIsFeatured = true;
      }

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_payment_status");
      if (dataHolder != null && dataHolder.isNotEmpty) {
        tempPaymentStatus = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
      }

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_price");
      tempPrice = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_sec_price");
      tempSecondPrice = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_currency_info");
      tempPriceCurrency = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_currency");
      tempCurrency = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_id");
      tempUniqueId = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_price_postfix");
      tempPricePostfix = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_virtual_tour");
      tempPropertyVirtualTourLink = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_map");
      tempAddressHideMap = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "agent_info") ?? {};
      if(dataHolder.isNotEmpty){
        tempAgentInfoMap = UtilityMethods.convertMap(dataHolder);
      }

      dataHolder = UtilityMethods.getListItemValueFromMap(inputMap: mapDataHolder, key: "fave_agents") ?? [];
      if(dataHolder.isNotEmpty){
        tempAgentList = List<String>.from(dataHolder).toSet().toList();// To get the distinctive members only
      }

      dataHolder = UtilityMethods.getListItemValueFromMap(inputMap: mapDataHolder, key: "fave_property_agency") ?? [];
      if(dataHolder.isNotEmpty){
        tempAgencyList = List<String>.from(dataHolder).toSet().toList(); // To get the distinctive members only
      }

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_display_option");
      tempAgentDisplayOption = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "houzez_total_rating");
      tempTotalRating = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_loggedintoview");
      String tempStr = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
      if(tempStr.isNotEmpty && tempStr == "1"){
        requiredLogin = true;
      }
      tempStr = ""; // dis-allocating the variable

      var data = HiveStorageManager.readCustomFieldsDataMaps();
      if (data != null && data.isNotEmpty) {
        final custom = customFromJson(data);
        var fieldList = [];
        var labelList = [];

        for (var data in custom.customFields!) {
          fieldList.add(data.fieldId);
          labelList.add(data.label);
        }

        for (int i = 0; i < fieldList.length; i++) {
          if (mapDataHolder.containsKey("fave_${fieldList[i]}")) {
            String key = "fave_${fieldList[i]}";
            var field = mapDataHolder[key];
            Map<String, dynamic> mapForEdit = {fieldList[i]: field};
            if (field is List) {
              field = field.join("\n");
            }
            Map<String, String> map = {labelList[i]: field};

            customFieldsMap.addAll(map);
            customFieldsMapForEditing.addAll(mapForEdit);
          }
        }
      }
    }

    // Dis-allocating the variables
    dataHolder = null;
    mapDataHolder = {};
    tempMap = {};
    tempFeatured = "";

    return PropertyInfo(
      isFeatured: tempIsFeatured,
      requiredLogin: requiredLogin,
      propertyType: tempPropertyType,
      propertyStatus: tempPropertyStatus,
      propertyLabel: tempPropertyLabel,
      priceCurrency: tempPriceCurrency,
      uniqueId: tempUniqueId,
      price: tempPrice,
      firstPrice: tempFirstPrice,
      secondPrice: tempSecondPrice,
      pricePostfix: tempPricePostfix,
      propertyVirtualTourLink: tempPropertyVirtualTourLink,
      featured: tempFeatured,
      addressHideMap: tempAddressHideMap,
      agentInfo: tempAgentInfoMap,
      agencyList: tempAgencyList,
      agentList: tempAgentList,
      agentDisplayOption: tempAgentDisplayOption,
      houzezTotalRating: tempTotalRating,
      currency: tempCurrency,
      customFieldsMap: customFieldsMap,
      customFieldsMapForEditing: customFieldsMapForEditing,
      paymentStatus: tempPaymentStatus,
    );
  }

  static Article parseArticleMap(Map<String, dynamic> json) {
    int? author;
    int catId = 0;
    int? tempId;
    int? tempFeaturedImageId;
    bool tempIsFav = false;
    String content = "";
    String image = "";
    String tempVideoUrl = "";
    String avatar = "";
    String category = "";
    String date = "";
    String postDateGmt = "";
    String modifiedDate = "";
    String modifiedDateGmt = "";
    String tempLink = "";
    String tempGuid = "";
    String tempType = "";
    String tempTitle = "";
    String tempVirtualTourLink = "";
    String propertyStatus = "";
    String userDisplayName = "";
    String userName = "";
    String reviewPostType = "";
    String reviewStars = "";
    String reviewBy = "";
    String reviewTo = "";
    String reviewPropertyId = "";
    String description = "";
    String reviewLikes = "";
    String reviewDislikes = "";
    List<String> listOfImages = [];
    Map<String, dynamic> avatarUrls = {};

    dynamic dataHolder;
    Map<String, dynamic> mapDataHolder = {};
    Map tempMap = {};

    if(json.containsKey("content")){
      dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "content") ?? {};
      if(dataHolder.isNotEmpty){
        content = UtilityMethods.getStringItemValueFromMap(inputMap: dataHolder, key: "rendered") ?? "";
      }
    }
    if(json.containsKey("post_content")){
      content = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "post_content") ?? "";
    }
    if(content.isNotEmpty){
      content = UtilityMethods.cleanContent(content);
    }

    if(json.containsKey("author")){
      author = UtilityMethods.getIntegerItemValueFromMap(inputMap: json, key: "author");
    }
    if(json.containsKey("post_author")){
      dataHolder = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "post_author") ?? "";
      if(dataHolder.isNotEmpty){
        author = int.tryParse(dataHolder);
      }
    }

    tempFeaturedImageId = UtilityMethods.getIntegerItemValueFromMap(inputMap: json, key: "featured_media");

    image = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "thumbnail") ?? "";

    dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "avatar_urls") ?? {};
    if(dataHolder.isNotEmpty){
      avatarUrls = UtilityMethods.convertMap(dataHolder);
    }

    description = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "description") ?? "";
    if(description.isNotEmpty){
      description = UtilityMethods.cleanContent(description);
    }

    dataHolder = UtilityMethods.getListItemValueFromMap(inputMap: json, key: "property_images") ?? [];
    if(dataHolder.isNotEmpty){
      dataHolder.removeWhere((element) => element is !String || element == "null");
      listOfImages = List<String>.from(dataHolder);
    }

    if(listOfImages.isEmpty && image.isNotEmpty){
      listOfImages.add(image);
    }

    tempMap = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "property_meta") ?? {};
    if(tempMap.isNotEmpty) {
      mapDataHolder = UtilityMethods.convertMap(tempMap);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_video_url");
      tempVideoUrl = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_virtual_tour");
      tempVirtualTourLink = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "_thumbnail_id");
      String tempMedia = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
      if(tempMedia.isNotEmpty){
        tempFeaturedImageId = int.tryParse(tempMedia);
      }
      tempMedia = ""; // dis-allocating the variable
    }

    tempMap = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "meta") ?? {};
    if(tempMap.isNotEmpty) {
      mapDataHolder = UtilityMethods.convertMap(tempMap);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "review_post_type");
      reviewPostType = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "review_stars");
      reviewStars = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "review_by");
      reviewBy = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "review_to");
      reviewTo = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "review_property_id");
      reviewPropertyId = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "review_likes");
      reviewLikes = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "review_dislikes");
      reviewDislikes = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
    }

    if(json.containsKey("date")){
      dataHolder = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "date") ?? "";
      if(dataHolder.isNotEmpty){
        date = DateFormat('dd MMMM, yyyy', 'en').format(DateTime.parse(dataHolder + "z")).toString();
      }
    }

    if(json.containsKey("date_gmt")){
      postDateGmt = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "date_gmt") ?? "";
    }

    if(json.containsKey("modified")){
      modifiedDate = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "modified") ?? "";
    }

    if(json.containsKey("modified_gmt")){
      dataHolder = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "modified_gmt") ?? "";
      if(dataHolder.isNotEmpty){
        modifiedDateGmt = UtilityMethods.getTimeAgoFormat(time: dataHolder, locale: 'en_short');
      }
    }

    if(json.containsKey("post_date")){
      dataHolder = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "post_date") ?? "";
      if(dataHolder.isNotEmpty){
        date = UtilityMethods.getTimeAgoFormat(time: dataHolder);
      }
      // if(dataHolder.isNotEmpty){
      //   date = DateFormat('dd MMMM, yyyy', 'en_US').format(DateTime.parse(dataHolder + "z")).toString();
      // }
    }

    if(json.containsKey("post_date_gmt")){
      postDateGmt = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "post_date_gmt") ?? "";
    }

    if(json.containsKey("post_modified")){
      modifiedDate = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "post_modified") ?? "";
    }

    if(json.containsKey("post_modified_gmt")){
      dataHolder = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "post_modified_gmt") ?? "";
      if(dataHolder.isNotEmpty){
        modifiedDateGmt = UtilityMethods.getTimeAgoFormat(time: dataHolder);
      }
    }

    if(json.containsKey("user_display_name")){
      userDisplayName = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "user_display_name") ?? "";
    }

    if(json.containsKey("username")){
      userName = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "username") ?? "";
    }

    if(json.containsKey("title")){
      dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "title") ?? {};
      if(dataHolder.isNotEmpty){
        tempTitle = UtilityMethods.getStringItemValueFromMap(inputMap: dataHolder, key: "rendered") ?? "";
      }
    }

    if(json.containsKey("post_title")){
      tempTitle = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "post_title") ?? "";
    }

    if(json.containsKey("name")){
      tempTitle = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "name") ?? "";
    }

    if(json.containsKey("ID")){
      tempId = UtilityMethods.getIntegerItemValueFromMap(inputMap: json, key: "ID");
    }

    if(json.containsKey("id")){
      tempId = UtilityMethods.getIntegerItemValueFromMap(inputMap: json, key: "id");
    }

    if(json.containsKey("property_id")){
      tempId = UtilityMethods.getIntegerItemValueFromMap(inputMap: json, key: "property_id");
    }

    if(json.containsKey("type")){
      tempType = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "type") ?? "";
    }

    if(json.containsKey("post_type")){
      tempType = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "post_type") ?? "";
    }

    if(json.containsKey("status")){
      propertyStatus = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "status") ?? "";
    }

    if(json.containsKey("post_status")){
      propertyStatus = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "post_status") ?? "";
    }

    tempLink = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "link") ?? "";

    tempIsFav = UtilityMethods.getBooleanItemValueFromMap(inputMap: json, key: "is_fav");

    if(json.containsKey("post_status")){
      if(json["guid"] is String){
        tempGuid = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "guid") ?? "";
      }
      if(json["guid"] is Map){
        dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "guid") ?? {};
        if(dataHolder.isNotEmpty){
          tempGuid = UtilityMethods.getStringItemValueFromMap(inputMap: dataHolder, key: "rendered") ?? "";
        }
      }
    }

    Article article;
    article = Article(
        id: tempId,
        title: UtilityMethods.cleanContent(tempTitle),
        content: content,
        image: image,
        imageList: listOfImages,
        video: tempVideoUrl,
        author: author,
        avatar: avatar,
        category: category,
        date: date,
        dateGMT: postDateGmt,
        link: tempLink,
        guid: UtilityMethods.cleanContent(tempGuid),
        catId: catId,
        virtualTourLink: tempVirtualTourLink,
        status: propertyStatus,
        isFav: tempIsFav,
        type: tempType,
        reviewBy: reviewBy,
        featuredImageId: tempFeaturedImageId,
        // reviewDislikes: reviewDislikes,
        // reviewLikes: reviewLikes,
        reviewPostType: reviewPostType,
        reviewPropertyId: reviewPropertyId,
        reviewStars: reviewStars,
        reviewTo: reviewTo,
        modifiedDate: modifiedDate,
        modifiedGmt: modifiedDateGmt,
        userDisplayName: userDisplayName,
        userName: userName,
        avatarUrls: avatarUrls,
        description: UtilityMethods.cleanContent(description),
    );

    Address address = parseAddressMap(json);
    PropertyInfo propertyInfo = parsePropertyInfoMap(json);
    Features features = parseFeaturesMap(json);
    Author authorInfo = parseAuthorInfoMap(json);
    if (json.containsKey("additional_details")) {
      MembershipPlanDetails membershipPlanDetails = MembershipPlanDetails.fromJson(json['additional_details']);
      article.membershipPlanDetails = membershipPlanDetails;
    }
    article.propertyInfo = propertyInfo;
    article.address = address;
    article.features = features;
    article.otherFeatures!.addAll(json);
    article.internalFeaturesList!.addAll(features.featuresList!);
    article.authorInfo = authorInfo;

    Map<String, String> propDetails = new Map<String, String>();

    String _formattedDate = "";
    String createdDate = "";
    String _dateGmt = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "post_date_gmt") ?? "";
    String _modifiedDateGmt = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "post_modified_gmt") ?? "";

    if (_dateGmt.isNotEmpty) {
      createdDate = UtilityMethods.getFormattedDate(_dateGmt);
    }
    if (_modifiedDateGmt.isNotEmpty) {
      _formattedDate = UtilityMethods.getFormattedDate(_modifiedDateGmt);
    }

    if (createdDate.isNotEmpty) {
      propDetails[PROPERTY_DETAILS_PROPERTY_CREATED_DATE] = createdDate;
    }

    if (_formattedDate.isNotEmpty && createdDate != _formattedDate) {
      propDetails[PROPERTY_DETAILS_PROPERTY_LAST_UPDATED] = _formattedDate;
    }

    if (article.id != null) {
      propDetails[PROPERTY_DETAILS_PROPERTY_ID] = article.id.toString();
    }

    if (propertyInfo.price != null && propertyInfo.price!.isNotEmpty) {
      if (propertyInfo.secondPrice != null && propertyInfo.secondPrice!.isNotEmpty) {
        propDetails[FIRST_PRICE] = propertyInfo.price!;
        propDetails[SECOND_PRICE] = propertyInfo.secondPrice!;
        if (propertyInfo.pricePostfix!.isNotEmpty) {
          propDetails[SECOND_PRICE] = propertyInfo.secondPrice! + "/" + propertyInfo.pricePostfix!;
        }
      } else if (propertyInfo.secondPrice == null || propertyInfo.secondPrice!.isEmpty) {
        propDetails[PRICE] = propertyInfo.price!;
        if (propertyInfo.pricePostfix!.isNotEmpty) {
          propDetails[PRICE] = propertyInfo.price! + "/" + propertyInfo.pricePostfix!;
        }
      }
    }

    if (propertyInfo.propertyType != null &&
        propertyInfo.propertyType!.isNotEmpty) {
      propDetails[PROPERTY_DETAILS_PROPERTY_TYPE] = propertyInfo.propertyType!;
    }

    if (propertyInfo.propertyStatus != null &&
        propertyInfo.propertyStatus!.isNotEmpty) {
      propDetails[PROPERTY_DETAILS_PROPERTY_STATUS] = propertyInfo.propertyStatus!;
    }

    if (propertyInfo.uniqueId != null && propertyInfo.uniqueId!.isNotEmpty) {
      propDetails[PROPERTY_DETAILS_PROPERTY_UNIQUE_ID] = propertyInfo.uniqueId!;
    }

    if (features.landArea != null && features.landArea!.isNotEmpty) {
      propDetails[PROPERTY_DETAILS_PROPERTY_SIZE] = features.landArea!;
      // propDetails['Property Size'] = features.landArea + " " + features.landAreaUnit;
    }

    if (features.bedrooms != null && features.bedrooms!.isNotEmpty) {
      propDetails[PROPERTY_DETAILS_PROPERTY_BEDROOMS] = features.bedrooms!;
    }

    if (features.bathrooms != null && features.bathrooms!.isNotEmpty) {
      propDetails[PROPERTY_DETAILS_PROPERTY_BATHROOMS] = features.bathrooms!;
    }

    if (features.garage != null && features.garage!.isNotEmpty) {
      propDetails[PROPERTY_DETAILS_PROPERTY_GARAGE] = features.garage!;
    }

    if (features.garageSize != null && features.garageSize!.isNotEmpty) {
      propDetails[PROPERTY_DETAILS_PROPERTY_GARAGE_SIZE] = features.garageSize!;
    }

    if (features.yearBuilt != null && features.yearBuilt!.isNotEmpty) {
      propDetails[PROPERTY_DETAILS_PROPERTY_YEAR_BUILT] = features.yearBuilt!;
    }

    article.propertyDetailsMap = propDetails;


    // Dis-allocating the variables
    dataHolder = null;
    mapDataHolder = {};
    tempMap = {};

    return article;
  }
  
  static Term parsePropertyMetaDataMap(Map<String, dynamic> json) {
    int? tempId;
    int? tempParent;
    int? tempTotalCount;
    String tempName = "";
    String tempSlug = "";
    String tempThumbnail = "";
    String tempFullImage = "";
    String taxonomy = "";
    String parentTerm = "";
    var unescape = HtmlUnescape();

    tempId = UtilityMethods.getIntegerItemValueFromMap(inputMap: json, key: "term_id");
    tempParent = UtilityMethods.getIntegerItemValueFromMap(inputMap: json, key: "parent");
    tempTotalCount = UtilityMethods.getIntegerItemValueFromMap(inputMap: json, key: "count");
    tempName = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "name") ?? "";
    if(tempName.isNotEmpty){
      tempName = unescape.convert(tempName);
    }
    tempSlug = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "slug") ?? "";
    if(tempSlug.isNotEmpty){
      tempSlug = unescape.convert(tempSlug);
    }
    tempThumbnail = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "thumbnail") ?? "";
    tempFullImage = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "full") ?? "";
    taxonomy = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "taxonomy") ?? "";
    parentTerm = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_parent_term") ?? "";

    Term propertyMetaData = Term(
      id: tempId,
      name: tempName,
      slug: tempSlug,
      parent: tempParent,
      totalPropertiesCount: tempTotalCount,
      thumbnail: tempThumbnail,
      fullImage: tempFullImage,
      taxonomy: taxonomy,
      parentTerm: parentTerm
    );

    return propertyMetaData;
  }

  static Agency parseAgencyInformation(Map<String, dynamic> json) {
    int? tempId;
    String tempSlug = "";
    String tempType = "";
    String tempTitle = "";
    String tempContent = "";
    String tempThumbnail = "";
    String tempAgencyFaxNumber = "";
    String tempAgencyLicenseNumber = "";
    String tempAgencyPhoneNumber = "";
    String tempAgencyMobileNumber = "";
    String tempAgencyEmail = "";
    String tempAgencyAddress = "";
    String tempAgencyMapAddress = "";
    String tempAgencyLocation = "";
    String tempAgencyTaxNumber = "";
    String tempAgencyLink = "";
    String agencyWhatsappNumber = "";
    String tempTotalRating = "";

    dynamic dataHolder;
    Map<String, dynamic> mapDataHolder = {};
    Map tempMap = {};

    tempId = UtilityMethods.getIntegerItemValueFromMap(inputMap: json, key: "id");
    tempSlug = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "slug") ?? "";
    tempType = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "type") ?? "";
    tempAgencyLink = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "link") ?? "";
    tempAgencyLink = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "link") ?? "";
    tempThumbnail = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "thumbnail") ?? "";
    dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "title") ?? {};
    if(dataHolder.isNotEmpty){
      tempTitle = UtilityMethods.getStringItemValueFromMap(inputMap: dataHolder, key: "rendered") ?? "";
    }
    dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "content") ?? {};
    if(dataHolder.isNotEmpty){
      tempContent = UtilityMethods.getStringItemValueFromMap(inputMap: dataHolder, key: "rendered") ?? "";
    }

    tempMap = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "agency_meta") ?? {};
    if(tempMap.isNotEmpty) {
      mapDataHolder = UtilityMethods.convertMap(tempMap);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agency_fax");
      tempAgencyFaxNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agency_licenses");
      tempAgencyLicenseNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agency_phone");
      tempAgencyPhoneNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agency_mobile");
      tempAgencyMobileNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agency_email");
      tempAgencyEmail = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agency_address");
      tempAgencyAddress = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agency_map_address");
      tempAgencyMapAddress = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agency_location");
      tempAgencyLocation = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agency_tax_no");
      tempAgencyTaxNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agency_whatsapp");
      agencyWhatsappNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "houzez_total_rating");
      tempTotalRating = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
    }

    // Dis-allocating the variables
    dataHolder = null;
    mapDataHolder = {};
    tempMap = {};

    return Agency(
        id: tempId,
        slug: tempSlug,
        type: tempType,
        title: UtilityMethods.cleanContent(tempTitle),
        content: UtilityMethods.cleanContent(tempContent),
        thumbnail: tempThumbnail,
        agencyFaxNumber: tempAgencyFaxNumber,
        agencyLicenseNumber: tempAgencyLicenseNumber,
        agencyPhoneNumber: tempAgencyPhoneNumber,
        agencyMobileNumber: tempAgencyMobileNumber,
        email: tempAgencyEmail,
        agencyAddress: tempAgencyAddress,
        agencyMapAddress: tempAgencyMapAddress,
        agencyLocation: tempAgencyLocation,
        agencyTaxNumber: tempAgencyTaxNumber,
        agencyLink: tempAgencyLink,
        agencyWhatsappNumber: agencyWhatsappNumber,
        totalRating: tempTotalRating
    );
  }

  static Agent parseAgentInformation(Map<String, dynamic> json) {
    int? tempId;
    String tempAgentId = "";
    String tempUserAgentId = "";
    String tempSlug = "";
    String tempType = "";
    String tempTitle = "";
    String tempContent = "";
    String tempThumbnail = "";
    String tempTotalRating = "";
    String tempAgentPosition = "";
    String tempAgentCompany = "";
    String tempAgentMobileNumber = "";
    String tempAgentOfficeNumber = "";
    String tempAgentPhoneNumber = "";
    String tempAgentFaxNumber = "";
    String tempAgentEmail = "";
    String tempAgentAddress = "";
    String tempAgentTaxNumber = "";
    String tempAgentLicenseNumber = "";
    String tempAgentServiceArea = "";
    String tempAgentSpecialties = "";
    String tempAgentLink = "";
    String agentWhatsappNumber = "";
    String agentUserName = "";
    String tempAgentFirstName = "";
    String tempAgentLastName = "";
    List<String> tempAgentAgenciesList = [];

    dynamic dataHolder;
    Map<String, dynamic> mapDataHolder = {};
    Map tempMap = {};

    tempId = UtilityMethods.getIntegerItemValueFromMap(inputMap: json, key: "id");
    tempUserAgentId = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "ID") ?? "";
    tempSlug = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "slug") ?? "";
    agentUserName = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "user_login") ?? "";
    tempAgentEmail = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "user_email") ?? "";
    tempType = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "type") ?? "";
    tempAgentLink = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "link") ?? "";
    dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "title") ?? {};
    if(dataHolder.isNotEmpty){
      tempTitle = UtilityMethods.getStringItemValueFromMap(inputMap: dataHolder, key: "rendered") ?? "";
    }
    if (json.containsKey("display_name") && tempTitle.isEmpty) {
      tempTitle = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "display_name") ?? "";
    }
    dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "content") ?? {};
    if(dataHolder.isNotEmpty){
      tempContent = UtilityMethods.getStringItemValueFromMap(inputMap: dataHolder, key: "rendered") ?? "";
    }
    tempThumbnail = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "thumbnail") ?? "";

    tempMap = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "agent_meta") ?? {};
    if(tempMap.isNotEmpty) {
      mapDataHolder = UtilityMethods.convertMap(tempMap);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_position");
      tempAgentPosition = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      if(mapDataHolder.containsKey("fave_author_custom_picture") && tempThumbnail.isEmpty){
        dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_author_custom_picture");
        tempThumbnail = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
      }

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_company");
      tempAgentCompany = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "first_name");
      tempAgentFirstName = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "last_name");
      tempAgentLastName = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_author_agent_id");
      tempAgentId = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_mobile");
      tempAgentMobileNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_office_num");
      tempAgentOfficeNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      if(mapDataHolder.containsKey("fave_author_mobile") && tempAgentMobileNumber.isEmpty) {
        dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_author_mobile");
        tempAgentMobileNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
      }

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_author_phone");
      tempAgentPhoneNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_fax");
      tempAgentFaxNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      if(mapDataHolder.containsKey("fave_agent_email") && tempAgentEmail.isEmpty) {
        dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_email");
        tempAgentEmail = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
      }

      dataHolder = UtilityMethods.getListItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_agencies") ?? [];
      if(dataHolder.isNotEmpty){
        tempAgentAgenciesList = List<String>.from(dataHolder);
      }

      if(mapDataHolder.containsKey("fave_author_agency_id") && tempAgentAgenciesList.isEmpty) {
        dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_author_agency_id");
        String temp = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
        if(temp.isNotEmpty){
          tempAgentAgenciesList = [temp];
        }
        temp = ""; //dis-allocating the variable
      }

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_address");
      tempAgentAddress = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_tax_no");
      tempAgentTaxNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_license");
      tempAgentLicenseNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_service_area");
      tempAgentServiceArea = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_specialties");
      tempAgentSpecialties = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "houzez_total_rating");
      tempTotalRating = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

      dataHolder = UtilityMethods.getItemValueFromMap(inputMap: mapDataHolder, key: "fave_agent_whatsapp");
      agentWhatsappNumber = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);
    }

    // Dis-allocating the variables
    dataHolder = null;
    mapDataHolder = {};
    tempMap = {};

    return Agent(
      id: tempId,
      slug: tempSlug,
      type: tempType,
      title: UtilityMethods.cleanContent(tempTitle),
      content: UtilityMethods.cleanContent(tempContent),
      thumbnail: tempThumbnail,
      totalRating: tempTotalRating,
      agentFaxNumber: tempAgentFaxNumber,
      agentLicenseNumber: tempAgentLicenseNumber,
      agentOfficeNumber: tempAgentOfficeNumber,
      agentMobileNumber: tempAgentMobileNumber,
      email: tempAgentEmail,
      agentAddress: tempAgentAddress,
      agentServiceArea: tempAgentServiceArea,
      agentSpecialties: tempAgentSpecialties,
      agentTaxNumber: tempAgentTaxNumber,
      agentAgencies: tempAgentAgenciesList,
      agentCompany: tempAgentCompany,
      agentPosition: tempAgentPosition,
      agentLink: tempAgentLink,
      agentWhatsappNumber: agentWhatsappNumber,
      agentPhoneNumber: tempAgentPhoneNumber,
      agentId : tempAgentId,
      userAgentId : tempUserAgentId,
      agentUserName :agentUserName,
      agentFirstName:tempAgentFirstName,
      agentLastName:tempAgentLastName,
    );
  }

  // static MembershipPlanDetails parseMembershipPlanDetailsMap(Map<String, dynamic> json) {
  //
  //   // Map<String, dynamic> json = jsonDecode(json);
  //
  //
  //   String vcPostSettings = "";
  //   String faveBillingTimeUnit = "";
  //   String faveBillingUnit = "";
  //   String favePackageListings = "";
  //   String faveUnlimitedListings = "";
  //   String favePackageFeaturedListings = "";
  //   String favePackagePrice = "";
  //   String favePackageStripeId = "";
  //   String favePackageVisible = "";
  //   String favePackagePopular = "";
  //   String faveUnlimitedImages = "";
  //   String editLock = "";
  //   String editLast = "";
  //   String androidIapId = "";
  //   String iosIapId = "";
  //   String rsPageBgColor = "";
  //   dynamic dataHolder;
  //   Map<String, dynamic> mapDataHolder = {};
  //   Map<String, dynamic> mapDataHolder01 = {};
  //   Map tempMap = {};
  //
  //   dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "property_meta") ?? {};
  //   if(dataHolder.isNotEmpty) {
  //     mapDataHolder = UtilityMethods.convertMap(dataHolder);
  //
  //     tempMap = UtilityMethods.getMapItemValueFromMap(inputMap: mapDataHolder, key: "agent_info") ?? {};
  //     if(tempMap.isNotEmpty) {
  //       mapDataHolder01 = UtilityMethods.convertMap(tempMap);
  //
  //       tempData = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_data") ?? "";
  //       tempIsSingle = UtilityMethods.getBooleanItemValueFromMap(inputMap: mapDataHolder01, key: "is_single_agent");
  //       tempEmail = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_email") ?? "";
  //       tempName = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_name") ?? "";
  //       tempPhone = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_phone") ?? "";
  //       tempPhoneCall = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_phone_call") ?? "";
  //       tempMobile = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_mobile") ?? "";
  //       tempMobileCall = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_mobile_call") ?? "";
  //       tempWhatsApp = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_whatsapp") ?? "";
  //       tempWhatsAppCall = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_whatsapp_call") ?? "";
  //       tempPicture = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "picture") ?? "";
  //       tempLink = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "link") ?? "";
  //       tempType = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_type") ?? "";
  //       tempId = UtilityMethods.getIntegerItemValueFromMap(inputMap: mapDataHolder01, key: "agent_id");
  //     }
  //   }
  //
  //   // Dis-allocating the variables
  //   dataHolder = null;
  //   mapDataHolder = {};
  //   mapDataHolder01 = {};
  //   tempMap = {};
  //
  //
  //   return MembershipPlanDetails(
  //
  //
  //
  //   );
  // }

  static Author parseAuthorInfoMap(Map<String, dynamic> json) {
    int? tempId;
    bool tempIsSingle = false;
    String tempData = "";
    String tempEmail = "";
    String tempName = "";
    String tempPhone = "";
    String tempPhoneCall = "";
    String tempMobile = "";
    String tempMobileCall = "";
    String tempWhatsApp = "";
    String tempWhatsAppCall = "";
    String tempPicture = "";
    String tempLink = "";
    String tempType = "";

    dynamic dataHolder;
    Map<String, dynamic> mapDataHolder = {};
    Map<String, dynamic> mapDataHolder01 = {};
    Map tempMap = {};

    dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "property_meta") ?? {};
    if(dataHolder.isNotEmpty) {
      mapDataHolder = UtilityMethods.convertMap(dataHolder);

      tempMap = UtilityMethods.getMapItemValueFromMap(inputMap: mapDataHolder, key: "agent_info") ?? {};
      if(tempMap.isNotEmpty) {
        mapDataHolder01 = UtilityMethods.convertMap(tempMap);

        tempData = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_data") ?? "";
        tempIsSingle = UtilityMethods.getBooleanItemValueFromMap(inputMap: mapDataHolder01, key: "is_single_agent");
        tempEmail = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_email") ?? "";
        tempName = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_name") ?? "";
        tempPhone = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_phone") ?? "";
        tempPhoneCall = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_phone_call") ?? "";
        tempMobile = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_mobile") ?? "";
        tempMobileCall = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_mobile_call") ?? "";
        tempWhatsApp = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_whatsapp") ?? "";
        tempWhatsAppCall = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_whatsapp_call") ?? "";
        tempPicture = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "picture") ?? "";
        tempLink = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "link") ?? "";
        tempType = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "agent_type") ?? "";
        tempId = UtilityMethods.getIntegerItemValueFromMap(inputMap: mapDataHolder01, key: "agent_id");
      }
    }

    // Dis-allocating the variables
    dataHolder = null;
    mapDataHolder = {};
    mapDataHolder01 = {};
    tempMap = {};

    Author authorInfo = Author(
      id: tempId,
      isSingle: tempIsSingle,
      data: tempData,
      email: tempEmail,
      name: tempName,
      phone: tempPhone,
      phoneCall: tempPhoneCall,
      mobile: tempMobile,
      mobileCall: tempMobileCall,
      whatsApp: tempWhatsApp,
      whatsAppCall: tempWhatsAppCall,
      picture: tempPicture,
      link: tempLink,
      type: tempType,
    );
    return authorInfo;
  }

  static FloorPlans parseFloorPlansMap(Map<String, dynamic> json) {
    String tempTitle = "";
    String tempRooms = "";
    String tempBathrooms = "";
    String tempPrice = "";
    String tempPricePostFix = "";
    String tempSize = "";
    String tempImage = "";
    String tempDescription = "";

    tempTitle = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_plan_title") ?? "";
    tempRooms = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_plan_rooms") ?? "";
    tempBathrooms = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_plan_bathrooms") ?? "";
    tempPrice = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_plan_price") ?? "";
    tempPricePostFix = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_plan_price_postfix") ?? "";
    tempSize = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_plan_size") ?? "";
    tempImage = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_plan_image") ?? "";
    tempDescription = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_plan_description") ?? "";
    
    FloorPlans floorPlans = FloorPlans(
      title: tempTitle,
      rooms: tempRooms,
      bathrooms: tempBathrooms,
      price: tempPrice,
      pricePostFix: tempPricePostFix,
      size: tempSize,
      image: tempImage,
      description: tempDescription,
    );

    return floorPlans;
  }

  static MultiUnit parseMultiUnitsMap(Map<String, dynamic> json) {
    String faveMuTitle = "";
    String faveMuPrice = "";
    String faveMuPricePostfix = "";
    String faveMuBeds = "";
    String faveMuBaths = "";
    String faveMuSize = "";
    String faveMuSizePostfix = "";
    String faveMuType = "";
    String faveMuAvailabilityDate = "";

    faveMuTitle = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_mu_title") ?? "";
    faveMuPrice = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_mu_price") ?? "";
    faveMuPricePostfix = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_mu_price_postfix") ?? "";
    faveMuBeds = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_mu_beds") ?? "";
    faveMuBaths = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_mu_baths") ?? "";
    faveMuSize = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_mu_size") ?? "";
    faveMuSizePostfix = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_mu_size_postfix") ?? "";
    faveMuType = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_mu_type") ?? "";
    faveMuAvailabilityDate = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "fave_mu_availability_date") ?? "";

    MultiUnit multiUnit = MultiUnit(
      availabilityDate: faveMuAvailabilityDate,
      bathrooms: faveMuBaths,
      bedrooms: faveMuBeds,
      price: faveMuPrice,
      pricePostfix: faveMuPricePostfix,
      size: faveMuSize,
      sizePostfix: faveMuSizePostfix,
      title: faveMuTitle,
      type: faveMuType,
    );

    return multiUnit;
  }

  static SavedSearch parseSavedSearchMap(Map<String, dynamic> json) {
    String id = "";
    String autherId = "";
    String query = "";
    String email = "";
    String url = "";
    String time = "";

    dynamic dataHolder;

    id = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "id") ?? "";
    autherId = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "auther_id") ?? "";
    query = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "query") ?? "";
    email = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "email") ?? "";
    url = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "url") ?? "";
    dataHolder = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "time") ?? "";
    if(dataHolder.isNotEmpty){
      time = UtilityMethods.getTimeAgoFormat(time: dataHolder);
    }

    // Dis-allocating the variables
    dataHolder = null;

    return SavedSearch(
      id: id,
      autherId: autherId,
      email: email,
      query: query,
      time: time,
      url: url,
    );
  }

  static User parseUserInfoMap(Map<String, dynamic> json) {
    String id = "";
    String userLogin = "";
    String userNicename = "";
    String userEmail = "";
    String userUrl = "";
    String userStatus = "";
    String displayName = "";
    String profile = "";
    String username = "";
    String userTitle = "";
    String firstName = "";
    String lastName = "";
    String userMobile = "";
    String userWhatsapp = "";
    String userPhone = "";
    String description = "";
    String userlangs = "";
    String userCompany = "";
    String taxNumber = "";
    String faxNumber = "";
    String userAddress = "";
    String serviceAreas = "";
    String specialties = "";
    String license = "";
    String gdprAgreement = "";
    String roles = "";
    String facebook = "";
    String twitter = "";
    String instagram = "";
    String linkedin = "";
    String youtube = "";
    String pinterest = "";
    String vimeo = "";
    String skype = "";
    String website = "";
    List displayNameOptions = [];

    dynamic dataHolder;
    Map<String, dynamic> mapDataHolder = {};
    Map<String, dynamic> mapDataHolder01 = {};
    Map tempMap = {};

    dataHolder = UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "roles") ?? [];
    roles = UtilityMethods.getStringValueFromDynamicItem(item: dataHolder);

    dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "user") ?? {};
    if(dataHolder.isNotEmpty) {
      mapDataHolder = UtilityMethods.convertMap(dataHolder);
    }

    if(mapDataHolder.isNotEmpty) {
      tempMap = UtilityMethods.getMapItemValueFromMap(inputMap: mapDataHolder, key: "data") ?? {};
      if(tempMap.isNotEmpty) {
        mapDataHolder01 = UtilityMethods.convertMap(tempMap);

        id = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "ID") ?? "";
        userLogin = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "user_login") ?? "";
        userNicename = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "user_nicename") ?? "";
        userEmail = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "user_email") ?? "";
        userUrl = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "user_url") ?? "";
        userStatus = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "user_status") ?? "";
        displayName = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "display_name") ?? "";
        profile = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "profile") ?? "";
        username = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "username") ?? "";
        userTitle = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "user_title") ?? "";
        firstName = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "first_name") ?? "";
        lastName = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "last_name") ?? "";
        userMobile = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "user_mobile") ?? "";
        userWhatsapp = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "user_whatsapp") ?? "";
        userPhone = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "user_phone") ?? "";
        dataHolder = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "description") ?? "";
        if(dataHolder.isNotEmpty){
          description = UtilityMethods.cleanContent(dataHolder);
        }
        userlangs = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "userlangs") ?? "";
        userCompany = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "user_company") ?? "";
        taxNumber = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "tax_number") ?? "";
        faxNumber = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "fax_number") ?? "";
        userAddress = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "user_address") ?? "";
        serviceAreas = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "service_areas") ?? "";
        specialties = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "specialties") ?? "";
        license = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "license") ?? "";
        gdprAgreement = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "gdpr_agreement") ?? "";
        facebook = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "facebook") ?? "";
        twitter = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "twitter") ?? "";
        instagram = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "instagram") ?? "";
        linkedin = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "linkedin") ?? "";
        skype = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "userskype") ?? "";
        pinterest = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "pinterest") ?? "";
        youtube = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "youtube") ?? "";
        vimeo = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "vimeo") ?? "";
        website = UtilityMethods.getStringItemValueFromMap(inputMap: mapDataHolder01, key: "website") ?? "";
        dataHolder = UtilityMethods.getListItemValueFromMap(inputMap: mapDataHolder01, key: "display_name_options") ?? [];
        if(dataHolder.isNotEmpty){
          displayNameOptions = List<String>.from(dataHolder);
        }
      }
    }

    // Dis-allocating the variables
    dataHolder = null;
    mapDataHolder = {};
    mapDataHolder01 = {};
    tempMap = {};

    return User(
      id: id,
      lastName: lastName,
      firstName: firstName,
      displayName: displayName,
      description: description,
      faxNumber: faxNumber,
      gdprAgreement: gdprAgreement,
      license: license,
      profile: profile,
      roles: roles,
      serviceAreas: serviceAreas,
      specialties: specialties,
      taxNumber: taxNumber,
      userAddress: userAddress,
      userCompany: userCompany,
      userEmail: userEmail,
      userlangs: userlangs,
      userLogin: userLogin,
      userMobile: userMobile,
      username: username,
      userNicename: userNicename,
      userPhone: userPhone,
      userStatus: userStatus,
      userTitle: userTitle,
      userUrl: userUrl,
      userWhatsapp: userWhatsapp,
      displayNameOptions: displayNameOptions,
      facebook: facebook,
      instagram: instagram,
      linkedin: linkedin,
      twitter: twitter,
      pinterest: pinterest,
      skype: skype,
      vimeo: vimeo,
      website: website,
      youtube: youtube,
    );
  }

  static List<dynamic> getParsedDataInList({required List<dynamic> inputList, required Function(Map<String, dynamic>) function}){
    List<dynamic> outputList = inputList.map((item) => function(item)).toList();
    return outputList;
  }

  @override
  ApiResponse<String> parseNonceResponse(Response response) {
    if (response.statusCode == HttpStatus.ok) {
      if (response.data is Map) {
        Map? map = response.data;
        if (map != null && map.containsKey("success") && map["success"]) {
          if (map.containsKey("nonce")) {
            return ApiResponse<String>(true, map["nonce"], "success");
          }
        }
      }
    } else {

      if (response.statusCode == 403 && response.data is Map) {
        Map? map = response.data;

        if (map != null && map.containsKey("reason") && map["reason"] != null) {
          print("***************************************************************");
          print("* ATTENTION: "+map["reason"]);
          print("***************************************************************");
          return ApiResponse<String>(false, "", map["reason"]);
        }
      }
    }
    return ApiResponse<String>(false, "", response.statusMessage!);
  }

  @override
  Partner parsePartnerJson(Map<String, dynamic> json) {
    String tempTitle = "";
    dynamic dataHolder;
    Map<String, dynamic> mapDataHolder = {};
    Map tempMap = {};


    if (json.containsKey("title")) {
      dataHolder = UtilityMethods.getMapItemValueFromMap(inputMap: json, key: "title") ?? {};
      if(dataHolder.isNotEmpty){
        tempTitle = UtilityMethods.getStringItemValueFromMap(inputMap: dataHolder, key: "rendered") ?? "";
      }
    }
    Partner partner = Partner(
      title: UtilityMethods.cleanContent(tempTitle),
      id: UtilityMethods.getIntegerItemValueFromMap(inputMap: json, key: "id"),
      date: UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "date"),
      dateGmt: UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "date_gmt"),
      modified: UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "modified"),
      modifiedGmt: UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "modified_gmt"),
      slug: UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "slug"),
      status: UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "status"),
      type: UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "type"),
      link: UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "link"),
      featuredMedia: UtilityMethods.getIntegerItemValueFromMap(inputMap: json, key: "featured_media"),
      menuOrder: UtilityMethods.getIntegerItemValueFromMap(inputMap: json, key: "menu_order"),
      template: UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "template"),
      featuredImageUrl: UtilityMethods.getStringItemValueFromMap(inputMap: json, key: "featured_image_url"),
    );

    // Dis-allocating the variables
    dataHolder = null;
    mapDataHolder = {};
    tempMap = {};

    return partner;
  }
  ApiResponse<String> parsePaymentResponse(Response response) {
    if (response.statusCode == HttpStatus.ok) {
      if (response.data is Map) {
        Map? map = response.data;
        if (map != null && map.containsKey("success") && map["success"]) {
          if (map.containsKey("message")) {
            return ApiResponse<String>(true, map["message"], map["message"]);
          }
        }
      }
    } else {

      if (response.statusCode == 403 && response.data is Map) {
        Map? map = response.data;

        if (map != null && map.containsKey("reason") && map["reason"] != null) {
          print("***************************************************************");
          print("* ATTENTION: "+map["reason"]);
          print("***************************************************************");
          return ApiResponse<String>(false, "", map["reason"]);
        }
      }
    }
    return ApiResponse<String>(false, "", response.statusMessage!);
  }

  @override
  ApiResponse<String> parseFeaturedResponse(Response response) {
    String tempResponseString = response.toString().split("{")[1];
    Map map = jsonDecode("{${tempResponseString.split("}")[0]}}");

    if (response.statusCode == 500) {
      if (map.containsKey("success") && map["success"]) {
        if (map.containsKey("msg")) {
          return ApiResponse<String>(true, "success", "success");
        }
      } else {
        print(
            "***************************************************************");
        print("* ATTENTION: " + "Error while making property featured");
        print(
            "***************************************************************");
        return ApiResponse<String>(false, "", "Error while making property featured");
      }
    }

    return ApiResponse<String>(false, "", response.statusMessage!);
  }

  @override
  UserMembershipPackage parseUserMembershipPackageResponse(Map<String, dynamic> json) {
    return UserMembershipPackage.fromJson(json);
  }
}

