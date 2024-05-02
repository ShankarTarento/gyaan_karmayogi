import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/skeleton/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/field_name_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/form_field_section_heading.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/read_only_field.dart';
import 'package:karmayogi_mobile/util/ehrms_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EHrmsDetails extends StatelessWidget {
  const EHrmsDetails({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileRepository>(builder: (BuildContext context,
        ProfileRepository profileRepository, Widget child) {
      return profileRepository.ehrmsDetails != null
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal details section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: Image.network(
                              profileRepository.ehrmsDetails.profilePhoto,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return ContainerSkeleton(
                                  width: 100,
                                  height: 100,
                                  radius: 200,
                                );
                              },
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: EhrmsHelper.getPersonalDetails(
                                  context: context,
                                  ehrmsDetails: profileRepository.ehrmsDetails)
                              .length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                FieldNameWidget(
                                  fieldName: EhrmsHelper.getPersonalDetails(
                                          context: context,
                                          ehrmsDetails: profileRepository
                                              .ehrmsDetails)[index]
                                      .key,
                                ),
                                ReadOnlyField(
                                  text: EhrmsHelper.getPersonalDetails(
                                          context: context,
                                          ehrmsDetails: profileRepository
                                              .ehrmsDetails)[index]
                                      .value,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    height: 24,
                  ),
                  // Employee details section
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: EhrmsHelper.getEmployeeDetails(
                              context: context,
                              ehrmsDetails: profileRepository.ehrmsDetails)
                          .length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            FieldNameWidget(
                              fieldName: EhrmsHelper.getEmployeeDetails(
                                      context: context,
                                      ehrmsDetails:
                                          profileRepository.ehrmsDetails)[index]
                                  .key,
                            ),
                            ReadOnlyField(
                              text: EhrmsHelper.getEmployeeDetails(
                                      context: context,
                                      ehrmsDetails:
                                          profileRepository.ehrmsDetails)[index]
                                  .value,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    height: 24,
                  ),
                  // Present address section
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormFieldSectionHeading(
                            text: AppLocalizations.of(context)
                                .mehrmsPresentAddress),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: EhrmsHelper.getPresentAddress(
                                  context: context,
                                  ehrmsDetails: profileRepository.ehrmsDetails)
                              .length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                FieldNameWidget(
                                  fieldName: EhrmsHelper.getPresentAddress(
                                          context: context,
                                          ehrmsDetails: profileRepository
                                              .ehrmsDetails)[index]
                                      .key,
                                ),
                                ReadOnlyField(
                                  text: EhrmsHelper.getPresentAddress(
                                          context: context,
                                          ehrmsDetails: profileRepository
                                              .ehrmsDetails)[index]
                                      .value,
                                ),
                              ],
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    height: 24,
                  ),
                  // Permanent address section
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormFieldSectionHeading(
                            text: AppLocalizations.of(context)
                                .mehrmsPermanentAddress),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: EhrmsHelper.getPermanentAddress(
                                  context: context,
                                  ehrmsDetails: profileRepository.ehrmsDetails)
                              .length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                FieldNameWidget(
                                  fieldName: EhrmsHelper.getPermanentAddress(
                                          context: context,
                                          ehrmsDetails: profileRepository
                                              .ehrmsDetails)[index]
                                      .key,
                                ),
                                ReadOnlyField(
                                  text: EhrmsHelper.getPermanentAddress(
                                          context: context,
                                          ehrmsDetails: profileRepository
                                              .ehrmsDetails)[index]
                                      .value,
                                ),
                              ],
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  )
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                  child: Text(
                      AppLocalizations.of(context).mehrmsNoDetailsMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontWeight: FontWeight.w700,
                      ))),
            );
    });
  }
}
