import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/browse_competency_card_model.dart';
import './../../../constants/index.dart';

class CompetencyLevelDetailsCard extends StatelessWidget {
  final String text;
  final bool isWorkOrder;
  final bool isEvaluation;
  final bool isGap;
  final BrowseCompetencyCardModel profileCompetency;
  final bool isDesired;
  final bool isRecommended;

  CompetencyLevelDetailsCard(
      {this.text = 'Some text',
      this.isWorkOrder = false,
      this.isEvaluation = false,
      this.isGap = false,
      this.profileCompetency,
      this.isDesired = false,
      this.isRecommended = false});

  @override
  Widget build(BuildContext context) {
    _getCompetencyLevelValue() {
      if (profileCompetency.selfAttestedLevel != null &&
          profileCompetency.competencyCBPCompletionLevel != null) {
        if (profileCompetency.competencyCBPCompletionLevel <
            profileCompetency.selfAttestedLevel) {
          return profileCompetency.competencyCBPCompletionLevelValue;
        } else if (profileCompetency.competencyCBPCompletionLevel >
            profileCompetency.selfAttestedLevel) {
          return profileCompetency.competencySelfAttestedLevelValue;
        } else {
          return profileCompetency.competencySelfAttestedLevelValue;
        }
      } else if (profileCompetency.competencyCBPCompletionLevel != null &&
          profileCompetency.selfAttestedLevel == null) {
        return profileCompetency.competencyCBPCompletionLevelValue;
      } else if (profileCompetency.selfAttestedLevel != null &&
          profileCompetency.competencyCBPCompletionLevel == null) {
        return profileCompetency.competencySelfAttestedLevelValue != null
            ? profileCompetency.competencySelfAttestedLevelValue
            : 0;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(4.0),
          ),
        ),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.525,
                      child: Text(
                        profileCompetency != null
                            ? profileCompetency.name.toString().trim()
                            : 'Competency name',
                        style: GoogleFonts.lato(
                            height: 1.5,
                            decoration: TextDecoration.none,
                            color: AppColors.greys87,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    // Container(
                    //   width: MediaQuery.of(context).size.width * 0.25,
                    //   child: Text(
                    //     "Not enough data",
                    //     style: GoogleFonts.lato(
                    //         height: 1.5,
                    //         decoration: TextDecoration.none,
                    //         color: AppColors.greys60,
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.w400),
                    //   ),
                    // ),
                    Row(
                      children: [
                        (!isDesired && _getCompetencyLevelValue() != null) ||
                                (isDesired &&
                                    profileCompetency
                                            .competencySelfAttestedLevelValue !=
                                        null)
                            ? Container(
                                // width: MediaQuery.of(context).size.width *
                                //     0.2,
                                // alignment: Alignment.topRight,
                                padding:
                                    const EdgeInsets.only(left: 12, bottom: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      alignment: Alignment.topRight,
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: Text(
                                        profileCompetency
                                            .competencySelfAttestedLevelValue
                                            .toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        // !isDesired
                                        //     ? _getCompetencyLevelValue()
                                        //     : profileCompetency
                                        //         .competencySelfAttestedLevelValue,
                                        style: GoogleFonts.lato(
                                            height: 1.5,
                                            decoration: TextDecoration.none,
                                            color: AppColors.greys87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    // (!isDesired &&
                                    //         profileCompetency
                                    //                 .selfAttestedLevel ==
                                    //             profileCompetency
                                    //                 .competencyCBPCompletionLevel)
                                    //     ? Padding(
                                    //         padding:
                                    //             const EdgeInsets.only(left: 8),
                                    //         child: Icon(
                                    //           Icons.check_circle,
                                    //           color: AppColors.positiveLight,
                                    //           size: 20,
                                    //         ),
                                    //       )
                                    //     : Center()
                                  ],
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                alignment: Alignment.topRight,
                                child: Text(
                                  "Not enough data",
                                  style: GoogleFonts.lato(
                                      height: 1.5,
                                      decoration: TextDecoration.none,
                                      color: AppColors.greys60,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                      ],
                    )
                  ],
                ),
                profileCompetency.competencyType != null
                    ? Row(
                        children: [
                          Container(
                            child: Text(
                              profileCompetency.competencyType,
                              style: GoogleFonts.lato(
                                  height: 1.5,
                                  decoration: TextDecoration.none,
                                  color: AppColors.greys87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      )
                    : Center(),
                ((profileCompetency.competencySelfAttestedLevelName != null ||
                            profileCompetency
                                    .competencyCBPCompletionLevelValue !=
                                null) ||
                        isDesired)
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 8),
                        child: Divider(
                          thickness: 1,
                          color: AppColors.grey16,
                        ),
                      )
                    : Center(),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       "Recommended level",
                //       style: GoogleFonts.lato(
                //           height: 1.5,
                //           decoration: TextDecoration.none,
                //           color: AppColors.greys87,
                //           fontSize: 12,
                //           fontWeight: FontWeight.w400),
                //     ),
                //     Row(
                //       children: [
                //         Container(
                //           height: 6,
                //           width: 12,
                //           decoration: BoxDecoration(
                //             color: AppColors.primaryThree,
                //             borderRadius: BorderRadius.all(
                //               Radius.circular(3.0),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 3),
                //           child: Container(
                //             height: 6,
                //             width: 12,
                //             decoration: BoxDecoration(
                //               color: AppColors.primaryThree,
                //               borderRadius: BorderRadius.all(
                //                 Radius.circular(3.0),
                //               ),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 3),
                //           child: Container(
                //             height: 6,
                //             width: 12,
                //             decoration: BoxDecoration(
                //               color: AppColors.primaryThree,
                //               borderRadius: BorderRadius.all(
                //                 Radius.circular(3.0),
                //               ),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 3),
                //           child: Container(
                //             height: 6,
                //             width: 12,
                //             decoration: BoxDecoration(
                //               color: AppColors.grey08,
                //               borderRadius: BorderRadius.all(
                //                 Radius.circular(3.0),
                //               ),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 3),
                //           child: Container(
                //             height: 6,
                //             width: 12,
                //             decoration: BoxDecoration(
                //               color: AppColors.grey08,
                //               borderRadius: BorderRadius.all(
                //                 Radius.circular(3.0),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       "PIAA",
                //       style: GoogleFonts.lato(
                //           height: 1.5,
                //           decoration: TextDecoration.none,
                //           color: AppColors.greys87,
                //           fontSize: 12,
                //           fontWeight: FontWeight.w400),
                //     ),
                //     Row(
                //       children: [
                //         Container(
                //           height: 6,
                //           width: 12,
                //           decoration: BoxDecoration(
                //             color: AppColors.positiveLight,
                //             borderRadius: BorderRadius.all(
                //               Radius.circular(3.0),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 3),
                //           child: Container(
                //             height: 6,
                //             width: 12,
                //             decoration: BoxDecoration(
                //               color: AppColors.positiveLight,
                //               borderRadius: BorderRadius.all(
                //                 Radius.circular(3.0),
                //               ),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 3),
                //           child: Container(
                //             height: 6,
                //             width: 12,
                //             decoration: BoxDecoration(
                //                 color: Colors.white,
                //                 borderRadius: BorderRadius.all(
                //                   Radius.circular(3.0),
                //                 ),
                //                 border: Border.all(
                //                     color: Colors.redAccent, width: 1.5)),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 3),
                //           child: Container(
                //             height: 6,
                //             width: 12,
                //             decoration: BoxDecoration(
                //               color: AppColors.grey08,
                //               borderRadius: BorderRadius.all(
                //                 Radius.circular(3.0),
                //               ),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 3),
                //           child: Container(
                //             height: 6,
                //             width: 12,
                //             decoration: BoxDecoration(
                //               color: AppColors.grey08,
                //               borderRadius: BorderRadius.all(
                //                 Radius.circular(3.0),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       "WPCASS",
                //       style: GoogleFonts.lato(
                //           height: 1.5,
                //           decoration: TextDecoration.none,
                //           color: AppColors.greys87,
                //           fontSize: 12,
                //           fontWeight: FontWeight.w400),
                //     ),
                //     Row(
                //       children: [
                //         Container(
                //           height: 6,
                //           width: 12,
                //           decoration: BoxDecoration(
                //             color: AppColors.positiveLight,
                //             borderRadius: BorderRadius.all(
                //               Radius.circular(3.0),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 3),
                //           child: Container(
                //             height: 6,
                //             width: 12,
                //             decoration: BoxDecoration(
                //               color: AppColors.positiveLight,
                //               borderRadius: BorderRadius.all(
                //                 Radius.circular(3.0),
                //               ),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 3),
                //           child: Container(
                //             height: 6,
                //             width: 12,
                //             decoration: BoxDecoration(
                //                 color: Colors.white,
                //                 borderRadius: BorderRadius.all(
                //                   Radius.circular(3.0),
                //                 ),
                //                 border: Border.all(
                //                     color: Colors.redAccent, width: 1.5)),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 3),
                //           child: Container(
                //             height: 6,
                //             width: 12,
                //             decoration: BoxDecoration(
                //               color: AppColors.grey08,
                //               borderRadius: BorderRadius.all(
                //                 Radius.circular(3.0),
                //               ),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 3),
                //           child: Container(
                //             height: 6,
                //             width: 12,
                //             decoration: BoxDecoration(
                //               color: AppColors.grey08,
                //               borderRadius: BorderRadius.all(
                //                 Radius.circular(3.0),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
                // (!isDesired && !isRecommended)
                //     ? Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(
                //             "CBP course",
                //             style: GoogleFonts.lato(
                //                 height: 1.5,
                //                 decoration: TextDecoration.none,
                //                 color: AppColors.greys87,
                //                 fontSize: 12,
                //                 fontWeight: FontWeight.w400),
                //           ),
                //           Row(
                //             children: [
                //               for (var i = 0;
                //                   i <
                //                       (profileCompetency
                //                                   .competencyCBPCompletionLevel !=
                //                               null
                //                           ? profileCompetency
                //                               .competencyCBPCompletionLevel
                //                           : 0);
                //                   i++)
                //                 Padding(
                //                   padding: const EdgeInsets.only(left: 3),
                //                   child: (Container(
                //                     height: 6,
                //                     width: 12,
                //                     decoration: BoxDecoration(
                //                       color: AppColors.positiveLight,
                //                       borderRadius: BorderRadius.all(
                //                         Radius.circular(1.0),
                //                       ),
                //                     ),
                //                   )),
                //                 ),
                //               for (var i = 0;
                //                   i <
                //                       (profileCompetency
                //                                   .competencyCBPCompletionLevel !=
                //                               null
                //                           ? (5 -
                //                               profileCompetency
                //                                   .competencyCBPCompletionLevel)
                //                           : 5);
                //                   i++)
                //                 (Padding(
                //                   padding: const EdgeInsets.only(left: 3),
                //                   child: Container(
                //                     height: 6,
                //                     width: 12,
                //                     decoration: BoxDecoration(
                //                       color: AppColors.grey08,
                //                       borderRadius: BorderRadius.all(
                //                         Radius.circular(1.0),
                //                       ),
                //                     ),
                //                   ),
                //                 ))
                //             ],
                //           ),
                //         ],
                //       )
                //     : Center(),
                !isRecommended
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Self attestation",
                            style: GoogleFonts.lato(
                                height: 1.5,
                                decoration: TextDecoration.none,
                                color: AppColors.greys87,
                                fontSize: 12,
                                fontWeight: FontWeight.w400),
                          ),
                          Row(
                            children: [
                              for (var i = 0;
                                  i <
                                      (profileCompetency.selfAttestedLevel !=
                                              null
                                          ? profileCompetency.selfAttestedLevel
                                          : 0);
                                  i++)
                                (Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Container(
                                    height: 6,
                                    width: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.positiveLight,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(1.0),
                                      ),
                                    ),
                                  ),
                                )),
                              for (var i = 0;
                                  i <
                                      (profileCompetency.selfAttestedLevel !=
                                              null
                                          ? (5 -
                                              profileCompetency
                                                  .selfAttestedLevel)
                                          : 5);
                                  i++)
                                (Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Container(
                                    height: 6,
                                    width: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey08,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(1.0),
                                      ),
                                    ),
                                  ),
                                ))
                            ],
                          ),
                        ],
                      )
                    : Center()
              ],
            )),
      ),
    );
  }
}
