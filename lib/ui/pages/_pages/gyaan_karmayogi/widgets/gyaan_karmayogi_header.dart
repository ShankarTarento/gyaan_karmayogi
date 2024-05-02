import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../constants/_constants/color_constants.dart';
import '../services/gyaan_karmayogi_service.dart';

class GyaanKarmayogiHeader extends StatefulWidget {
  final TextEditingController searchController;
  final Function() resetFilter;
  const GyaanKarmayogiHeader(
      {Key key, @required this.searchController, @required this.resetFilter})
      : super(key: key);

  @override
  State<GyaanKarmayogiHeader> createState() => _GyaanKarmayogiHeaderState();
}

class _GyaanKarmayogiHeaderState extends State<GyaanKarmayogiHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff3A83CF), Color(0xFF1B4CA1)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).mCommonGyannKarmayogi,
            style: GoogleFonts.montserrat(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: 4, bottom: 8, left: MediaQuery.of(context).size.width / 4),
            child: SvgPicture.asset(
              'assets/img/curve.svg',
              width: 176,
            ),
          ),
          Text(
            AppLocalizations.of(context).mGyaanKarmayogiDescription,
            style: GoogleFonts.lato(
              color: AppColors.white,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Row(
            children: [
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width / 1.5,
                child: TextField(
                  controller: widget.searchController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      contentPadding: EdgeInsets.only(left: 12, right: 12),
                      hintText:
                          AppLocalizations.of(context).mSearchInGyaanKarmayogi,
                      hintStyle: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      )),
                ),
              ),
              Spacer(),
              SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width / 4.5,
                child: ElevatedButton(
                    onPressed: () async {
                      await Provider.of<GyaanKarmayogiServices>(context,
                              listen: false)
                          .getAvailableSector(
                              showAllSectors: false,
                              type: "sector",
                              query: widget.searchController.text);
                      widget.resetFilter();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context).mStaticSearch)),
              )
            ],
          ),
        ],
      ),
    );
  }
}
