import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../constants/index.dart';
import '../../../../util/faderoute.dart';
import '../../index.dart';

class TopProviders extends StatelessWidget {
  final List<TopProviderModel> topProviderList;

  const TopProviders({Key key, this.topProviderList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).mStaticTopProvidersTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
                color: AppColors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 16,
          ),
          ScrollLoopAutoScroll(
            duration: Duration(minutes: 30),
            scrollDirection: Axis.horizontal,
            child: Container(
              color: AppColors.appBarBackground,
              child: Row(
                  children: topProviderList
                      .map((provider) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                                onTap: () => Navigator.push(
                                      context,
                                      FadeRoute(
                                          page: CoursesByProvider(
                                        provider.clientName,
                                        isCollection: false,
                                        collectionId: '',
                                      )),
                                    ),
                                child: Container(
                                  width: 150,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          right: BorderSide(
                                              color: AppColors.grey16))),
                                  child: Column(
                                    children: [
                                      Image(
                                        height: 60,
                                        width: 80,
                                        image: NetworkImage(
                                          ApiUrl.baseUrl +
                                              '/' +
                                              provider.clientImageUrl,
                                        ),
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Center(),
                                      ),
                                      SizedBox(height: 4),
                                      TitleRegularGrey60(
                                        provider.clientName,
                                        color: AppColors.greys87,
                                        fontSize: 14,
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                )),
                          ))
                      .toList()),
            ),
          ),
        ],
      ),
    );
  }
}
