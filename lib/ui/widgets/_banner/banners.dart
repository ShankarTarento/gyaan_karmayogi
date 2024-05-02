import 'package:karmayogi_mobile/constants/index.dart';

class Banners {
  final String image;
  final String navigationUri;

  Banners({
    this.image,
    this.navigationUri,
  });

  List<Banners> get items => [
        Banners(
            image: ApiUrl.baseUrl +
                "/assets/instances/eagle/banners/orgs/new-banner/4/s.png",
            navigationUri: ApiUrl.baseUrl + '/app/organisation/dopt'),
        // Banners(
        //     image: ApiUrl.baseUrl +
        //         "/assets/instances/eagle/banners/orgs/new-banner/1/s.png",
        //     navigationUri: ''),
        Banners(
            image: ApiUrl.baseUrl +
                "/assets/instances/eagle/banners/orgs/new-banner/2/s.png",
            navigationUri: ''),
        // Banners(
        //     image: ApiUrl.baseUrl +
        //         "/assets/instances/eagle/banners/orgs/new-banner/3/s.png",
        //     navigationUri: ''),
      ];

  int get bannerLength => items.length;
}
