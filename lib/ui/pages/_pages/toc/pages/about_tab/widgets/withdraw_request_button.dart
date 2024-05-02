import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class WithdrawRequest extends StatefulWidget {
  final Batch selectedBatch;
  final Map<String, dynamic> courseDetails;
  final Function() withdrawFunction;
  const WithdrawRequest(
      {Key key, this.courseDetails, this.selectedBatch, this.withdrawFunction})
      : super(key: key);

  @override
  State<WithdrawRequest> createState() => _WithdrawRequestState();
}

class _WithdrawRequestState extends State<WithdrawRequest> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.secondaryShade1.withOpacity(0.2),
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(children: [
          Container(
            margin: EdgeInsets.only(bottom: 10, left: 16, right: 16, top: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.primaryOne)),
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.selectedBatch.name,
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      "${Helper.getDateTimeInFormat(widget.selectedBatch.startDate, desiredDateFormat: IntentType.dateFormat2)} to  ${Helper.getDateTimeInFormat(widget.selectedBatch.endDate, desiredDateFormat: IntentType.dateFormat2)}",
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                        side: BorderSide(
                          color: AppColors.grey08,
                        ),
                      ),
                      builder: (BuildContext context) {
                        return Container(
                            height: 220,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8))),
                            child: confirmWithdraw());
                      });
                },
                child: Text(
                  "Withdraw request",
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all<double>(0),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(63.0),
                        side: BorderSide(color: AppColors.darkBlue)),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget confirmWithdraw() {
    return Container(
      padding: EdgeInsets.only(top: 24, bottom: 24, left: 16, right: 16),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Text(
            "Are you sure you want to withdraw your request?",
            style: GoogleFonts.montserrat(
                fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "You will miss the learning opportunity if you withdraw your enrollment",
            style: GoogleFonts.lato(fontSize: 14, height: 1.5),
          ),
          SizedBox(
            height: 24,
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => {
                      //   widget.enrollParentAction('Cancel'),
                      Navigator.of(context).pop(true)
                    },
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double>(0),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                              side: BorderSide(
                                  color: AppColors.darkBlue, width: 1.5))),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          AppColors.appBarBackground),
                    ),
                    // padding: EdgeInsets.all(15.0),
                    child: Text(
                      EnglishLang.cancel,
                      style: GoogleFonts.lato(
                        color: AppColors.darkBlue,
                        fontSize: 14.0,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      //   widget.enrollParentAction('Cancel'),
                      //  Navigator.of(context).pop(true)
                      widget.withdrawFunction();
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double>(0),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      )),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(AppColors.darkBlue),
                    ),
                    // padding: EdgeInsets.all(15.0),
                    child: Text(
                      "Confirm",
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 14.0,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
