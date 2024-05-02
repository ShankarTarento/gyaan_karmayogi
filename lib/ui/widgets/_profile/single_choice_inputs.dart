import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class SingleChoiceInputs extends StatelessWidget {
  final int itemCount;
  final dynamic selected;
  final List<dynamic> choices;
  final Function(dynamic) onChanged;
  const SingleChoiceInputs(
      {Key key, this.itemCount, this.choices, this.selected, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(const Radius.circular(4.0)),
                border: Border.all(
                    color: (selected == choices[index])
                        ? AppColors.primaryThree
                        : AppColors.grey16,
                    width: 1.5),
              ),
              child: RadioListTile(
                dense: true,
                groupValue: selected,
                title: Text(
                  choices[index],
                  style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400),
                ),
                value: choices[index],
                onChanged: onChanged,
                selected: (selected == choices[index]),
                selectedTileColor: AppColors.selectionBackgroundBlue,
              ),
            ),
          );
        },
      ),
    );
  }
}
