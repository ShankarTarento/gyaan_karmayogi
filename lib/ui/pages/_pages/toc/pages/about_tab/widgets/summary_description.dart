import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:google_fonts/google_fonts.dart';

class SummaryWidget extends StatefulWidget {
  final String title;
  final String details;

  const SummaryWidget({
    Key key,
    @required this.title,
    @required this.details,
  }) : super(key: key);

  @override
  State<SummaryWidget> createState() => _SummaryWidgetState();
}

class _SummaryWidgetState extends State<SummaryWidget> {
  bool isExpanded = false;
  int _maxLength = 150;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          widget.details,
          maxLines: isExpanded ? null : 3,
          style: GoogleFonts.lato(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: Color(0xff000000).withOpacity(0.60)),
        ),
        widget.details.length > _maxLength
            ? GestureDetector(
                onTap: () {
                  isExpanded = isExpanded ? false : true;
                  setState(() {});
                },
                child: Text(
                  isExpanded
                      ? AppLocalizations.of(context).mStaticViewLess
                      : "...${AppLocalizations.of(context).mStaticViewMore}",
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff1B4CA1),
                  ),
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
