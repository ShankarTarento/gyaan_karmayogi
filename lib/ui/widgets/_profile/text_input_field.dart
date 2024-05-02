import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class TextInputField extends StatelessWidget {
  final String Function(String) validatorFuntion;
  final FocusNode focusNode;
  final Function() onTap;
  final void Function(String) onFieldSubmitted;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hintText;
  final bool readOnly;
  final bool isDate;
  final int maxLength;
  final Widget suffix;
  final int minLines;
  final int maxLines;
  final String counterText;
  final String initialValue;
  final Function(String) onChanged;

  const TextInputField(
      {Key key,
      this.validatorFuntion,
      this.focusNode,
      this.onFieldSubmitted,
      this.controller,
      this.keyboardType,
      this.hintText,
      this.onTap,
      this.readOnly = false,
      this.isDate = false,
      this.maxLength,
      this.suffix,
      this.minLines,
      this.maxLines,
      this.counterText,
      this.onChanged,
      this.initialValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: TextFormField(
          maxLength: maxLength,
          initialValue: initialValue,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validatorFuntion,
          focusNode: focusNode,
          onTap: onTap,
          onFieldSubmitted: onFieldSubmitted,
          controller: controller,
          style: GoogleFonts.lato(fontSize: 14.0),
          keyboardType: keyboardType,
          readOnly: readOnly,
          maxLines: maxLength,
          minLines: minLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: (readOnly && !isDate) ? AppColors.grey04 : Colors.white,
            contentPadding: EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0),
            border: const OutlineInputBorder(),
            disabledBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey16)),
            hintText: hintText,
            hintStyle: GoogleFonts.lato(
                color: AppColors.grey40,
                fontSize: 14.0,
                fontWeight: FontWeight.w400),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: (readOnly && !isDate)
                      ? AppColors.grey16
                      : AppColors.primaryThree,
                  width: 1.0),
            ),
            suffix: suffix != null ? suffix : SizedBox(),
            counterText: counterText,
          ),
        ),
      ),
    );
  }
}
