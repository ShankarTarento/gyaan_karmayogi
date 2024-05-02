import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../constants/_constants/color_constants.dart';

class Tags extends StatefulWidget {
  final List<dynamic> keywords;
  const Tags({Key key, @required this.keywords}) : super(key: key);

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).mStaticTags,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        widget.keywords.isNotEmpty
            ? ExtendedWrap(
                minLines: 2,
                maxLines: isExpanded ? 10 : 2,
                overflowWidget: GestureDetector(
                  onTap: () {
                    isExpanded = isExpanded ? false : true;
                    setState(() {});
                  },
                  child: Text(
                    isExpanded
                        ? AppLocalizations.of(context).mStaticViewLess
                        : AppLocalizations.of(context).mStaticViewMore,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff1B4CA1),
                      height: 1.3,
                      decorationThickness: 1.0,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                runSpacing: 8,
                spacing: 0,
                alignment: WrapAlignment.start,
                children: widget.keywords
                    .map(
                      (e) => Container(
                        padding: EdgeInsets.all(1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              e,
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: Color(0xff000000).withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: widget.keywords.indexOf(e) !=
                                      widget.keywords.length - 1
                                  ? CircleAvatar(
                                      backgroundColor: AppColors.grey40,
                                      radius: 1,
                                    )
                                  : SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              )
            : Text(
                AppLocalizations.of(context).mProfileNoTags,
                style: GoogleFonts.lato(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff000000).withOpacity(0.60)),
              )
      ],
    );
  }
}
