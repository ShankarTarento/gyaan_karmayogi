import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../data_models/gyaan_karmayogi_category_model.dart';
import '../../../data_models/gyaan_karmayogi_sector_model.dart';
import '../../../services/gyaan_karmayogi_services.dart';
import '../../../utils/app_colors.dart';
import '../filter_screen/filter_screen.dart';

class SearchField extends StatefulWidget {
  final Function(Map<String, dynamic>) applyFilter;
  final String token;
  final String wid;
  final String apiKey;
  final String apiUrl;
  final String rootOrgId;
  final String baseUrl;
  final String selectedCategory;
  final Map<String, dynamic> translatedWords;
  const SearchField(
      {Key key,
      @required this.translatedWords,
      @required this.applyFilter,
      @required this.token,
      @required this.wid,
      @required this.apiUrl,
      @required this.apiKey,
      @required this.baseUrl,
      @required this.selectedCategory,
      @required this.rootOrgId})
      : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  // @override
  // void initState() {
  //   getData();
  //   // TODO: implement initState
  //   super.initState();
  // }

  // List<FilterModel> sectors = [];
  // List<FilterModel> subSector = [];
  // List<FilterModel> categories = [];
  // List<String> selectedSectors = [];
  // List<String> selectedSubSectors = [];
  // String selectedCategory;

  getData() async {
    // sectors = await Provider.of<GyaanKarmayogiServices>(context, listen: false)
    //     .getAvailableSector(
    //         type: "sector",
    //         authToken: widget.token,
    //         apiUrl: widget.apiUrl,
    //         wid: widget.wid,
    //         apiKey: widget.apiKey,
    //         baseUrl: widget.baseUrl,
    //         deptId: widget.rootOrgId);
    // subSector =
    //     await Provider.of<GyaanKarmayogiServices>(context, listen: false)
    //         .getAvailableSector(
    //             type: "subSector",
    //             authToken: widget.token,
    //             apiUrl: widget.apiUrl,
    //             wid: widget.wid,
    //             apiKey: widget.apiKey,
    //             baseUrl: widget.baseUrl,
    //             deptId: widget.rootOrgId);
    // categories =
    //     await Provider.of<GyaanKarmayogiServices>(context, listen: false)
    //         .getAvailableSector(
    //             type: "",
    //             authToken: widget.token,
    //             apiUrl: widget.apiUrl,
    //             wid: widget.wid,
    //             apiKey: widget.apiKey,
    //             baseUrl: widget.baseUrl,
    //             deptId: widget.rootOrgId);
    // setState(() {});
  }

  // Map<String, dynamic> searchFilter;
  // List<GyaanKarmayogiSector> availableSectors;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 40,
          width: MediaQuery.of(context).size.width / 1.1,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(40.0),
              ),
              contentPadding: const EdgeInsets.only(left: 12, right: 12),
              hintText: widget.translatedWords["searchInGyaanKarmayogi"] ??
                  'Search in Gyaan Karmayogi',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.greys87,
              ),
              hintStyle: GoogleFonts.lato(
                fontSize: 12,
                color: AppColors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            onSubmitted: (value) {
              //  searchFilter["query"] = value;
              if (value != null && value != "") {
                widget.applyFilter({"query": value});
              }
            },
          ),
        ),
      ],
    );
  }
}
