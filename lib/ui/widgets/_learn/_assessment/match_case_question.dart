import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:reorderables/reorderables.dart';
import 'package:widget_size/widget_size.dart';
import '../../_common/page_loader.dart';
import './../../../../constants/_constants/color_constants.dart';
import './../../../../feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MatchCaseQuestion extends StatefulWidget {
  final question;
  final String questionText;
  final List options;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final ValueChanged<Map> parentAction;
  final bool isNewAssessment;
  final String id;
  MatchCaseQuestion(this.question, this.questionText, this.options,
      this.currentIndex, this.answerGiven, this.showAnswer, this.parentAction,
      {this.isNewAssessment = false, this.id});
  @override
  _MatchCaseQuestionQuestionState createState() =>
      _MatchCaseQuestionQuestionState();
}

class _MatchCaseQuestionQuestionState extends State<MatchCaseQuestion> {
  // ScrollController _scrollController;
  // List<Widget> _rows;
  List _options = [];
  double _minHeight = 72;
  List<double> _heights = [];
  // dynamic _question;
  String _qId;
  int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _qId = widget.isNewAssessment ? widget.id : widget.question['questionId'];
    // _question = widget.question;
    for (int i = 0; i < widget.options.length; i++) {
      _heights.add(_minHeight);
    }
  }

  double _getHeight() {
    double height = 0;
    for (var i = 0; i < _heights.length; i++) {
      height = height + _heights[i];
    }
    return height;
  }

  void _onReorder(int oldIndex, int newIndex) {
    // print('$oldIndex, $newIndex');
    if (!widget.showAnswer) {
      final temp = _options[oldIndex];
      setState(() {
        _options[oldIndex] = _options[newIndex];
        _options[newIndex] = temp;
      });
      widget
          .parentAction({'index': _qId, 'isCorrect': true, 'value': _options});
    }
  }
  // triggerMode: TooltipTriggerMode.tap,
  //             message: widget.showAnswer
  //                 ? (widget.isNewAssessment
  //                     ? widget.question['options'][index]['answer']
  //                     : widget.question['options'][index]['match'])
  //                 : '',

  _getRows(ctx) {
    return List<Widget>.generate(
        widget.options.length,
        (int index) => InkWell(
              onLongPress: widget.showAnswer
                  ? () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      Future.delayed(
                          Duration(
                            seconds: 2,
                          ), () {
                        if (mounted) {
                          setState(() {
                            _selectedIndex = null;
                          });
                        }
                      });
                    }
                  : null,
              child: Container(
                width: double.infinity - 30,
                height: _heights[index],
                margin: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Label(
                      triangleHeight: 10.0,
                      edge: Edge.LEFT,
                      child: Container(
                          alignment: Alignment.centerLeft,
                          // height: MediaQuery.of(context).size.height - 30,
                          // width: double.infinity,
                          // height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width / 2 - 62,
                          height: _heights[index],
                          // margin: EdgeInsets.only(bottom: 10), update last
                          decoration: BoxDecoration(
                            color: widget.showAnswer &&
                                    (widget.isNewAssessment
                                            ? widget.question['options'][index]
                                                ['answer']
                                            : widget.question['options'][index]
                                                ['match']) !=
                                        _options[index]
                                ? FeedbackColors.negativeLightBg
                                : widget.showAnswer &&
                                        (widget.isNewAssessment
                                                ? widget.question['options']
                                                    [index]['answer']
                                                : widget.question['options']
                                                    [index]['match']) ==
                                            _options[index]
                                    ? FeedbackColors.positiveLightBg
                                    : FeedbackColors.background,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.grey08,
                                blurRadius: 6.0,
                                spreadRadius: 0,
                                offset: Offset(
                                  3,
                                  3,
                                ),
                              ),
                            ],
                            border: Border.all(
                                color: widget.showAnswer &&
                                        (widget.isNewAssessment
                                                ? widget.question['options']
                                                    [index]['answer']
                                                : widget.question['options']
                                                    [index]['match']) !=
                                            _options[index]
                                    ? FeedbackColors.negativeLight
                                    : widget.showAnswer &&
                                            (widget.isNewAssessment
                                                    ? widget.question['options']
                                                        [index]['answer']
                                                    : widget.question['options']
                                                        [index]['match']) ==
                                                _options[index]
                                        ? FeedbackColors.positiveLight
                                        : AppColors.grey08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: EdgeInsets.all(10),
                          // height: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              _selectedIndex != null && _selectedIndex == index
                                  ? ((widget.isNewAssessment
                                      ? widget.question['options'][index]
                                          ['answer']
                                      : widget.question['options'][index]
                                          ['match']))
                                  : _options[index],
                              style: GoogleFonts.lato(
                                  color: _selectedIndex == index
                                      ? FeedbackColors.positiveLight
                                      : FeedbackColors.black87),
                            ),
                          )),
                    ),
                    Container(
                      width: 40,
                      height: _heights[index],
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              right: BorderSide(
                                color: AppColors.grey08,
                              ),
                              left: BorderSide(
                                  color: AppColors.grey08, width: 0.5),
                              top: BorderSide(
                                color: AppColors.grey08,
                              ),
                              bottom: BorderSide(
                                color: AppColors.grey08,
                              ))
                          // borderRadius: BorderRadius.circular(4),
                          ),
                      child: Center(
                          child: Icon(
                        Icons.reorder,
                        color: AppColors.greys60,
                      )),
                    )
                  ],
                ),
              ),
            ));
  }

  // Make sure there is a scroll controller attached to the scroll view that contains ReorderableSliverList.
  // Otherwise an error will be thrown.

  @override
  Widget build(BuildContext context) {
    if (_qId !=
        (widget.isNewAssessment ? widget.id : widget.question['questionId'])) {
      // setState(() {
      _heights = [];
      for (int i = 0; i < widget.options.length; i++) {
        _heights.add(72);
      }
      _qId = widget.isNewAssessment ? widget.id : widget.question['questionId'];
      // });
    }
    _options = widget.options;

    ScrollController _scrollController = ScrollController();
    return SingleChildScrollView(
      child: widget.question['options'].length > 0
          ? Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: HtmlWidget(
                      widget.questionText != null
                          ? widget.questionText
                          : widget.question['question'],
                      textStyle: GoogleFonts.lato(
                          color: FeedbackColors.black87,
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0,
                          height: 1.5
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      AppLocalizations.of(context).mMatchCaseHoldANdDragItems,
                      style: GoogleFonts.lato(
                        color: FeedbackColors.black87,
                        fontWeight: FontWeight.w400,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Divider(
                        color: Colors.black,
                      )),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width / 2 - 26,
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _options.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin:
                                        EdgeInsets.only(bottom: 8, right: 4),
                                    child: Point(
                                        triangleHeight: 10.0,
                                        edge: Edge.RIGHT,
                                        child: WidgetSize(
                                            onChange: (Size size) {
                                              // print(size.height);
                                              setState(() {
                                                _heights[index] = size.height;
                                              });
                                            },
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                constraints: BoxConstraints(
                                                  minHeight: _minHeight,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.1),
                                                    border: Border(
                                                        left: BorderSide(
                                                          color:
                                                              AppColors.grey08,
                                                        ),
                                                        right: BorderSide(
                                                            color: AppColors
                                                                .avatarRed,
                                                            width: 0.5),
                                                        top: BorderSide(
                                                          color:
                                                              AppColors.grey08,
                                                        ),
                                                        bottom: BorderSide(
                                                          color:
                                                              AppColors.grey08,
                                                        ))),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    widget.isNewAssessment
                                                        ? widget.question[
                                                                    'options']
                                                                [index]['value']
                                                            ['body']
                                                        : widget.question[
                                                                'options']
                                                            [index]['text'],
                                                    style: GoogleFonts.lato(
                                                      color: FeedbackColors
                                                          .black87,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 13.0,
                                                    ),
                                                  ),
                                                )))),
                                  );

                                  // ]);
                                },
                              )),
                          Positioned(
                              right: 0,
                              child: Container(
                                height: _getHeight() + 40,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 22,
                                // constraints: BoxConstraints(minHeight: 200, maxHeight: 300),
                                // margin: EdgeInsets.only(top: 57),
                                child: CustomScrollView(
                                  physics: NeverScrollableScrollPhysics(),
                                  // A ScrollController must be included in CustomScrollView, otherwise
                                  // ReorderableSliverList wouldn't work
                                  controller: _scrollController,
                                  slivers: <Widget>[
                                    ReorderableSliverList(
                                      enabled: widget.showAnswer ? false : true,
                                      delegate:
                                          ReorderableSliverChildListDelegate(
                                              _getRows(context)),
                                      // or use ReorderableSliverChildBuilderDelegate if needed
                                      // delegate: ReorderableSliverChildBuilderDelegate(
                                      //   (BuildContext context, int index) => _rows[index],
                                      //   childCount: _rows.length
                                      // ),
                                      onReorder: _onReorder,
                                    )
                                  ],
                                ),
                              )),
                        ],
                      )),
                  widget.showAnswer
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                              AppLocalizations.of(context).mMatchCaseLongPressOnItems),
                        )
                      : Center(),
                  SizedBox(
                    height: 100,
                  )
                ],
              ))
          : PageLoader(),
    );
  }
}
