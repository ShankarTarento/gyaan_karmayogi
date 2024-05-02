import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';

import '../../../../../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BlendedProgramDetails extends StatefulWidget {
  final Batch batch;

  BlendedProgramDetails({
    Key key,
    @required this.batch,
  }) : super(key: key);

  @override
  State<BlendedProgramDetails> createState() => _BlendedProgramDetailsState();
}

class _BlendedProgramDetailsState extends State<BlendedProgramDetails> {
  List countStatus;

  Batch batch;
  @override
  void initState() {
    batch = widget.batch;
    getCountStatus();
    super.initState();
  }

  @override
  void didUpdateWidget(BlendedProgramDetails oldWidget) {
    if (oldWidget.batch.batchId != widget.batch.batchId) {
      getCountStatus();
    }
    super.didUpdateWidget(oldWidget);
  }

  getCountStatus() async {
    countStatus =
        await LearnService().getBlendedProgramBatchCount(widget.batch.batchId);
    batch = widget.batch;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          detailsCard(
            count: batch != null ? batch.batchAttributes.currentBatchSize : "0",
            title:  AppLocalizations.of(context).mLearnBatchSize,
          ),
          detailsCard(
            count: countStatus != null && batch != null
                ? "${getTotal(count: countStatus)}"
                : "0",
            title: AppLocalizations.of(context).mCommonTotalApplied,
          ),
          detailsCard(
            count: getTotalEnrolled() != null && batch != null
                ? "${getTotalEnrolled()}"
                : "0",
            title: AppLocalizations.of(context).mLearnTotalEnrolled,
          ),
        ],
      ),
    );
  }

  int getTotal({@required List count}) {
    int total = 0;

    total = count.fold(total, (previousValue, element) {
      if (element["currentStatus"] != "WITHDRAWN") {
        return previousValue + element["statusCount"];
      } else {
        return previousValue;
      }
    });
    return total;
  }

  int getTotalEnrolled() {
    var approvedStatus;
    if (countStatus != null) {
      approvedStatus = countStatus.firstWhere(
          (element) => element["currentStatus"] == "APPROVED",
          orElse: () => null);
    }
    return approvedStatus != null ? approvedStatus["statusCount"] : null;
  }

  Widget detailsCard({@required String title, @required String count}) {
    return Container(
      height: 74,
      width: 84,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.darkBlueGradient8),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              count,
              style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryThree),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              title,
              style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greys60),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
            )
          ]),
    );
  }
}
