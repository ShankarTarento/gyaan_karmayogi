import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../constants/index.dart';

class IosScromPlayerWidget extends StatelessWidget {
  final String identifier;
  final VoidCallback onLoadComplete;
  const IosScromPlayerWidget({Key key, this.identifier, this.onLoadComplete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: Uri.parse(
          '${ApiUrl.baseUrl}/viewer/mobile/html/$identifier?embed=true&preview=true',
        ),
      ),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          javaScriptEnabled: true,
          transparentBackground: true,
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
        ),
      ),
      onLoadStart: (controller, url) => onLoadComplete,
    );
  }
}
