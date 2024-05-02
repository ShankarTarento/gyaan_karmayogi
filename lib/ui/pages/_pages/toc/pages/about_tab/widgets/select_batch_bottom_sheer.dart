import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/services/toc_services.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';

class SelectBatchBottomSheet extends StatefulWidget {
  final List<Batch> batches;
  final Batch batch;
  const SelectBatchBottomSheet(
      {Key key, @required this.batches, @required this.batch})
      : super(key: key);

  @override
  State<SelectBatchBottomSheet> createState() => _SelectBatchBottomSheetState();
}

class _SelectBatchBottomSheetState extends State<SelectBatchBottomSheet> {
  @override
  void initState() {
    // TODO: implement initState
    selectedBatch = widget.batch;
    super.initState();
  }

  Batch selectedBatch;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 24, bottom: 24),
            width: 80,
            height: 8,
            decoration: BoxDecoration(
                color: AppColors.grey40,
                borderRadius: BorderRadius.circular(16)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Available Batches",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        Divider(
          color: AppColors.darkGrey,
          thickness: 1,
        ),
        widget.batches.isNotEmpty
            ? Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                        widget.batches.length,
                        (index) =>
                            DateTime.parse(widget.batches[index].startDate)
                                    .isAfter(DateTime.now())
                                ? GestureDetector(
                                    onTap: () {
                                      selectedBatch = widget.batches[index];
                                      setState(() {});
                                      Provider.of<TocServices>(context,
                                              listen: false)
                                          .setBatchDetails(
                                              selectedBatch: selectedBatch);
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12.0,
                                          bottom: 12,
                                          left: 16,
                                          right: 16),
                                      child: Text(
                                          "${widget.batches[index].name} - ${Helper.getDateTimeInFormat(widget.batches[index].startDate, desiredDateFormat: IntentType.dateFormat2)} to  ${Helper.getDateTimeInFormat(widget.batches[index].endDate, desiredDateFormat: IntentType.dateFormat2)}",
                                          style: selectedBatch ==
                                                  widget.batches[index]
                                              ? GoogleFonts.lato(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.darkBlue,
                                                  height: 1.5)
                                              : GoogleFonts.lato(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                  height: 1.5,
                                                )),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12.0,
                                        bottom: 12,
                                        left: 16,
                                        right: 16),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                "${widget.batches[index].name} - ${Helper.getDateTimeInFormat(widget.batches[index].startDate, desiredDateFormat: IntentType.dateFormat2)} to  ${Helper.getDateTimeInFormat(widget.batches[index].endDate, desiredDateFormat: IntentType.dateFormat2)}",
                                            style: GoogleFonts.lato(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.greys60,
                                              height: 1.5,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "  Expired",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                  ),
                ),
              )
            : Text("No batches found")
      ],
    );
  }
}
