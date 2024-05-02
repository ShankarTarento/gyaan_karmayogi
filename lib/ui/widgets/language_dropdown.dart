import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/landing_page.dart';
import 'package:karmayogi_mobile/respositories/_respositories/chatbot_repository.dart';
import 'package:provider/provider.dart';

class LanguageDropdown extends StatefulWidget {
  final bool isHomePage;
  LanguageDropdown({Key key, @required this.isHomePage}) : super(key: key);

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  @override
  void initState() {
    super.initState();
    _getLanguages();
  }

  List<dynamic> dropdownItems = [
    {"value": "en", "viewValue": "English"},
    {"value": "hi", "viewValue": "हिंदी"},
    // {"value": "ta", 'viewValue': "தமிழ்"},
    // {"value": "te", 'viewValue': "తెలుగు"},
    // {"value": "bn", 'viewValue': "বাংলা"},
    // {"value": "gu", 'viewValue': "ગુજરાતી"},
    // {"value": "kn", 'viewValue': "ಕನ್ನಡ"},
    // {"value": "ml", 'viewValue': "മലയാളം"},
    // {"value": "mr", 'viewValue': "मराठी"},
    // {"value": "or", 'viewValue': "ଓଡିଆ"},
    // {"value": "pa", 'viewValue': "ਪੰਜਾਬੀ"},
    // {"value": "as", 'viewValue': "অসমীয়া"},
  ];

  Map<String, dynamic> dropdownValue;

  _getLanguages() async {
    final _storage = FlutterSecureStorage();

    final String deviceLocale = Platform.localeName.split('_').first.toString();
    String selectedLanguage =
        await _storage.read(key: Storage.selectedAppLanguage);
    dynamic selected;

    if (selectedLanguage == null) {
      switch (deviceLocale) {
        case AppLocale.hindi:
          selected = {"value": "hi", "viewValue": "हिंदी"};
          break;

        case AppLocale.marathi:
          selected = {"value": "mr", 'viewValue': "मराठी"};
          break;

        case AppLocale.tamil:
          selected = {"value": "ta", 'viewValue': "தமிழ்"};
          break;

        case AppLocale.assamese:
          selected = {"value": "as", 'viewValue': "অসমীয়া"};
          break;

        case AppLocale.bengali:
          selected = {"value": "bn", 'viewValue': "বাংলা"};
          break;

        case AppLocale.telugu:
          selected = {"value": "te", 'viewValue': "తెలుగు"};
          break;

        case AppLocale.kannada:
          selected = {"value": "kn", 'viewValue': "ಕನ್ನಡ"};
          break;

        case AppLocale.malaylam:
          selected = {"value": "ml", 'viewValue': "മലയാളം"};
          break;

        case AppLocale.gujarati:
          selected = {"value": "gu", 'viewValue': "ગુજરાતી"};
          break;

        case AppLocale.oriya:
          selected = {"value": "or", 'viewValue': "ଓଡିଆ"};
          break;

        case AppLocale.punjabi:
          selected = {"value": "pa", 'viewValue': "ਪੰਜਾਬੀ"};
          break;

        default:
          selected = {"value": "en", "viewValue": "English"};
      }
    } else {
      print("selected language not null");
      print(selected);
      selected = jsonDecode(selectedLanguage);
    }
    if (dropdownItems.any((item) =>
        item["value"] == selected["value"] &&
        item["viewValue"] == selected["viewValue"])) {
      dropdownValue = dropdownItems.firstWhere((item) =>
          item["value"] == selected["value"] &&
          item["viewValue"] == selected["viewValue"]);
    } else {
      dropdownValue = dropdownItems[0];
    }
    setState(() {});

    return dropdownItems;
  }

  setLanguage(dynamic newValue) async {
    await Provider.of<ChatbotRepository>(context, listen: false)
        .setAppLanguageDropDownValue(newValue);

    await LandingPage().setLocale(
        context,
        Locale(
          newValue['value'],
        ));

    setState(() {
      dropdownValue = newValue;
    });
  }

  String selectedOption = '';
  @override
  Widget build(BuildContext context) {
    return widget.isHomePage
        ? iconDropdown()
        : SizedBox(
            height: 32,
            width: widget.isHomePage ? 134 : 126,
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<Map<String, dynamic>>(
                selectedItemBuilder: (context) => dropdownItems
                    .map((dynamic item) =>
                        DropdownMenuItem<Map<String, dynamic>>(
                            value: item,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/img/translate_icon2.svg',
                                  color: AppColors.greys87,
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  child: Text(
                                    item["viewValue"],
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )))
                    .toList(),
                isExpanded: true,
                items: dropdownItems
                    .map((dynamic item) =>
                        DropdownMenuItem<Map<String, dynamic>>(
                          value: item,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: dropdownValue == item
                                    ? Color(0xff1B4CA1)
                                    : Colors.transparent,
                                size: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: Text(
                                  item["viewValue"],
                                  style: dropdownValue == item
                                      ? GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xff1B4CA1),
                                        )
                                      : GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                value: dropdownValue,
                onChanged: (value) {
                  setState(() {
                    dropdownValue = value;
                    setLanguage(dropdownValue);
                  });
                },
                buttonStyleData: ButtonStyleData(
                  height: 50,
                  width: 135,
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(widget.isHomePage ? 14 : 4),
                    border: Border.all(
                      color: AppColors.grey16,
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.transparent),
                    ],
                  ),
                  elevation: 2,
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(
                    Icons.arrow_drop_down,
                  ),
                  iconSize: 14,
                  iconEnabledColor: Colors.black,
                  iconDisabledColor: Colors.black,
                ),
                dropdownStyleData: DropdownStyleData(
                  width: 135,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  offset: const Offset(0, -5),
                  scrollbarTheme: ScrollbarThemeData(
                    radius: const Radius.circular(40),
                    thickness: MaterialStateProperty.all(6),
                    thumbVisibility: MaterialStateProperty.all(true),
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(),
              ),
            ),
          );
  }

  Widget iconDropdown() {
    return DropdownButtonHideUnderline(
        child: DropdownButton2(
      customButton: SvgPicture.asset(
        'assets/img/translate_icon2.svg',
        color: AppColors.greys87,
        height: 24,
        width: 24,
        fit: BoxFit.fill,
      ),
      items: dropdownItems
          .map((dynamic item) => DropdownMenuItem<Map<String, dynamic>>(
                value: item,
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: dropdownValue == item
                          ? AppColors.darkBlue
                          : Colors.transparent,
                      size: 20,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Text(
                        item["viewValue"],
                        style: dropdownValue == item
                            ? GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff1B4CA1),
                              )
                            : GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
      value: dropdownValue,
      onChanged: (value) {
        setState(() {
          dropdownValue = value;
          setLanguage(dropdownValue);
        });
      },
      // buttonStyleData: ButtonStyleData(
      //   height: 50,
      //   width: 135,
      //   padding: const EdgeInsets.only(left: 14, right: 10),
      //   decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(widget.isHomePage ? 14 : 4),
      //     border: Border.all(
      //       color: AppColors.grey16,
      //     ),
      //     color: Colors.white,
      //     boxShadow: [
      //       BoxShadow(color: Colors.transparent),
      //     ],
      //   ),
      //   elevation: 2,
      // ),
      // iconStyleData: const IconStyleData(
      //   icon: Icon(
      //     Icons.arrow_drop_down,
      //   ),
      //   iconSize: 14,
      //   iconEnabledColor: Colors.black,
      //   iconDisabledColor: Colors.black,
      // ),
      dropdownStyleData: DropdownStyleData(
        width: 135,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        offset: const Offset(0, -5),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(40),
          thickness: MaterialStateProperty.all(6),
          thumbVisibility: MaterialStateProperty.all(true),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(),
    ));
  }
}
