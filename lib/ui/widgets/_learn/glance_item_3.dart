import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GlanceItem3 extends StatefulWidget {
  final String icon;
  final String text;
  final int status;
  final bool isModule, isEnrolled;
  final bool showContent = true;
  final String contentType;
  final String duration, mimeType;
  final bool isFeaturedCourse;
  final currentProgress;
  final bool showProgress, isExpanded, isLastAccessed;
  final String maxQuestions;

  const GlanceItem3(
      {Key key,
      this.icon,
      this.text,
      this.status,
      this.isModule,
      this.contentType,
      this.duration,
      this.isFeaturedCourse = false,
      this.currentProgress,
      this.showProgress = false,
      this.isExpanded = false,
      this.isLastAccessed = false,
      this.isEnrolled = false,
      this.maxQuestions = '',
      this.mimeType = ''})
      : super(key: key);

  @override
  _GlanceItem3State createState() => _GlanceItem3State();
}

class _GlanceItem3State extends State<GlanceItem3> {
// class GlanceItem3 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: widget.isLastAccessed && widget.showProgress
          ? AppColors.darkBlue
          : widget.isExpanded
              ? AppColors.whiteGradientOne
              : AppColors.appBarBackground,
      // height: 74,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          (!widget.isFeaturedCourse && widget.showProgress)
              ? Padding(
                  padding: const EdgeInsets.only(left: 5, top: 10),
                  child: (widget.status == 2)
                      ? Icon(
                          widget.isLastAccessed && widget.showProgress
                              ? Icons.check_circle_outline
                              : Icons.check_circle,
                          size: 22,
                          color: widget.isLastAccessed && widget.showProgress
                              ? AppColors.appBarBackground
                              : AppColors.darkBlue)
                      : Padding(
                          padding: const EdgeInsets.only(top: 4, right: 0),
                          child: widget.showProgress
                              ? Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      backgroundColor: AppColors.grey16,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ((widget.currentProgress != null &&
                                                    widget.currentProgress !=
                                                        '') &&
                                                double.parse(widget
                                                        .currentProgress
                                                        .toString()) <
                                                    1)
                                            ? AppColors.primaryOne
                                            : widget.isLastAccessed &&
                                                    widget.showProgress
                                                ? AppColors.appBarBackground
                                                : AppColors.darkBlue,
                                      ),
                                      strokeWidth: 3,
                                      value: (widget.currentProgress != null &&
                                              widget.currentProgress != '')
                                          ? double.parse(
                                              widget.currentProgress.toString())
                                          : 0.0),
                                )
                              : Center(),
                        ),
                )
              : Center(),
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            padding: const EdgeInsets.only(left: 8, top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style: GoogleFonts.lato(
                      height: 1.5,
                      decoration: TextDecoration.none,
                      color: widget.isLastAccessed && widget.showProgress
                          ? AppColors.appBarBackground
                          : AppColors.greys87,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SvgPicture.asset(
                        widget.icon,
                        color: widget.isLastAccessed && widget.showProgress
                            ? AppColors.appBarBackground
                            : widget.icon == "assets/img/audio.svg"
                                ? AppColors.grey40
                                : AppColors.greys87,
                        height: 16,
                        width: 16,
                        // alignment: Alignment.topLeft,
                      ),
                      (widget.duration != null &&
                              !(widget.mimeType == EMimeTypes.assessment ||
                                  widget.mimeType == EMimeTypes.newAssessment))
                          ? Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                widget.duration,
                                style: GoogleFonts.lato(
                                    height: 1.5,
                                    decoration: TextDecoration.none,
                                    color: widget.isLastAccessed &&
                                            widget.showProgress
                                        ? AppColors.appBarBackground
                                        : AppColors.greys60,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            )
                          : Center(),
                      if (widget.maxQuestions != null &&
                          widget.maxQuestions != '' &&
                          (widget.mimeType == EMimeTypes.assessment ||
                              widget.mimeType == EMimeTypes.newAssessment))
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '${widget.maxQuestions} ${(widget.maxQuestions == 1) ? AppLocalizations.of(context).mStaticQuestion.toString().toLowerCase() : AppLocalizations.of(context).mStaticQuestions.toString().toLowerCase()}',
                            style: GoogleFonts.lato(
                                height: 1.5,
                                decoration: TextDecoration.none,
                                color:
                                    widget.isLastAccessed && widget.showProgress
                                        ? AppColors.appBarBackground
                                        : AppColors.greys60,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
