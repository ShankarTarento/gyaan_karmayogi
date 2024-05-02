import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/_constants/color_constants.dart';

class LoadWebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const LoadWebViewPage({Key key, this.url, this.title}) : super(key: key);

  @override
  State<LoadWebViewPage> createState() => _LoadWebViewPageState();
}

class _LoadWebViewPageState extends State<LoadWebViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Text(widget.title,
            style: GoogleFonts.montserrat(
              color: AppColors.greys87,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: widget.url,

        onWebResourceError: (WebResourceError error) => {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Scaffold(
                  appBar: AppBar(
                    titleSpacing: 0,
                    centerTitle: false,
                    title: Text(widget.title,
                        style: GoogleFonts.montserrat(
                          color: AppColors.greys87,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  body: Container(
                    child: Center(
                        child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Error loading URL',
                            style: GoogleFonts.montserrat(
                              color: AppColors.greys87,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Error code: ${error.errorCode}\nDescription: ${error.description}',
                            style: GoogleFonts.montserrat(
                              color: AppColors.greys87,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    )),
                  ),
                
                );
              })
         
        },
      ),
    );
  }
}
