import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';

class BlendedProgramLocation extends StatelessWidget {
  final Batch selectedBatch;
  const BlendedProgramLocation({Key key, @required this.selectedBatch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return selectedBatch.batchAttributes.batchLocationDetails != null
        ? Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.secondaryShade1.withOpacity(0.2)),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.darkBlue,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.4,
                      child: Text(
                        selectedBatch.batchAttributes.batchLocationDetails,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        : SizedBox();
  }
}
