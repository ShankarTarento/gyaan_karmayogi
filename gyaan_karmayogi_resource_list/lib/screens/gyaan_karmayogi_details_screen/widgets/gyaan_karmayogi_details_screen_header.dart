import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data_models/gyaan_karmayogi_resource_details.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/constants.dart';
import '../../../utils/helper.dart';

class GyaanKarmayogiDetailsScreenHeader extends StatelessWidget {
  final ResourceDetails resourceDetails;
  final Map<String, dynamic> translatedWords;

  const GyaanKarmayogiDetailsScreenHeader({
    Key key,
    @required this.resourceDetails,
    @required this.translatedWords,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff3A83CF), Color(0xff1B4CA1)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(
          //   height: 8,
          // ),
          Row(
            children: [
              resourceDetails.sectorName != null
                  ? Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 4, bottom: 4),
                      decoration: BoxDecoration(
                          color: AppColors.greys60,
                          border: Border.all(color: AppColors.primaryOne),
                          borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          // Icon(
                          //   Icons.stop,
                          //   color: AppColors.primaryOne,
                          //   size: 16,
                          // ),
                          // SizedBox(
                          //   width: 3,
                          // ),
                          Text(
                            resourceDetails.sectorName,
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: AppColors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    )
                  : const SizedBox(),
              resourceDetails.subSectorName != null
                  ? Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 4, bottom: 4),
                      decoration: BoxDecoration(
                          color: AppColors.greys60,
                          border: Border.all(color: AppColors.primaryOne),
                          borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          // Icon(
                          //   Icons.stop,
                          //   color: AppColors.primaryOne,
                          //   size: 16,
                          // ),
                          // SizedBox(
                          //   width: 3,
                          // ),
                          Text(
                            resourceDetails.subSectorName,
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: AppColors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    )
                  : const SizedBox()
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            resourceDetails.name,
            style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.white),
          ),
          const SizedBox(
            height: 8,
          ),
          resourceDetails.creatorContacts != null
              ? Text(
                  "${translatedWords["by"]} ${resourceDetails.creatorContacts[0].name}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white),
                )
              : const SizedBox(),
          const SizedBox(
            height: 16,
          ),
          Text(
            "${translatedWords["publishedOn"]} ${Helper.getDateTimeInFormat(dateTime: resourceDetails.lastPublishedOn, desiredDateFormat: Constants.dateFormat2)}",
            style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.white),
          ),
          const SizedBox(
            height: 16,
          ),
          Wrap(
            runAlignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            alignment: WrapAlignment.start,

            runSpacing: 20,
            spacing: 16,
            children: [
              titleSubtitle(
                  context: context,
                  title: translatedWords["sector"] ?? "Sector",
                  subtitle: resourceDetails.sectorName ?? "-"),
              titleSubtitle(
                  context: context,
                  title: translatedWords["subSector"] ?? "Sub-Sector",
                  subtitle: resourceDetails.subSectorName ?? "-"),
              titleSubtitle(
                  context: context,
                  title: translatedWords["category"] ?? "Category",
                  subtitle: resourceDetails.resourceCategory ?? "-"),
              titleSubtitle(
                  context: context,
                  title: translatedWords["resourceType"] ?? "Resource type",
                  subtitle: resourceType() ?? "-")
            ],
            //  List.generate(5, (index) => titleSubtitle(context: context)),
          )
        ],
      ),
    );
  }

  String resourceType() {
    if (resourceDetails.mimeType == EMimeTypes.youtubeLink ||
        resourceDetails.mimeType == EMimeTypes.externalLink) {
      return "Youtube";
    } else if (resourceDetails.mimeType == EMimeTypes.mp4) {
      return "Video";
    } else if (resourceDetails.mimeType == EMimeTypes.mp3) {
      return "Audio";
    } else {
      return "PDF";
    }
  }

  Widget titleSubtitle(
      {@required BuildContext context,
      @required String title,
      @required String subtitle}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.white),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.white),
          )
        ],
      ),
    );
  }
}
