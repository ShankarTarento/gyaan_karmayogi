import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/widgets/_assistant/vega_course_card.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../constants/index.dart';
import '../models/_arguments/index.dart';

class VegaExpandedItem extends StatelessWidget {
  final Map data;
  const VegaExpandedItem({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              side: BorderSide(
                color: AppColors.grey08,
              ),
            ),
            margin: EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: AnimationLimiter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < data.length; i++)
                    AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Column(
                            children: [
                              ExpansionTile(
                                textColor: AppColors.greys87,
                                iconColor: AppColors.greys87,
                                title: Text(
                                  Helper.capitalizeFirstLetter(data.entries
                                      .elementAt(i)
                                      .key
                                      .toString()
                                      .replaceAll('_', ' ')),
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(data.entries
                                            .elementAt(i)
                                            .value
                                            .length !=
                                        0
                                    ? '${data.entries.elementAt(i).value.length} courses'
                                    : 'No courses found'),
                                children: <Widget>[
                                  data.entries.elementAt(i).value.length != 0
                                      ? ListTile(
                                          title: Container(
                                              // height: 50,
                                              height: data.entries
                                                          .elementAt(i)
                                                          .value
                                                          .length >
                                                      0
                                                  ? 314
                                                  : 0,
                                              width: double.infinity,
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 0),
                                              child: AnimationLimiter(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: data.entries
                                                      .elementAt(i)
                                                      .value
                                                      .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return AnimationConfiguration
                                                        .staggeredList(
                                                      position: index,
                                                      duration: const Duration(
                                                          milliseconds: 375),
                                                      child: SlideAnimation(
                                                        verticalOffset: 50.0,
                                                        child: FadeInAnimation(
                                                          child: InkWell(
                                                            onTap: () {
                                                              // _generateInteractTelemetryData(
                                                              // _vegaCourses[index].id);
                                                              Navigator.pushNamed(
                                                                context,
                                                                AppUrl
                                                                    .courseTocPage,
                                                                arguments:
                                                                    CourseTocModel
                                                                        .fromJson({
                                                                  'courseId':data
                                                                              .entries
                                                                              .elementAt(i)
                                                                              .value[index]['identifier']
                                                                }));
                                                            },
                                                            child: VegaCourseCard(
                                                                course: data
                                                                    .entries
                                                                    .elementAt(
                                                                        i)
                                                                    .value[index]),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )),
                                        )
                                      : Center()
                                ],
                              ),
                              (i != data.length - 1)
                                  ? Divider(
                                      indent: 16,
                                      endIndent: 16,
                                      color: AppColors.grey08,
                                      height: 15,
                                      thickness: 1,
                                    )
                                  : Center()
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              ),
            )),
      ),
    );
  }
}
