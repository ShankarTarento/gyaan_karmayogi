import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReadOnlyField extends StatelessWidget {
  final String text;
  const ReadOnlyField({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      margin: EdgeInsets.all(8),
      message: text == null
          ? AppLocalizations.of(context).mehrmsFieldValueNotPresent
          : '',
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        margin: EdgeInsets.only(top: 6, bottom: 4),
        padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
            color: AppColors.grey08,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.grey16)),
        height: 48,
        width: double.infinity,
        child: Text(
            text != null
                ? text
                : AppLocalizations.of(context).mehrmsFieldValueNotPresent,
            style: GoogleFonts.lato(
              color: text != null ? AppColors.greys87 : AppColors.grey40,
            )),
      ),
    );
  }
}
