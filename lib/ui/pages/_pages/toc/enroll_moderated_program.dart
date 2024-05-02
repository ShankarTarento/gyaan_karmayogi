import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/select_batch_bottom_sheer.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/services/toc_services.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';

class EnrollModeratedProgram extends StatelessWidget {
  final Batch selectedBatch;
  final List<Batch> batches;
  final Function(BuildContext context) onEnrollPressed;
  const EnrollModeratedProgram(
      {Key key,
      @required this.selectedBatch,
      @required this.batches,
      @required this.onEnrollPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.secondaryShade1.withOpacity(0.2)),
        width: MediaQuery.of(context).size.width,
        child: Column(children: [
          Container(
            margin: EdgeInsets.only(bottom: selectedBatch != null ? 10 : 0),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.primaryOne)),
            width: MediaQuery.of(context).size.width,
            child: selectedBatch != null
                ? Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedBatch.name,
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
                              "${selectedBatch.name} - ${Helper.getDateTimeInFormat(selectedBatch.startDate, desiredDateFormat: IntentType.dateFormat2)} to  ${Helper.getDateTimeInFormat(selectedBatch.endDate, desiredDateFormat: IntentType.dateFormat2)}",
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                      Spacer(),
                      IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  side: BorderSide(
                                    color: AppColors.grey08,
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  return Consumer<TocServices>(
                                      builder: (context, tocServices, _) {
                                    return SelectBatchBottomSheet(
                                      batches: batches,
                                      batch: tocServices.batch,
                                    );
                                  });
                                });
                          },
                          icon: Icon(Icons.keyboard_arrow_down))
                    ],
                  )
                : Text(
                    'No open batches are available',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          selectedBatch != null
              ? Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Last enroll date",
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        Text(
                          selectedBatch != null
                              ? selectedBatch.enrollmentEndDate
                              : "",
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () => onEnrollPressed(context),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.primaryOne),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(63.0),
                          ),
                        ),
                      ),
                      child: Text(
                        "Enroll",
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(),
        ]),
      ),
    );
  }
}
