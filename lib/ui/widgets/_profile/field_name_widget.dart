import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class FieldNameWidget extends StatelessWidget {
  final bool isMandatory;
  final String fieldName;
  final bool isApproved;
  final bool isInReview;
  final bool isNeedsApproval;
  final bool isApprovalField;
  const FieldNameWidget(
      {Key key,
      this.isMandatory = false,
      this.fieldName,
      this.isApproved = false,
      this.isInReview = false,
      this.isNeedsApproval = false,
      this.isApprovalField = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          !isMandatory
              ? Text(
                  fieldName,
                  style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                )
              : RichText(
                  text: TextSpan(
                      text: fieldName,
                      style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                            text: ' *',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 16))
                      ]),
                ),
          isApprovalField
              ? SvgPicture.asset(
                  isApproved
                      ? 'assets/img/approved.svg'
                      : isInReview
                          ? 'assets/img/sent_for_approval.svg'
                          : 'assets/img/needs_approval.svg',
                  width: 22,
                  height: 22,
                )
              : SizedBox()
        ],
      ),
    );
  }
}
