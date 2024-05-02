import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SeeAllConnectionRequests extends StatelessWidget {
  final connectionRequests;
  final parentAction;
  final maxLimitToShowRequests = 3;

  SeeAllConnectionRequests(this.connectionRequests, {this.parentAction});
  bool get showRequests =>
      this.connectionRequests.data.length > maxLimitToShowRequests;
  @override
  Widget build(BuildContext context) {
    return connectionRequests.data.length > 0
        ? InkWell(
            onTap: parentAction,
            splashColor: Theme.of(context).primaryColor,
            child: Stack(children: _buildItems(context)))
        : SizedBox.shrink();
  }

  List<Widget> _buildItems(BuildContext context) {
    List<Widget> stackElements = [];
    stackElements.add(Container(
      height: 56,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: AppColors.darkBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.darkBlue.withOpacity(0.1),
          width: 1, //                   <--- border width here
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              AppLocalizations.of(context).mStaticMyActivitySeePendingReqs,
              style: GoogleFonts.lato(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: Icon(
              Icons.arrow_forward_ios_sharp,
              size: 12,
              weight: 2,
              grade: 2,
              color: AppColors.darkBlue,
            ),
          ),
          Spacer(),
          _stackedConnRequests(),
          Visibility(
            visible: showRequests,
            child: Text(
              '+ ${connectionRequests.data.length - maxLimitToShowRequests}',
              style: GoogleFonts.lato(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.25,
              ),
            ),
          ),
        ],
      ),
    ));

    stackElements.add(Positioned(
      // draw a red marble
      top: -1,
      right: -1,
      child: new Icon(Icons.brightness_1,
          size: 8.0, color: AppColors.negativeLight),
    ));
    return stackElements;
  }

  Widget _stackedConnRequests() {
    return Container(
        width: showRequests ? 80 : 50,
        height: 24,
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: connectionRequests.data.length > maxLimitToShowRequests
                ? maxLimitToShowRequests
                : connectionRequests.data.length,
            itemBuilder: (context, index) {
              return Align(
                widthFactor: 0.4,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    backgroundColor: AppColors.networkBg[
                        Random().nextInt(AppColors.networkBg.length)],
                    radius: 11,
                    child: Text(
                      getInitials(connectionRequests.data[index]['fullName']),
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              );
            }));
  }
}

String getInitials(String fullName) => fullName.isNotEmpty
    ? fullName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
    : '';
