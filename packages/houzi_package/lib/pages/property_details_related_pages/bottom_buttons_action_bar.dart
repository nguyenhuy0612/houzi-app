import 'package:flutter/material.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/hooks_files/hooks_configurations.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/models/article.dart';
import 'package:houzi_package/pages/send_email_to_realtor.dart';
import 'package:houzi_package/widgets/button_widget.dart';
import 'package:houzi_package/widgets/no_internet_botton_widget.dart';
import 'package:url_launcher/url_launcher.dart';

typedef PropertyProfileBottomButtonActionBarListener = void Function(bool isBottomButtonActionBarDisplayed);

class PropertyProfileBottomButtonActionBar extends StatefulWidget {
  final bool isInternetConnected;
  final Function()? noInternetOnPressed;
  final Map<String, dynamic> realtorInfoMap;
  final Article? article;
  final String agentDisplayOption;
  final String? articleLink;
  final PropertyProfileBottomButtonActionBarListener? profileBottomButtonActionBarListener;

  const PropertyProfileBottomButtonActionBar({
    Key? key,
    this.isInternetConnected = true,
    this.noInternetOnPressed,
    required this.realtorInfoMap,
    required this.article,
    required this.agentDisplayOption,
    this.articleLink,
    this.profileBottomButtonActionBarListener,
  }) : super(key: key);

  @override
  State<PropertyProfileBottomButtonActionBar> createState() => _PropertyProfileBottomButtonActionBarState();
}

class _PropertyProfileBottomButtonActionBarState extends State<PropertyProfileBottomButtonActionBar> {

  int? tempRealtorId;
  String tempRealtorThumbnail = '';
  String tempRealtorEmail = '';
  String tempRealtorName = '';
  String tempRealtorPhone = "";
  String tempRealtorMobile = "";
  String tempRealtorWhatsApp = "";
  String tempRealtorLink = "";
  String agentDisplayOption = "";

  @override
  Widget build(BuildContext context) {
    tempRealtorId = widget.realtorInfoMap[tempRealtorIdKey];
    tempRealtorThumbnail = widget.realtorInfoMap[tempRealtorThumbnailKey] ?? "";
    tempRealtorEmail = widget.realtorInfoMap[tempRealtorEmailKey] ?? "";
    tempRealtorName = widget.realtorInfoMap[tempRealtorNameKey] ?? "";
    tempRealtorPhone = widget.realtorInfoMap[tempRealtorPhoneKey] ?? "";
    tempRealtorMobile = widget.realtorInfoMap[tempRealtorMobileKey] ?? "";
    tempRealtorWhatsApp = widget.realtorInfoMap[tempRealtorWhatsAppKey] ?? "";
    tempRealtorLink = widget.realtorInfoMap[tempRealtorLinkKey] ?? "";
    agentDisplayOption = widget.agentDisplayOption ?? "";

    if(showBottomButtonActionBar()) {
      widget.profileBottomButtonActionBarListener!(true);
      return Positioned(
        bottom: 0.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppThemePreferences().appTheme.backgroundColor!.withOpacity(0.8),
            border: Border(
              top: AppThemePreferences().appTheme.propertyDetailsPageBottomMenuBorderSide!,
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 70,
              child:
              !widget.isInternetConnected ? NoInternetBottomActionBarWidget(onPressed: ()=> widget.noInternetOnPressed!) :
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    if(showEmailActionButton()) Expanded(
                      flex: 1,
                      child: emailElevatedButtonWidget(),
                    ),
                    if(showEmailActionButton() && showCallActionButton()) const SizedBox(width: 5),
                    if(showCallActionButton()) Expanded(
                      flex: 1,
                      child: callElevatedButtonWidget(),
                    ),
                    if(showCallActionButton() && showWhatsappActionButton()) const SizedBox(width: 5),
                    if(showWhatsappActionButton()) Expanded(
                      flex: 1,
                      child: whatsappElevatedButtonWidget(),
                    ),
                  ],
                ),
              ),

            ),
          ),
        ),
      );
    } else {
      widget.profileBottomButtonActionBarListener!(false);
      return Container();
    }
  }

  bool showBottomButtonActionBar(){
    if(showEmailActionButton() || showCallActionButton() || showWhatsappActionButton()){
      return true;
    }

    return false;
  }

  bool showEmailActionButton(){
    if(SHOW_EMAIL_BUTTON && UtilityMethods.isValidString(tempRealtorEmail)){
      return true;
    }

    return false;
  }

  bool showCallActionButton(){
    if(SHOW_CALL_BUTTON &&
        (UtilityMethods.isValidString(tempRealtorPhone) || UtilityMethods.isValidString(tempRealtorMobile))){
      return true;
    }

    return false;
  }

  bool showWhatsappActionButton(){
    if(SHOW_WHATSAPP_BUTTON && UtilityMethods.isValidString(tempRealtorWhatsApp)){
      return true;
    }

    return false;
  }


  Widget emailElevatedButtonWidget(){
    return HooksConfigurations.widgetItem(context, widget.article, "email_button") ?? ButtonWidget(
      text: UtilityMethods.getLocalizedString("email_capital"),
      fontSize: AppThemePreferences.bottomActionBarFontSize,
      color: AppThemePreferences.emailButtonBackgroundColor,
      icon: Icon(
        AppThemePreferences.emailIcon,
        color: AppThemePreferences.filledButtonIconColor,
      ),
      onPressed: () => onEmailButtonPressed(),
      // centeredContent: true,
    );
  }

  Widget callElevatedButtonWidget(){
    return HooksConfigurations.widgetItem(context, widget.article, "call_button") ?? ButtonWidget(
      text: UtilityMethods.getLocalizedString("call_capital"),
      fontSize: AppThemePreferences.bottomActionBarFontSize,
      icon: Icon(
        AppThemePreferences.phoneIcon,
        color: AppThemePreferences.filledButtonIconColor,
      ),
      onPressed: () => onCallButtonPressed(),
      color: AppThemePreferences.callButtonBackgroundColor,
      // centeredContent: true,
    );
  }

  Widget whatsappElevatedButtonWidget() {
    return HooksConfigurations.widgetItem(context, widget.article, "whatsapp_button") ?? ButtonWidget(
      text: UtilityMethods.getLocalizedString("whatsapp"),
      icon: AppThemePreferences().appTheme.whatsAppIcon,
      fontSize: AppThemePreferences.bottomActionBarFontSize,
      color: AppThemePreferences.whatsAppBackgroundColor,
      onPressed: () async => onWhatsAppButtonPressed(),
    );
  }

  onEmailButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SendEmailToRealtor(
              informationMap: {
                SEND_EMAIL_APP_BAR_TITLE:
                UtilityMethods.getLocalizedString("enquire_information"),
                SEND_EMAIL_REALTOR_ID: tempRealtorId,
                SEND_EMAIL_REALTOR_NAME: tempRealtorName,
                SEND_EMAIL_REALTOR_EMAIL: tempRealtorEmail,
                SEND_EMAIL_REALTOR_TYPE: agentDisplayOption,
                SEND_EMAIL_MESSAGE: UtilityMethods.getLocalizedString(
                    "hello_i_am_interested_in",
                    inputWords: [
                      UtilityMethods.stripHtmlIfNeeded(widget.article!.title!),
                      widget.articleLink != null && widget.articleLink!.isNotEmpty
                          ? widget.articleLink
                          : widget.article!.link,
                      tempRealtorLink
                    ]),
                SEND_EMAIL_THUMBNAIL: tempRealtorThumbnail,
                SEND_EMAIL_SITE_NAME: APP_NAME,
                SEND_EMAIL_LISTING_ID: widget.article!.id,
                SEND_EMAIL_LISTING_NAME: widget.article!.title,
                SEND_EMAIL_UNIQUE_ID: widget.article!.propertyInfo!.uniqueId!,
                SEND_EMAIL_SOURCE: PROPERTY,
                SEND_EMAIL_LISTING_LINK: widget.articleLink!=null && widget.articleLink!.isNotEmpty ? widget.articleLink:widget.article!.link,
              },
            ),
      ),
    );
  }

  onCallButtonPressed() {
    String num = "";
    if(UtilityMethods.isValidString(tempRealtorPhone)){
      num = tempRealtorPhone;
    }else{
      num = tempRealtorMobile;
    }

    launchUrl(Uri.parse("tel://$num"));
  }

  onWhatsAppButtonPressed() async {
    String msg = UtilityMethods.getLocalizedString(
      "whatsapp_hello_i_am_interested_in",
      inputWords: [
        UtilityMethods.stripHtmlIfNeeded(widget.article!.title!),
        widget.articleLink != null && widget.articleLink!.isNotEmpty
            ? widget.articleLink
            : widget.article!.link,
      ],
    );
    tempRealtorWhatsApp = tempRealtorWhatsApp.replaceAll(RegExp(r'[()\s+-]'), '');
    var whatsappUrl = "whatsapp://send?phone=$tempRealtorWhatsApp&text=$msg";
    await canLaunchUrl(Uri.parse(whatsappUrl))
        ? launchUrl(Uri.parse(whatsappUrl))
        : launchUrl(Uri.parse("https://wa.me/$tempRealtorWhatsApp"));
  }
}
