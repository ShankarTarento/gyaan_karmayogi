import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:provider/provider.dart';

class OrgTypeSelection extends StatelessWidget {
  final List<dynamic> options;
  final String selected;
  final Function(dynamic value) onTapFn;
  const OrgTypeSelection(
      {Key key,
      @required this.selected,
      @required this.options,
      @required this.onTapFn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 4,
        crossAxisSpacing: 10,
        children: List.generate(options.length, (index) {
          return Consumer<ProfileRepository>(builder: (BuildContext context,
              ProfileRepository profileRepository, Widget child) {
            return GestureDetector(
              onTap: () {
                if (!profileRepository.inReview
                    .containsKey('organisationType')) {
                  onTapFn(options[index]);
                }
              },
              child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(const Radius.circular(4.0)),
                      color: (selected == options[index]) ||
                              ((selected == '') &&
                                  options[index] == EnglishLang.government)
                          ? AppColors.primaryThree
                          : Colors.white,
                      border: Border.all(
                        color: (selected == options[index]) ||
                                ((selected == '') &&
                                    options[index] == EnglishLang.government)
                            ? AppColors.primaryThree
                            : AppColors.grey16,
                      ),
                    ),
                    child: Center(
                        child: Text(
                      options[index],
                      style: GoogleFonts.lato(
                          fontSize: 14,
                          color: (selected == options[index]) ||
                                  ((selected == '') &&
                                      options[index] == EnglishLang.government)
                              ? Colors.white
                              : AppColors.greys60),
                    )),
                  )),
            );
          });
        }));
  }
}
