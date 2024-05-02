import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/knowledge_resources/resources_item.dart';
import './../../../../constants/index.dart';
import './../../../../models/index.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AllResourcesPage extends StatefulWidget {
  final List<KnowledgeResource> knowledgeResources;
  final parentAction;
  AllResourcesPage({Key key, this.knowledgeResources, this.parentAction})
      : super(key: key);

  @override
  _AllResourcesPageState createState() => _AllResourcesPageState();
}

class _AllResourcesPageState extends State<AllResourcesPage>
    with TickerProviderStateMixin {
  AnimationController _iconAnimationController;
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
  }

  Future<void> _fetchData() async {
    widget.parentAction();
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (widget.knowledgeResources.length != 0)
        ? SingleChildScrollView(
            child: Container(
            child: Column(children: <Widget>[
              Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: _resourcesListView())
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
                      "No resources available",
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

  Widget _resourcesListView() {
    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.knowledgeResources.length > 0? widget.knowledgeResources.length: 0,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(
                  milliseconds: 375),
              child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: InkWell(
                        // onTap: () {
                        //   Navigator.push(
                        //     context,
                        //     FadeRoute(
                        //         page: KnowledgeResourceDetails(
                        //           widget.knowledgeResources[index],
                        //           parentAction: _fetchData,
                        //         )),
                        //   );
                        // },
                        child: ResourcesItem(
                          widget.knowledgeResources[index],
                          parentAction: _fetchData
                        )),
                  )));
        },
      ),
    );
  }
}
