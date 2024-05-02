import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import '../../../../../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourseProvider extends StatelessWidget {
  final Map<String, dynamic> courseDetails;
  CourseProvider({
    Key key,
    @required this.courseDetails,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return courseDetails["source"] != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).mStaticProviders,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    margin: EdgeInsets.only(right: 16),
                    padding: EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.grey16, width: 1),
                        borderRadius:
                            BorderRadius.all(const Radius.circular(4.0))),
                    child: courseDetails["creatorLogo"] != null
                        ? Image.network(Helper.convertImageUrl(
                            courseDetails["creatorLogo"]))
                        : Image.asset(
                            'assets/img/karmayogi_bharat_symbol.png',
                            fit: BoxFit.contain,
                          ),
                  ),
                  Expanded(
                    child: Text(
                      'By ' + courseDetails["source"],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                        color: AppColors.greys60,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : SizedBox();
  }
}
        // Row(
        //   children: [
        //     (course.creatorIcon != null && !isFeatured)
        //         ? Container(
        //             margin: EdgeInsets.only(left: 16, top: 8),
        //             decoration: BoxDecoration(
        //                 color: Colors.white,
        //                 border: Border.all(color: AppColors.grey16, width: 1),
        //                 borderRadius:
        //                     BorderRadius.all(const Radius.circular(4.0))),
        //             child: Container(
        //               height: 16,
        //               width: 17,
        //               margin: EdgeInsets.all(8),
        //               decoration: BoxDecoration(
        //                 image: DecorationImage(
        //                     image: NetworkImage(course.creatorIcon),
        //                     fit: BoxFit.fitWidth),
        //               ),
        //             ),
        //           )
        //         : !isFeatured
        //             ? Container(
        //                 margin: EdgeInsets.only(left: 16, top: 6),
        //                 decoration: BoxDecoration(
        //                     color: Colors.white,
        //                     border:
        //                         Border.all(color: AppColors.grey16, width: 1),
        //                     borderRadius:
        //                         BorderRadius.all(const Radius.circular(4.0))),
        //                 child: Container(
        //                   height: 16,
        //                   width: 17,
        //                   margin: EdgeInsets.all(4),
        //                   decoration: BoxDecoration(
        //                     image: DecorationImage(
        //                       image: course.creatorLogo != ''
        //                           ? NetworkImage(course.creatorLogo)
        //                           : AssetImage(
        //                               'assets/img/igot_creator_icon.png'),
        //                     ),
        //                   ),
        //                 ),
        //               )
        //             : Center(),
        //     Expanded(
        //       child: Container(
        //         alignment: Alignment.topLeft,
        //         padding: EdgeInsets.only(left: 16, right: 16),
        //         child: Text(
        //           course.source != null
        //               ? course.source != ''
        //                   ? 'By ' + course.source
        //                   : ''
        //               : '',
        //           maxLines: 1,
        //           overflow: TextOverflow.ellipsis,
        //           style: GoogleFonts.lato(
        //             color: AppColors.greys60,
        //             fontWeight: FontWeight.w400,
        //             fontSize: 12.0,
        //             height: 1.5,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),