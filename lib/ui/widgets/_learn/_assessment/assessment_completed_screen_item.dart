import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import './../../../../feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssessmentCompletedScreenItem extends StatefulWidget {
  const AssessmentCompletedScreenItem({
    Key key,
    @required this.itemIndex,
    this.apiResponse,
    this.color,
    this.type,
    this.title,
  }) : super(key: key);

  final int itemIndex;
  final Map apiResponse;
  final Color color;
  final String type;
  final String title;

  @override
  State<AssessmentCompletedScreenItem> createState() =>
      _AssessmentCompletedScreenItemState();
}

class _AssessmentCompletedScreenItemState
    extends State<AssessmentCompletedScreenItem> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
          color: expanded ? widget.color.withOpacity(0.05) : AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.grey04),
            bottom: BorderSide(color: AppColors.grey04),
            left: expanded
                ? BorderSide(color: widget.color, width: 4)
                : BorderSide(color: AppColors.white, width: 0),
          )),
      child: ExpansionTile(
        title: Row(
          children: [
            if (widget.type.toString() == 'correct')
              Icon(Icons.done, size: 20, color: AppColors.primaryBlue),
            if (widget.type.toString() == 'incorrect')
              SvgPicture.asset(
                'assets/img/close_black.svg',
                color: AppColors.primaryBlue,
              ),
            if (widget.type.toString() == 'blank')
              SvgPicture.asset(
                'assets/img/unanswered.svg',
                color: AppColors.primaryBlue,
              ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                widget.title,
                style: GoogleFonts.lato(
                  color: FeedbackColors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        onExpansionChanged: (value) {
          setState(() {
            expanded = value;
          });
        },
        trailing: Icon(
          expanded ? Icons.remove : Icons.add,
          color: AppColors.darkBlue,
          size: 20,
        ),
        children: [
          for (var k = 0;
              k <
                  widget.apiResponse['children'][widget.itemIndex]['children']
                      .length;
              k++)
            widget.apiResponse['children'][widget.itemIndex]['children'][k]
                        ['result'] ==
                    widget.type
                ? QuestionItem(
                    quetion: widget.apiResponse['children'][widget.itemIndex]
                        ['children'][k]['question'],
                    quetionIndex: k + 1,
                  )
                : Container()
        ],
      ),
    );
  }
}

class QuestionItem extends StatefulWidget {
  const QuestionItem({
    Key key,
    @required this.quetion,
    @required this.quetionIndex,
  }) : super(key: key);

  final int quetionIndex;
  final String quetion;

  @override
  State<QuestionItem> createState() => _QuestionItemState();
}

class _QuestionItemState extends State<QuestionItem> {
  bool expanded = true;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left: 4, right: 4, bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              expandedAlignment: Alignment.centerLeft,
              onExpansionChanged: (value) {
                setState(() {
                  expanded = !value;
                });
              },
              trailing: Icon(
                expanded ? Icons.add : Icons.remove,
                color: AppColors.darkBlue,
                size: 20,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    widget.quetion,
                    style: GoogleFonts.lato(
                        decoration: TextDecoration.none,
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
              title: Text(
                '${AppLocalizations.of(context).mStaticQuestion} ${widget.quetionIndex}',
                style: GoogleFonts.lato(
                    decoration: TextDecoration.none,
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ));
  }
}
