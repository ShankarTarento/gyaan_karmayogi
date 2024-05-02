import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/flag_classifications.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/models/_models/flag_classification_model.dart';
import 'package:karmayogi_mobile/services/_services/report_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/content_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/_constants/color_constants.dart';

class ReportItem extends StatefulWidget {
  final String contextType;
  final String contextTypeId;
  final String userId;
  final updateReportStatus;

  const ReportItem(
      {Key key,
      this.contextType,
      this.contextTypeId,
      this.updateReportStatus,
      this.userId})
      : super(key: key);

  @override
  State<ReportItem> createState() => _ReportItemState();
}

class _ReportItemState extends State<ReportItem> {
  String _reportMessage;
  List<FlagClassificationItem> _reportReasons = [];
  final _textController = TextEditingController();
  bool _isReportUser = false;
  bool _isReasonEmpty = false;

  ReportService reportService = ReportService();
  _reportContent(String reason) async {
    final response = await reportService.createFlag(
        _isReportUser ? 'user' : widget.contextType,
        _isReportUser ? widget.userId : widget.contextTypeId,
        reason);
    if (response.runtimeType != int &&
        (response['params']['errmsg'] == null ||
            response['params']['errmsg'] == '')) {
      widget.updateReportStatus();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).mDiscussThanksForLettingUsKnow),
          backgroundColor: AppColors.positiveLight,
        ),
      );
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).mStaticErrorMessage),
          backgroundColor: AppColors.negativeLight,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _reportReasons = FLAG_CLASSIFICATIONS(context: context);
    _reportMessage = _reportReasons[0].type;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    height: 6,
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                      color: AppColors.grey16,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                ),
                Text(
                  "${AppLocalizations.of(context).mDiscussReportThis} ${!_isReportUser ? AppLocalizations.of(context).mDiscussPost : AppLocalizations.of(context).mDiscussUser}",
                  style: GoogleFonts.lato(
                      fontSize: 18,
                      color: AppColors.greys87,
                      fontWeight: FontWeight.w600),
                ),
                Divider(
                  color: AppColors.grey08,
                  height: 30,
                  thickness: 1,
                ),
                Text(
                  "${AppLocalizations.of(context).mDiscussWhyAreYouReporting}?",
                  style: GoogleFonts.lato(
                      fontSize: 16,
                      color: AppColors.greys60,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 12,
                ),
                !(_reportMessage ==
                        _reportReasons[_reportReasons.length - 1].type)
                    ? ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _reportReasons.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return RadioListTile(
                            activeColor: AppColors.primaryThree,
                            visualDensity:
                                VisualDensity(horizontal: -1, vertical: -1),
                            contentPadding: EdgeInsets.all(0),
                            title: Text(_reportReasons[index].type),
                            value: _reportReasons[index].type,
                            groupValue: _reportMessage,
                            secondary: _reportReasons.elementAt(index).type ==
                                    _reportMessage
                                ? ContentInfo(
                                    infoMessage: _reportReasons
                                        .elementAt(index)
                                        .description,
                                    isReport: true,
                                  )
                                : Text(''),
                            onChanged: (value) {
                              setState(() {
                                _reportMessage = value;
                              });
                            },
                            selected: _reportReasons.elementAt(index).type ==
                                _reportMessage,
                          );
                        })
                    : Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _reportMessage = _reportReasons[0].type;
                                  });
                                },
                                child: Icon(Icons.close)),
                          ),
                          TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)
                                    .mCommonTypeHere),
                          ),
                          Visibility(
                            visible:
                                _isReasonEmpty && _textController.text.isEmpty,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .mDiscussPleaseTypeReason,
                                  style: GoogleFonts.lato(
                                      color: AppColors.negativeLight),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.307,
                          )
                        ],
                      ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        _isReportUser = !_isReportUser;
                      });
                    },
                    child: Text(
                        '${AppLocalizations.of(context).mDiscussionReport} ${!_isReportUser ? AppLocalizations.of(context).mDiscussUser : AppLocalizations.of(context).mDiscussPost} ')),
                Container(
                  width: 87,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: AppColors.primaryThree,
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: () async {
                      if (_reportMessage ==
                              _reportReasons[_reportReasons.length - 1].type &&
                          _textController.text.isEmpty) {
                        setState(() {
                          _isReasonEmpty = true;
                        });
                      } else {
                        await _reportContent(_reportMessage !=
                                _reportReasons[_reportReasons.length - 1].type
                            ? _reportMessage
                            : _textController.text);
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context).mStaticSubmit,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
