import 'package:flutter/material.dart';
import 'package:jr_linguist/configs/constants.dart';

class LanguageSelectionDropdownWidget extends StatelessWidget {
  final String? selectedLanguage;
  final void Function(String selectedLanguage)? onLanguageSelected;

  const LanguageSelectionDropdownWidget({
    Key? key,
    required this.selectedLanguage,
    this.onLanguageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(const Radius.circular(8)),
        color: themeData.colorScheme.primary,
        border: Border.all(color: Colors.white, width: 1,),
      ),
      child: PopupMenuButton<String>(
        onSelected: onLanguageSelected,
        tooltip: "Select Language",
        initialValue: selectedLanguage,
        itemBuilder: (BuildContext context) {
          List<PopupMenuItem<String>> list = LanguagesType.languages.map((e) {
            return PopupMenuItem<String>(
              value: e,
              height: 36,
              child: Text(
                e,
                style: themeData.textTheme.bodyText2?.copyWith(
                  color: themeData.colorScheme.primary,
                ),
              ),
            );
          }).toList();

          return list;
        },
        position: PopupMenuPosition.under,
        color: themeData.colorScheme.onPrimary,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8,),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.language,
                size: 20,
                color: themeData.colorScheme.onPrimary,
              ),
              const SizedBox(width: 10,),
              Text(
                (selectedLanguage?.isNotEmpty ?? false) ? selectedLanguage! : "Select Language",
                style: themeData.textTheme.caption?.copyWith(
                  color: themeData.colorScheme.onPrimary,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.keyboard_arrow_down_outlined,
                  size: 22,
                  color: themeData.colorScheme.onPrimary,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}