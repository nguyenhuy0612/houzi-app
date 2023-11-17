import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/models/article.dart';
import 'package:houzi_package/pages/property_details_related_pages/property_detail_page_widgets/pd_heading_widget.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';
import 'package:houzi_package/widgets/toast_widget.dart';

class PropertyDetailPageDescription extends StatefulWidget {
  final Article article;
  final String title;
  const PropertyDetailPageDescription({required this.article, required this.title, Key? key}) : super(key: key);

  @override
  State<PropertyDetailPageDescription> createState() => _PropertyDetailPageDescriptionState();
}

class _PropertyDetailPageDescriptionState extends State<PropertyDetailPageDescription> {

  bool isReadMore = false;

  @override
  Widget build(BuildContext context) {
    return descriptionWidget(widget.title);
  }

  Widget descriptionWidget(String title) {
    if (title.isEmpty) {
      title = UtilityMethods.getLocalizedString("description");
    }
    String content = "";
    if (UtilityMethods.isValidString(widget.article.content)) {
      content = UtilityMethods.stripHtmlIfNeeded(widget.article.content!) ?? "";
    }

    final maxLines = isReadMore ? null : 6;
    final overFlow = isReadMore ? TextOverflow.visible : TextOverflow.ellipsis;
    return content.isNotEmpty
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textHeadingWidget(
            text: UtilityMethods.getLocalizedString(title),
            widget: content.length > 300 ? readMoreDescription() : Container()
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
          child: Align(
            alignment: UtilityMethods.isRTL(context)
                ? Alignment.centerRight : Alignment.centerLeft,
            child: GenericTextWidget(
              content,
              enableCopy: true,
              onLongPress: (){
                Clipboard.setData(ClipboardData(text: content));
                ShowToastWidget(
                  buildContext: context,
                  text: UtilityMethods.getLocalizedString(TEXT_COPIED_STRING),
                );
              },
              maxLines: maxLines,
              overflow: overFlow,
              strutStyle:
              StrutStyle(height: AppThemePreferences.bodyTextHeight),
              style: AppThemePreferences().appTheme.bodyTextStyle,
              textAlign: TextAlign.justify,
            ),
          ),
        ),
      ],
    )
        : Container();
  }

  Widget readMoreDescription() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
          child: Align(
            // alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                setState(() {
                  isReadMore = !isReadMore;
                });
              },
              child: GenericTextWidget(
                isReadMore
                    ? UtilityMethods.getLocalizedString("read_less")
                    : UtilityMethods.getLocalizedString("read_more"),
                strutStyle: StrutStyle(
                    height:
                    AppThemePreferences.genericTextHeight),
                style: AppThemePreferences()
                    .appTheme
                    .readMoreTextStyle,
                // textAlign: TextAlign.justify,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
