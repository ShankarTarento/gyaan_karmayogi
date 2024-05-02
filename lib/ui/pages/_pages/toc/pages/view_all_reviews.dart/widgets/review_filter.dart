import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class ReviewFilter extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final int selectedIndex;
  const ReviewFilter(
      {Key key, @required this.onChanged, @required this.selectedIndex})
      : super(key: key);

  @override
  State<ReviewFilter> createState() => _ReviewFilterState();
}

class _ReviewFilterState extends State<ReviewFilter> {
  @override
  void initState() {
    selectedIndex = widget.selectedIndex;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    filter = [
      AppLocalizations.of(context).mStaticLatestReviews,
      AppLocalizations.of(context).mStaticTopReviews
    ];
  }

  int selectedIndex;

  List<String> filter = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.0,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 8,
            margin: EdgeInsets.only(top: 24, bottom: 24),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                color: AppColors.greys60),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context).mStaticFilterResults,
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
          ),
          Divider(
            color: AppColors.black40,
          ),
          ...List.generate(
            2,
            (index) => GestureDetector(
              onTap: () {
                selectedIndex = index;
                setState(() {});
              },
              child: ratingFilter(
                index: index,
                title: filter[index],
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Divider(
            color: AppColors.black40,
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 160,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(63.0),
                      side: BorderSide(color: AppColors.darkBlue, width: 1.0),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).mStaticCancel,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 160,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onChanged(selectedIndex);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(63.0),
                      side: BorderSide(color: AppColors.darkBlue, width: 1.0),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)
                        .mCompetenciesContentTypeApplyFilters,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget ratingFilter({@required String title, @required int index}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 8, right: 8),
            height: 18,
            width: 18,
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedIndex == index
                    ? AppColors.darkBlue
                    : AppColors.greys60,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: selectedIndex == index
                    ? AppColors.darkBlue
                    : AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Text(
            title,
            style: selectedIndex == index
                ? GoogleFonts.lato(
                    color: AppColors.darkBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  )
                : GoogleFonts.lato(
                    color: AppColors.greys60,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
          )
        ],
      ),
    );
  }
}
