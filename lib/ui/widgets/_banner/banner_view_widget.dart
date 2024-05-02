import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/index.dart';

class BannerViewWidget extends StatefulWidget {
  BannerViewWidget({Key key}) : super(key: key);
  @override
  BannerViewWidgetState createState() => BannerViewWidgetState();
}

class BannerViewWidgetState extends State<BannerViewWidget> {
  final _controller = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer _timer;
  final banners = Banners();

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentPage < banners.bannerLength) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_controller.hasClients && mounted) {
        _controller.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.only(top: 38, bottom: 38),
      height: 340,
      width: MediaQuery.of(context).size.width,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
                controller: _controller,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: banners.bannerLength,
                itemBuilder: (context, pageIndex) {
                  return InkWell(
                    onTap: () async {
                      if (banners.items[pageIndex].navigationUri.isNotEmpty) {
                        _launchURL(Banners().items[pageIndex].navigationUri);
                      }
                    },
                    child: CachedNetworkImage(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        imageUrl: banners.items[pageIndex].image,
                        placeholder: (context, url) => PageLoader(),
                        errorWidget: (context, url, error) =>
                            SizedBox.shrink()),
                  );
                }),
          ),
          banners.items.length > 1
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SmoothPageIndicator(
                    controller: _controller,
                    count: banners.items.length,
                    effect: ExpandingDotsEffect(
                        activeDotColor: AppColors.orangeTourText,
                        dotColor: AppColors.profilebgGrey20,
                        dotHeight: 4,
                        dotWidth: 4,
                        spacing: 4),
                  ),
                )
              : Center()
        ],
      ),
    );
  }

  void _launchURL(String uri) async =>
      await canLaunchUrl(Uri.parse(uri)).then((value) => value
          ? launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication)
          : throw 'Please try after sometime');
}
