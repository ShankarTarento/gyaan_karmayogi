import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/creator_model.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthorsCurators extends StatelessWidget {
  final List<CreatorModel> curators;
  final List<CreatorModel> authors;
  const AuthorsCurators(
      {Key key, @required this.curators, @required this.authors})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).mStaticAuthorsAndCurators,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        authors.isEmpty && curators.isEmpty
            ? Text(
                AppLocalizations.of(context).mMsgNoDataFound,
                style: GoogleFonts.lato(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff000000).withOpacity(0.60)),
              )
            : SizedBox(),
        if (authors.isNotEmpty)
          ...List.generate(authors.length, (index) {
            return displayCard(
              initial: Helper.getInitials(authors[index].name),
              title: authors[index].name,
              subtitle: AppLocalizations.of(context).mLearnCourseAuthor,
              context: context,
            );
          }),
        if (curators.isNotEmpty)
          ...List.generate(curators.length, (index) {
            return displayCard(
              initial: Helper.getInitials(curators[index].name),
              title: curators[index].name,
              subtitle: AppLocalizations.of(context).mLearnCourseCurator,
              context: context,
            );
          })
      ],
    );
  }

  Widget displayCard(
      {@required String initial,
      @required String title,
      @required String subtitle,
      @required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black,
            child: Text(
              initial,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff000000).withOpacity(0.6),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
