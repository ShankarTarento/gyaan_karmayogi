import 'package:flutter/material.dart';
import '../../../models/index.dart';
import '../../widgets/index.dart';
import './../../../ui/pages/index.dart';

class HubScreen extends StatefulWidget {
  static const route = '/hubScreen';
  final int index;
  final Profile profileInfo;
  final profileParentAction;

  HubScreen({Key key, this.index, this.profileInfo, this.profileParentAction})
      : super(key: key);

  @override
  _HubScreenState createState() {
    return new _HubScreenState();
  }
}

class _HubScreenState extends State<HubScreen> with WidgetsBindingObserver {
  ScrollController _scrollController;

  bool scrollStatus = true;

  _scrollListener() {
    if (isScroll != scrollStatus) {
      setState(() {
        scrollStatus = isScroll;
      });
    }
  }

  bool get isScroll {
    return _scrollController.hasClients &&
        _scrollController.offset > (200 - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    // if (widget.index == 1) {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool isScrolled) {
          return <Widget>[
            HomeAppBarNew(
                profileInfo: widget.profileInfo,
                index: widget.index,
                profileParentAction: widget.profileParentAction),
          ];
        },
        body: SingleChildScrollView(
          child: Container(
            // color: Color.fromRGBO(241, 244, 244, 1),
            child: HubPage(
              tabIndex: widget.index,
            ),
          ),
        ),
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: CustomScrollView(
  //       slivers: <Widget>[
  //         HomeAppBar(
  //           title: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Row(
  //                 children: [
  //                   Padding(
  //                     padding: EdgeInsets.only(top: 3.0),
  //                     child: Image.asset(
  //                       'assets/img/igot_icon.png',
  //                       width: 28,
  //                       height: 28,
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: EdgeInsets.only(left: 8.0, top: 5.5),
  //                     child: Text(
  //                       'Karmayogi Bharat',
  //                       style: GoogleFonts.montserrat(
  //                         color: Colors.black87,
  //                         fontSize: 16.0,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               Icon(
  //                 Icons.search,
  //                 color: AppColors.greys60,
  //               ),
  //             ],
  //           ),
  //         ),
  //         HomeSilverList(
  //           child: Container(
  //             color: Color.fromRGBO(241, 244, 244, 1),
  //             child: HubPage(),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
}
