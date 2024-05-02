import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/skeleton/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion/silverappbar_delegate.dart';

class EditProfileSkeletonPage extends StatelessWidget {
  const EditProfileSkeletonPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  pinned: false,
                  leading: BackButton(color: AppColors.greys60),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: EdgeInsets.fromLTRB(40.0, 0.0, 10.0, 18.0),
                    title: Padding(
                      padding: EdgeInsets.only(left: 13.0, top: 3.0),
                      child: Text(
                        AppLocalizations.of(context).mEditProfile,
                        style: GoogleFonts.montserrat(
                          color: AppColors.greys87,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: SilverAppBarDelegate(
                    TabBar(
                      isScrollable: true,
                      indicator: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.darkBlue,
                            width: 2.0,
                          ),
                        ),
                      ),
                      indicatorColor: Colors.white,
                      labelPadding: EdgeInsets.only(top: 0.0),
                      unselectedLabelColor: AppColors.greys60,
                      labelColor: AppColors.darkBlue,
                      labelStyle: GoogleFonts.lato(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.lato(
                        fontSize: 10.0,
                        fontWeight: FontWeight.normal,
                      ),
                      tabs: [
                        for (var i = 0; i < 2; i++)
                          Container(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Tab(
                              child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: ContainerSkeleton(
                                  height: 30,
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  pinned: true,
                  floating: false,
                ),
              ];
            },
            // TabBar view
            body: TabBarView(
              children: [
                for (var i = 0; i < 2; i++)
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          i == 0
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16, bottom: 16),
                                    child: ContainerSkeleton(
                                      radius: 200,
                                      width: 150,
                                      height: 150,
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          for (var i = 0; i < 8; i++)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: ContainerSkeleton(
                                    width: 100,
                                    height: 20,
                                    color: AppColors.grey08,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 16),
                                  child: ContainerSkeleton(
                                    width: double.infinity,
                                    height: 50,
                                  ),
                                )
                              ],
                            )
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
