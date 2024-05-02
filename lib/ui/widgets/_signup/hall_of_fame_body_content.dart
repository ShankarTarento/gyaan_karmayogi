import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/hall_of_fame_mdo_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/hall_of_fame_list_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HallOfFameBodyContentWidget extends StatefulWidget {
  final HallOfFameMdoListModel listOfMdo;
  HallOfFameBodyContentWidget({Key key, @required this.listOfMdo})
      : super(key: key) {
    // list should show top 10 MDOs only
    if (listOfMdo.mdoList.length > 10) {
      listOfMdo.mdoList.removeRange(10, listOfMdo.mdoList.length);
    }
  }

  @override
  State<HallOfFameBodyContentWidget> createState() =>
      _HallOfFameBodyContentWidgetState();
}

class _HallOfFameBodyContentWidgetState
    extends State<HallOfFameBodyContentWidget> {
  bool searchApplied = false;
  List<MdoList> _filteredListOfMdo = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.darkerBlue,
              AppColors.darkestBlue,
              AppColors.darkerBlue,
            ],
          )),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.appBarBackground.withOpacity(0.4),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: Column(
              children: [
                SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16),
                  child: Container(
                    height: 48,
                    child: TextFormField(
                        onChanged: (value) {
                          searchApplied = value.trim().toString().isNotEmpty;
                          filterMDOs(value);
                        },
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        style: GoogleFonts.lato(fontSize: 14.0),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(Icons.search),
                          contentPadding:
                              EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                              color: AppColors.grey16,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                              color: AppColors.primaryThree,
                            ),
                          ),
                          hintText:
                              AppLocalizations.of(context).mStaticSearchMDOs,
                          hintStyle: GoogleFonts.lato(
                              color: AppColors.greys60,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400),
                          // ),
                          counterStyle: TextStyle(
                            height: double.minPositive,
                          ),
                          counterText: '',
                        )),
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: searchApplied
                        ? _filteredListOfMdo.length
                        : widget.listOfMdo.mdoList.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (!searchApplied &&
                          (widget.listOfMdo.mdoList[index].rank == 1 ||
                              widget.listOfMdo.mdoList[index].rank == 2 ||
                              widget.listOfMdo.mdoList[index].rank == 3)) {
                        return SizedBox.shrink();
                      }
                      return HallOfFameListItemWidget(
                        mdoListItem: searchApplied
                            ? _filteredListOfMdo[index]
                            : widget.listOfMdo.mdoList[index],
                        showClock: showClock(index),
                      );
                    }),
                Visibility(
                    visible: searchApplied
                        ? _filteredListOfMdo.length == 0
                        : widget.listOfMdo.mdoList.length == 0,
                    child: SizedBox(
                      height: 100,
                      child: Text(
                        AppLocalizations.of(context).mStaticNotFound,
                        style: GoogleFonts.lato(
                            color: AppColors.ghostWhite,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400),
                      ),
                    )),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void filterMDOs(value) {
    _filteredListOfMdo = widget.listOfMdo.mdoList
        .where(
            (mdo) => (mdo.orgName).toLowerCase().contains(value.toLowerCase()))
        .toList();
    setState(() {});
  }

  bool showClock(int index) {
    bool showClock = false;
    for (int i = 0; i < widget.listOfMdo.mdoList.length; i++) {
      if (i != index) {
        if (widget.listOfMdo.mdoList[i].averageKp ==
            widget.listOfMdo.mdoList[index].averageKp) {
          showClock = true;
          break;
        }
      }
    }
    return showClock;
  }
}
