import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:url_launcher/link.dart';

class VegaFilesView extends StatelessWidget {
  final files;
  const VegaFilesView({Key key, this.files}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(left: 8, right: 8),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              side: BorderSide(
                color: AppColors.grey08,
              ),
            ),
            shadowColor: Colors.black.withOpacity(0.5),
            elevation: 5,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Link(
                          target: LinkTarget.blank,
                          uri: Uri.parse(files[index]['link']),
                          builder: (context, followLink) => InkWell(
                              onTap: followLink,
                              child: ListTile(
                                leading: SvgPicture.asset(
                                  'assets/img/pdf.svg',
                                  width: 24.0,
                                  height: 24.0,
                                ),
                                title: Text(
                                  files[index]['name'],
                                  style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontWeight: FontWeight.w700),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios),
                              ))),
                      (index != files.length - 1)
                          ? Divider(
                              color: AppColors.grey08,
                              height: 25,
                              indent: 16,
                              endIndent: 16,
                              thickness: 1,
                            )
                          : Center()
                    ],
                  );
                  // ListTile(
                  //   title: Text('PDF1'),
                  //   trailing: ,
                  // );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
