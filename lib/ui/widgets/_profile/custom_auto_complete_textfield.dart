import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomAutoCompleteTextField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final FocusNode focusNode;
  final Function(String) textSubmitted;
  static final GlobalKey<AutoCompleteTextFieldState<String>> motherTongueKey =
      GlobalKey();
  const CustomAutoCompleteTextField(
      {Key key,
      this.controller,
      this.suggestions,
      this.focusNode,
      this.textSubmitted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: SimpleAutoCompleteTextField(
          key: motherTongueKey,
          suggestions: suggestions,
          controller: controller,
          clearOnSubmit: false,
          focusNode: focusNode,
          textSubmitted: textSubmitted,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
            border: const OutlineInputBorder(),
            disabledBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey16)),
            hintText: AppLocalizations.of(context).mCommonTypeHere,
            hintStyle: GoogleFonts.lato(
                color: AppColors.grey40,
                fontSize: 14.0,
                fontWeight: FontWeight.w400),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryThree, width: 1.0),
            ),
          ),
        ),
      ),
    );
  }
}
