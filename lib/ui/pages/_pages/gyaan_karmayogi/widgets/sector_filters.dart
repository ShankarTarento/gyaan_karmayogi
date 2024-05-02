import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi/widgets/sectors_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../constants/_constants/color_constants.dart';
import '../../../../../util/helper.dart';
import '../services/gyaan_karmayogi_service.dart';

class SectorFilters extends StatefulWidget {
  String selectedSector;
  String selectedSubSector;
  String selectedCategory;
  Function() clearSearch;

  SectorFilters({
    Key key,
    @required this.clearSearch,
    @required this.selectedCategory,
    @required this.selectedSector,
    @required this.selectedSubSector,
  }) : super(key: key);

  @override
  State<SectorFilters> createState() => _SectorFiltersState();
}

class _SectorFiltersState extends State<SectorFilters> {
  List<String> sectors = [];
  List<String> subSectors = [];
  List<String> resourceCategories = [];

  @override
  void initState() {
    getSectors();
    // TODO: implement initState
    super.initState();
  }

  getSectors() async {
    sectors = await Provider.of<GyaanKarmayogiServices>(context, listen: false)
        .getAvailableSector(type: "sector", showAllSectors: false);
    resourceCategories =
        await Provider.of<GyaanKarmayogiServices>(context, listen: false)
            .getAvailableSector(type: "", showAllSectors: false);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).mStaticSectors,
            style: GoogleFonts.lato(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 40,
            child: DropdownButtonFormField2(
              isExpanded: true,
              decoration: InputDecoration(
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.only(bottom: 6),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.black16),
                  borderRadius: BorderRadius.circular(5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.black16),
                  borderRadius: BorderRadius.circular(5),
                ),
                filled: true,
              ),
              value: widget.selectedSector,
              items: sectors
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          Helper.capitalize(item),
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) async {
                widget.clearSearch();
                widget.selectedSubSector = null;
                widget.selectedCategory = null;

                widget.selectedSector = value;
                subSectors = await Provider.of<GyaanKarmayogiServices>(context,
                        listen: false)
                    .getAvailableSector(
                        showAllSectors: false,
                        type: "subSector",
                        sectorName: value == "All sectors" ? null : [value]);
                resourceCategories = await Provider.of<GyaanKarmayogiServices>(
                        context,
                        listen: false)
                    .getAvailableSector(
                        showAllSectors: false,
                        type: "",
                        sectorName: value == "All sectors" ? null : [value]);
                setState(() {});
              },
              buttonStyleData: ButtonStyleData(
                height: 40,
                padding: EdgeInsets.only(left: 10, right: 10),
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black45,
                ),
                iconSize: 20,
              ),
              dropdownStyleData: DropdownStyleData(
                padding: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.black16)),
              ),
              menuItemStyleData:
                  const MenuItemStyleData(padding: EdgeInsets.all(0)),
              hint: Row(
                children: [
                  Text(
                    "All sectors",
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          //
          //
          //
          Text(
            AppLocalizations.of(context).mStaticSubSectors,
            style: GoogleFonts.lato(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 40,
            child: DropdownButtonFormField2(
              isExpanded: true,
              decoration: InputDecoration(
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.only(bottom: 6),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.black16),
                  borderRadius: BorderRadius.circular(5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.black16),
                  borderRadius: BorderRadius.circular(5),
                ),
                filled: true,
              ),
              value: widget.selectedSubSector,
              items: widget.selectedSector != null
                  ? subSectors
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              Helper.capitalize(item),
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ))
                      .toList()
                  : [],
              onChanged: (value) async {
                widget.selectedCategory = null;

                widget.selectedSubSector = value;
                resourceCategories = await Provider.of<GyaanKarmayogiServices>(
                        context,
                        listen: false)
                    .getAvailableSector(
                        type: "", subSectorName: value, showAllSectors: false);
                setState(() {});
              },
              buttonStyleData: ButtonStyleData(
                height: 40,
                padding: EdgeInsets.only(left: 10, right: 10),
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black45,
                ),
                iconSize: 20,
              ),
              dropdownStyleData: DropdownStyleData(
                padding: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.black16)),
              ),
              menuItemStyleData:
                  const MenuItemStyleData(padding: EdgeInsets.all(0)),
              hint: Row(
                children: [
                  Text(
                    "All sub-sectors",
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),

          Text(
            AppLocalizations.of(context).mStaticCategories,
            style: GoogleFonts.lato(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 40,
            child: DropdownButtonFormField2(
              isExpanded: true,
              decoration: InputDecoration(
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.only(bottom: 6),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.black16),
                  borderRadius: BorderRadius.circular(5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.black16),
                  borderRadius: BorderRadius.circular(5),
                ),
                filled: true,
              ),
              value: widget.selectedCategory,
              items: resourceCategories
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          Helper.capitalize(
                            item,
                          ),
                          textAlign: TextAlign.left,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                widget.selectedCategory = value;
                setState(() {});
                Provider.of<GyaanKarmayogiServices>(context, listen: false)
                    .setResourceCategories(resourceCategory: value);
                //provider.updateSelectedCategory(value);
              },
              buttonStyleData: ButtonStyleData(
                height: 40,
                padding: EdgeInsets.only(left: 10, right: 10),
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black45,
                ),
                iconSize: 20,
              ),
              dropdownStyleData: DropdownStyleData(
                padding: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.black16)),
              ),
              menuItemStyleData:
                  const MenuItemStyleData(padding: EdgeInsets.all(0)),
              hint: Row(
                children: [
                  Text(
                    "All categories",
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 16,
          ),
          // dropdown(
          //   title: "Categories",
          //   hint: "All categories",
          //   dropdownItems:
          //       context.watch<GyaanKarmayogiServices>().resourceCategoryFilters,
          //   onChanged: (value) {
          //     print(value);
          //   },
          //   selectedValue: selectedCategory,
          // )
        ],
      ),
    );
  }

  Widget dropdown(
      {@required String title,
      @required String hint,
      @required List dropdownItems,
      @required Function(String value) onChanged,
      @required String selectedValue}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        title,
        style: GoogleFonts.lato(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      const SizedBox(
        height: 10,
      ),
      SizedBox(
        height: 40,
        child: DropdownButtonFormField2(
          isExpanded: true,
          decoration: InputDecoration(
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.only(bottom: 6),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.black16),
              borderRadius: BorderRadius.circular(5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.black16),
              borderRadius: BorderRadius.circular(5),
            ),
            filled: true,
          ),
          value: selectedValue,
          items: dropdownItems
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            onChanged(value);
          },
          buttonStyleData: ButtonStyleData(
            height: 40,
            padding: EdgeInsets.only(left: 10, right: 10),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black45,
            ),
            iconSize: 20,
          ),
          dropdownStyleData: DropdownStyleData(
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: AppColors.black16)),
          ),
          menuItemStyleData:
              const MenuItemStyleData(padding: EdgeInsets.all(0)),
          hint: Row(
            children: [
              Text(
                hint,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 16,
      ),
    ]);
  }
}
