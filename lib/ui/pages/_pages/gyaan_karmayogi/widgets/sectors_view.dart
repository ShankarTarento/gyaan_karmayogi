import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyaan_karmayogi_resource_list/data_models/gyaan_karmayogi_sector_model.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi/widgets/sector_filters.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/gyaan_karmayogi_service.dart';
import 'gyaan_karmayogi_header.dart';

class SectorsView extends StatefulWidget {
  final Function() navigateToViewAll;
  const SectorsView({
    @required this.navigateToViewAll,
    Key key,
  }) : super(key: key);

  @override
  State<SectorsView> createState() => _SectorsViewState();
}

class _SectorsViewState extends State<SectorsView> {
  List<Color> subSectorColors = [];
  List<GyaanKarmayogiSector> sectors = [];
  @override
  void initState() {
    getSectors();
    subSectorColors = AppColors.gyaanKarmayogiSubSectorColors;
    super.initState();
  }

  getSectors() async {
    sectors = await Provider.of<GyaanKarmayogiServices>(context, listen: false)
        .getAvailableSectorWithIcon();
    await Provider.of<GyaanKarmayogiServices>(context, listen: false)
        .getAvailableSector(
      type: "sector",
      showAllSectors: true,
    );

    //  GyaanKarmayogiServices().getAvailableSectorWithIcon();
    setState(() {});
  }

  TextEditingController searchController = TextEditingController();

  int selectedIndex;
  String selectedSector;
  String selectedSubSector;
  String selectedCategory;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GyaanKarmayogiHeader(
          resetFilter: () {
            selectedCategory = null;
            selectedSector = null;
            selectedSubSector = null;
            selectedIndex = null;

            setState(() {});
          },
          searchController: searchController,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).mStaticSectors,
                    style: GoogleFonts.lato(
                        fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: widget.navigateToViewAll,
                    child: Text(
                      AppLocalizations.of(context).mStaticViewAll,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.darkBlue,
                  )
                ],
              ),
              InkWell(
                onTap: () async {
                  selectedIndex = null;
                  resetFilters();
                  await Provider.of<GyaanKarmayogiServices>(context,
                          listen: false)
                      .getAvailableSector(
                    type: "sector",
                    sectorName: sectors.map((e) => e.name).toList(),
                    showAllSectors: true,
                  );
                  setState(() {});
                },
                child: Container(
                  margin: EdgeInsets.only(top: 16, bottom: 16),
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1.5,
                        color: selectedIndex == null
                            ? AppColors.primaryOne
                            : Colors.transparent),
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "All Sectors",
                      style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2 / 0.8,
                children: List.generate(
                  sectors.length > 8 ? 8 : sectors.length,
                  (index) => InkWell(
                    onTap: () async {
                      selectedIndex = index;
                      resetFilters();
                      await Provider.of<GyaanKarmayogiServices>(context,
                              listen: false)
                          .getAvailableSector(
                              showAllSectors: false,
                              type: "sector",
                              sectorName: [sectors[index].name.toLowerCase()]);
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      height: 70,
                      width: MediaQuery.of(context).size.width / 2.4,
                      decoration: BoxDecoration(
                          color: subSectorColors[index],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              width: 1.5,
                              color: selectedIndex != null &&
                                      selectedIndex == index
                                  ? AppColors.primaryOne
                                  : Colors.transparent)),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: SvgPicture.network(
                              sectors[index].iconUrl,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3.4,
                            child: Text(
                              Helper.capitalize(sectors[index].name),
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: AppColors.yellowBckground,
          child: SectorFilters(
              clearSearch: () {
                searchController.clear();
              },
              selectedCategory: selectedCategory,
              selectedSector: selectedCategory,
              selectedSubSector: selectedSubSector),
        ),
      ],
    );
  }

  resetFilters() {
    selectedCategory = null;
    selectedSector = null;
    selectedSubSector = null;
    searchController.clear();
    setState(() {});
  }
}
// Wrap(
//   alignment: WrapAlignment.spaceBetween,
//   runAlignment: WrapAlignment.spaceBetween,
//   runSpacing: 10,
//   spacing: MediaQuery.of(context).size.width / 15,
//   children: List.generate(
//     8,
//     (index) => Container(
//       padding: EdgeInsets.all(12),
//       height: 70,
//       width: MediaQuery.of(context).size.width / 2.4,
//       decoration: BoxDecoration(
//         color: Colors.red,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.car_crash),
//           SizedBox(
//             width: 4,
//           ),
//           Text(
//             "Car Crash",
//             style: GoogleFonts.lato(
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//               color: Colors.black,
//             ),
//           )
//         ],
//       ),
//     ),
//   ),
// )
