import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import './../../../../constants/index.dart';
import './../../../../respositories/_respositories/knowledge_resource_repository.dart';
import './../../../../ui/pages/_pages/knowledge_resources/knowledge_resource_details.dart';
import './../../../../util/faderoute.dart';
import './../../../../respositories/index.dart';
import './../../../../models/index.dart';
import './../../../../localization/index.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SavedResourcesPage extends StatefulWidget {
  final List<KnowledgeResource> knowledgeResources;
  final parentAction;

  SavedResourcesPage({Key key, this.knowledgeResources, this.parentAction})
      : super(key: key);

  @override
  _SavedResourcesPageState createState() => _SavedResourcesPageState();
}

class _SavedResourcesPageState extends State<SavedResourcesPage>
    with SingleTickerProviderStateMixin {
  AnimationController _iconAnimationController;
  List<KnowledgeResource> _savedResources = [];

  @override
  void initState() {
    super.initState();

    _iconAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      value: 1.0,
      lowerBound: 1.0,
      upperBound: 1.2,
    );
    _getAllSavedResources();
    // openFile();
  }

  Future<void> _fetchData() async {
    widget.parentAction();
  }

  _fetchSavedResource(id) async {
    _savedResources.forEach((resource) {
      if (resource.id == id) {
        setState(() {
          _savedResources.remove(resource);
        });
      }
    });
  }

  Future<void> _bookmarkKnowledgeResource(context, id, status) async {
    try {
      _iconAnimationController
          .forward()
          .then((value) => _iconAnimationController.reverse());
      // print(id.toString() + ', ' + status.toString());
      var response = await Provider.of<KnowledgeResourceRespository>(context,
              listen: false)
          .bookmarkKnowledgeResource(id, status);
      // print(response);
      if (response == 200) {
        if (status) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              AppLocalizations.of(context).mStaticBookmarkAddedMessage,
            ),
            duration: Duration(seconds: 3),
            backgroundColor: AppColors.positiveLight,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              AppLocalizations.of(context).mStaticBookmarkRemovedMessage,
            ),
            duration: Duration(seconds: 3),
            backgroundColor: AppColors.positiveLight,
          ));
          widget.parentAction();

          _savedResources.forEach((resource) {
            if (resource.id == id) {
              setState(() {
                _savedResources.remove(resource);
              });
            }
          });
        }
        setState(() {});
      }
    } catch (err) {
      return err;
    }
  }

  Widget _link(urlLength) {
    return Row(children: [
      Icon(
        Icons.link,
        color: AppColors.primaryThree,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          urlLength.toString() + ' URL',
          style: GoogleFonts.lato(
              color: AppColors.greys87,
              fontSize: 14.0,
              fontWeight: FontWeight.w400),
        ),
      )
    ]);
  }

  _getAllSavedResources() async {
    widget.knowledgeResources.forEach((resource) {
      if (resource.bookmark == true) {
        setState(() {
          _savedResources.add(resource);
        });
      }
    });
    return _savedResources;
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (_savedResources.length != 0)
        ? SingleChildScrollView(
            child: Container(
            child: Column(children: <Widget>[
              Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: AnimationLimiter(
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _savedResources.length,
                      itemBuilder: (context, index) {
                        // if (widget.knowledgeResources[index].bookmark == false ||
                        //     widget.knowledgeResources[index].bookmark == null) {
                        //   return Center();
                        // }
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: InkWell(
                                onTap: () => {
                                  Navigator.push(
                                    context,
                                    FadeRoute(
                                        page: KnowledgeResourceDetails(
                                      _savedResources[index],
                                      parentAction: _fetchData,
                                      parentActionForSaved: _fetchSavedResource,
                                    )),
                                  ),
                                },
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.white,
                                  margin: EdgeInsets.only(top: 5.0),
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        16.0, 10.0, 20.0, 18.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _savedResources[index].source !=
                                                      null
                                                  ? _savedResources[index]
                                                      .source
                                                  : '',
                                              style: GoogleFonts.lato(
                                                  color: AppColors.greys60,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            (_savedResources[index].bookmark !=
                                                    null)
                                                ? _savedResources[index]
                                                        .bookmark
                                                    ? ScaleTransition(
                                                        scale:
                                                            _iconAnimationController,
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons.bookmark,
                                                            color: AppColors
                                                                .primaryThree,
                                                          ),
                                                          onPressed: () {
                                                            _bookmarkKnowledgeResource(
                                                                context,
                                                                _savedResources[
                                                                        index]
                                                                    .id,
                                                                false);
                                                          },
                                                        ),
                                                      )
                                                    : ScaleTransition(
                                                        scale:
                                                            _iconAnimationController,
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons.bookmark,
                                                            color: AppColors
                                                                .grey16,
                                                          ),
                                                          onPressed: () {
                                                            _bookmarkKnowledgeResource(
                                                                context,
                                                                _savedResources[
                                                                        index]
                                                                    .id,
                                                                true);
                                                          },
                                                        ),
                                                      )
                                                : Center()
                                          ],
                                        ),
                                        _savedResources[index].name != null
                                            ? Container(
                                                child: Text(
                                                  _savedResources[index].name,
                                                  style: GoogleFonts.lato(
                                                      color: AppColors.greys87,
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              )
                                            : Center(),
                                        // widget.knowledgeResources[index].description !=
                                        //         null
                                        //     ? Container(
                                        //         padding: const EdgeInsets.only(top: 10),
                                        //         child: Text(
                                        //           widget.knowledgeResources[index]
                                        //               .description,
                                        //           style: GoogleFonts.lato(
                                        //               color: AppColors.greys87,
                                        //               fontSize: 16.0,
                                        //               fontWeight: FontWeight.w500),
                                        //         ),
                                        //       )
                                        //     : Center(),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              // Icon(
                                              //   _knowledgeResources[index].icon,
                                              //   color: AppColors.greys60,
                                              // ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                child: Text(
                                                  _savedResources[index].id,
                                                  style: GoogleFonts.lato(
                                                      color: AppColors.greys60,
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _savedResources[index].raw[
                                                    'additionalProperties'] !=
                                                null
                                            ? Container(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0),
                                                child: Row(
                                                  children: [
                                                    _savedResources[index]
                                                                .files !=
                                                            null
                                                        //                                         widget.knowledgeResources[14].krFiles
                                                        // .where((item) => item['fileType'] == 'jpg')
                                                        // .toList()
                                                        ? Row(
                                                            children: [
                                                              _savedResources[index]
                                                                          .krFiles
                                                                          .where((item) =>
                                                                              item['fileType'] ==
                                                                              'jpg')
                                                                          .toList()
                                                                          .length !=
                                                                      0
                                                                  ? Row(
                                                                      children: [
                                                                        SvgPicture
                                                                            .asset(
                                                                          'assets/img/jpg.svg',
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              left: 10.0,
                                                                              right: 18),
                                                                          child:
                                                                              Text(
                                                                            _savedResources[index].krFiles.where((item) => item['fileType'] == 'jpg').toList().length.toString(),
                                                                            style: GoogleFonts.lato(
                                                                                color: AppColors.greys87,
                                                                                fontSize: 14.0,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Center(),
                                                              _savedResources[index]
                                                                          .krFiles
                                                                          .where((item) =>
                                                                              item['fileType'] ==
                                                                              'png')
                                                                          .toList()
                                                                          .length !=
                                                                      0
                                                                  ? Row(
                                                                      children: [
                                                                        SvgPicture
                                                                            .asset(
                                                                          'assets/img/png.svg',
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              left: 10.0,
                                                                              right: 18),
                                                                          child:
                                                                              Text(
                                                                            _savedResources[index].krFiles.where((item) => item['fileType'] == 'png').toList().length.toString(),
                                                                            style: GoogleFonts.lato(
                                                                                color: AppColors.greys87,
                                                                                fontSize: 14.0,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Center(),
                                                              _savedResources[index]
                                                                          .krFiles
                                                                          .where((item) =>
                                                                              item['fileType'] ==
                                                                              'pdf')
                                                                          .toList()
                                                                          .length !=
                                                                      0
                                                                  ? Row(
                                                                      children: [
                                                                        SvgPicture
                                                                            .asset(
                                                                          'assets/img/pdf.svg',
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              left: 10.0,
                                                                              right: 18),
                                                                          child:
                                                                              Text(
                                                                            _savedResources[index].krFiles.where((item) => item['fileType'] == 'pdf').toList().length.toString(),
                                                                            style: GoogleFonts.lato(
                                                                                color: AppColors.greys87,
                                                                                fontSize: 14.0,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Center(),
                                                            ],
                                                          )
                                                        : Center(),
                                                    _savedResources[index]
                                                                .urls !=
                                                            null
                                                        ? _link(_savedResources[
                                                                index]
                                                            .urls
                                                            .length)
                                                        : Center()
                                                  ],
                                                ),
                                              )
                                            : Center()
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ))
            ]),
          ))
        : Stack(
            children: <Widget>[
              Column(
                children: [
                  Container(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 125),
                        child: SvgPicture.asset(
                          'assets/img/empty_search.svg',
                          alignment: Alignment.center,
                          // color: AppColors.grey16,
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.height * 0.2,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      AppLocalizations.of(context).mMsgNoDataFound,
                      style: GoogleFonts.lato(
                        color: AppColors.greys60,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.5,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}
