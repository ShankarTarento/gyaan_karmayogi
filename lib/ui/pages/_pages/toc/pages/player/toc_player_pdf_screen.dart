import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';

class TocPlayerPdfScreen extends StatelessWidget {
  final Widget player;
  final String resourcename;
  TocPlayerPdfScreen(
      {Key key, @required this.player, @required this.resourcename})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context).mOpenresource('PDF'),
          style: GoogleFonts.lato(
              color: AppColors.appBarBackground,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.25),
        ),
        SizedBox(
          height: 16,
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Scaffold(
                        backgroundColor: AppColors.scaffoldBackground,
                        body: SafeArea(
                          child: NestedScrollView(
                            headerSliverBuilder: (BuildContext context,
                                bool innerBoxIsScrolled) {
                              return <Widget>[
                                SliverAppBar(
                                  backgroundColor: AppColors.appBarBackground,
                                  pinned: false,
                                  automaticallyImplyLeading: false,
                                  flexibleSpace: Row(
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: AppColors.greys60,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          }),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.75,
                                        child: Text(
                                          resourcename,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(
                                              color: AppColors.greys87,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.25),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ];
                            },
                            body: Center(child: player),
                          ),
                        ),
                      )),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.orangeTourText,
                borderRadius: BorderRadius.circular(63)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/img/pdf_alternate.svg',
                  color: AppColors.greys87,
                  height: 24,
                  width: 24,
                ),
                SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context).mStaticOpen,
                  style: GoogleFonts.lato(
                      color: AppColors.profilebgGrey,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.25),
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
