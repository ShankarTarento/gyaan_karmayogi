import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import './../../../models/index.dart';
import './../../../respositories/index.dart';
import './../../../constants/index.dart';
import './../../../ui/pages/index.dart';
import './../../../ui/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class KnowledgeResourcesScreen extends StatefulWidget {
  static const route = AppUrl.knowledgeResourcesPage;

  @override
  _KnowledgeResourcesScreenState createState() {
    return _KnowledgeResourcesScreenState();
  }
}

class _KnowledgeResourcesScreenState extends State<KnowledgeResourcesScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  List tabNames = [];

  List<KnowledgeResource> _knowledgeResources = [];
  String filterPositionId = '';
  String filterPosition = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didChangeDependencies() {
    tabNames = [
      AppLocalizations.of(context).mCommonAll,
      AppLocalizations.of(context).mStaticSaved
    ];
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  Future<void> fetchData() async {
    if (filterPositionId == '') {
      await _getKnowledgeResources();
    } else {
      _filerByPositionKnowledgeResource(filterPositionId);
    }
  }

  void setFilter(Map position) {
    // print('setFilter');
    setState(() {
      filterPosition = position['position'];
      filterPositionId = position['id'];
    });
    fetchData();
  }

  Future<List<KnowledgeResource>> _getKnowledgeResources() async {
    try {
      var knowledgeResources = [];
      knowledgeResources = await Provider.of<KnowledgeResourceRespository>(
              context,
              listen: false)
          .getKnowledgeResources();
      setState(() {
        _knowledgeResources = knowledgeResources;
      });
      return _knowledgeResources;
    } catch (err) {
      return err;
    }
  }

  Future<dynamic> _filerByPositionKnowledgeResource(String id) async {
    try {
      List<KnowledgeResource> knowledgeResources = [];
      knowledgeResources = await Provider.of<KnowledgeResourceRespository>(
              context,
              listen: false)
          .filerByPositionKnowledgeResource(id);
      setState(() {
        _knowledgeResources = knowledgeResources;
      });
    } catch (err) {
      return err;
    }
    return _knowledgeResources;
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: BackButton(color: AppColors.greys60),
        title: Row(children: [
          Icon(
            Icons.menu_book,
            color: AppColors.greys60,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                AppLocalizations.of(context).mCommonGyannKarmayogi,
                style: GoogleFonts.montserrat(
                  color: AppColors.greys87,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ))
        ]),
      ),
      // Tab controller
      body: _knowledgeResources.isNotEmpty
          ? SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _topBannerView(),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      // color: AppColors.lightBackground,
                      child: AllResourcesPage(
                          knowledgeResources: _knowledgeResources,
                          parentAction: fetchData),
                    ),
                  ],
                ),
              ),
            )
          : PageLoader(
              bottom: 175,
            ),
    );
  }

  Widget _topBannerView() {
    return CachedNetworkImage(
      imageUrl: ApiUrl.baseUrl +
          '/assets/instances/eagle/banners/hubs/knowledgeresource/s.png',
      placeholder: (context, url) => PageLoader(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
