import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/ui/widgets/_competency/competency_passbook_body.dart';
import 'package:karmayogi_mobile/ui/widgets/_competency/competency_passbook_header.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/contact_us.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:provider/provider.dart';
import '../../../respositories/_respositories/learn_repository.dart';
import '../../skeleton/index.dart';
import './../../../constants/index.dart';

class CompetencyPassbookScreen extends StatefulWidget {
  @override
  _CompetencyPassbookScreenState createState() {
    return _CompetencyPassbookScreenState();
  }
}

class _CompetencyPassbookScreenState extends State<CompetencyPassbookScreen> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await Provider.of<LearnRepository>(context, listen: false).getCompetency();
  }

  @override
  Widget build(BuildContext context) {
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
            if (competency != null && competency.runtimeType == List) {
              return Column(
                children: [
                  CompetencyPassbookHeaderWidget(competency: competency),
                  CompetencyPassbookBodyWidget()
                ],
              );
            } else {
              return const CompetencyPassbookSkeletonPage();
            }
          }),
        )));
  }
}
