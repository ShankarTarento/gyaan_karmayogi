import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/competency_data_model.dart';
import 'package:karmayogi_mobile/services/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/contact_us.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:provider/provider.dart';
import '../../../respositories/_respositories/learn_repository.dart';
import '../../skeleton/index.dart';
import '../../widgets/index.dart';
import './../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetencyThemeScreen extends StatefulWidget {
  final CompetencyTheme competencyTheme;
  const CompetencyThemeScreen({Key key, @required this.competencyTheme})
      : super(key: key);
  @override
  _CompetencyThemeScreenState createState() {
    return _CompetencyThemeScreenState();
  }
}

class _CompetencyThemeScreenState extends State<CompetencyThemeScreen> {
  bool isLoad = false;
  CompetencyTheme competencyTheme;
  final double leftPadding = 20.0;
  @override
  void initState() {
    super.initState();
    // fetchData();
  }

  // Future<void> fetchData() async {
  //   await Provider.of<LearnRepository>(context, listen: false).getCompetency();
  // }

  @override
  Widget build(BuildContext context) {
    if (!isLoad) {
      final args =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      competencyTheme = args['competencyTheme'];
      isLoad = true;
    }
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 0,
          leading: BackButton(color: AppColors.greys60),
          title: Row(children: [
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadeRoute(page: ContactUs()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                child: SvgPicture.asset(
                  'assets/img/help_icon.svg',
                  width: 56.0,
                  height: 56.0,
                ),
              ),
            ),
          ]),
        ),
        body: SafeArea(child: SingleChildScrollView(
          child:
              Consumer<LearnRepository>(builder: (context, learnRepository, _) {
            var competency = learnRepository.competency;
            if (competency != null) {
              return Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    CompetencyPassbookThemeHeader(
                        competencyTheme: competencyTheme),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 20.0, bottom: 12.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: AppColors.appBarBackground,
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations.of(context).mCompetencySubTheme} ${competencyTheme.competencySubthemes.length}',
                              // 'Competency sub-theme (${competencyTheme.competencySubthemes.length})',
                              style: GoogleFonts.montserrat(
                                  height: 1.5,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 16),
                            CompetencyPassbookSubtheme(
                                competencySubthemes:
                                    competencyTheme.competencySubthemes),
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                      child: Text(
                        '${AppLocalizations.of(context).mCompetencyAssociatedCertificate} ${competencyTheme.courses.length} ',
                        // 'Associated certificates (${competencyTheme.courses.length})',
                        style: GoogleFonts.montserrat(
                            height: 1.5,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: competencyTheme.courses.length,
                      itemBuilder: (context, index) {
                        if (competencyTheme.courses[index].certificateId !=
                            null) {
                          return FutureBuilder(
                              future: _getCompletionCertificate(
                                  competencyTheme.courses[index].certificateId),
                              builder:
                                  (context, AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.runtimeType == String) {
                                    return Center();
                                  }
                                  return CompetencyPassbookCertificateCard(
                                      courseInfo:
                                          competencyTheme.courses[index],
                                      certificate: snapshot.data);
                                } else {
                                  return CompetencyPassbookCertificateCard(
                                      courseInfo:
                                          competencyTheme.courses[index],
                                      isCertificateProvided: true);
                                }
                              });
                        } else {
                          return CompetencyPassbookCertificateCard(
                              courseInfo: competencyTheme.courses[index],
                              isCertificateProvided: false);
                        }
                      },
                    )
                  ],
                ),
              );
            } else {
              return const CompetencyPassbookThemeSkeletonPage();
            }
          }),
        )));
  }

// Get certificate in base64 format
  Future<dynamic> _getCompletionCertificate(dynamic certificateId) async {
    final certificate =
        await LearnService().getCourseCompletionCertificate(certificateId);
    return certificate;
  }
}
