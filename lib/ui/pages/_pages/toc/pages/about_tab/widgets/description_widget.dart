import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' as html_parser;
import '../../../../../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DescriptionWidget extends StatefulWidget {
  final String title;
  final String details;
  final Map<String, dynamic> course;
  const DescriptionWidget({
    Key key,
    @required this.title,
    @required this.course,
    @required this.details,
  }) : super(
          key: key,
        );

  @override
  State<DescriptionWidget> createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<DescriptionWidget> {
  bool isExpanded = false;
  int _maxLength = 130;
  bool descriptionTrimText = true;
  String description;
  @override
  void initState() {
    description = html_parser.parse(widget.course['instructions']).body.text;
    // TODO: implement initState
    super.initState();
  }

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
        widget.course['instructions'] != null
            ? Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: HtmlWidget(
                  (descriptionTrimText && description.length > _maxLength)
                      ? description.substring(0, _maxLength - 1) + '...'
                      : widget.course['instructions'],
                  textStyle: GoogleFonts.lato(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.greys60,
                  ),
                ))
            : Center(),
        widget.course['instructions'] != null
            ? (widget.course['instructions'].length > _maxLength)
                ? Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: InkWell(
                        onTap: () => _toogleReadMore(),
                        child: Text(
                          !descriptionTrimText
                              ? AppLocalizations.of(context).mStaticViewLess
                              : "...${AppLocalizations.of(context).mStaticViewMore}",
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            height: 1.0,
                            fontWeight: FontWeight.w900,
                            color: Color(0xff1B4CA1),
                          ),
                        )))
                : Center()
            : Center()
      ],
    );
  }

  void _toogleReadMore({bool isSummary = false}) {
    setState(() {
      descriptionTrimText = !descriptionTrimText;
    });
  }
}
