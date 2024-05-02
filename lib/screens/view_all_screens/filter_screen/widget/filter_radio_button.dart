import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyaan_karmayogi_resource_list/utils/app_colors.dart';
import 'package:gyaan_karmayogi_resource_list/utils/helper.dart';

import '../../../../data_models/gyaan_karmayogi_category_model.dart';

class FilterRadioButton extends StatefulWidget {
  final String title;
  final List<FilterModel> checkListItems;
  final ValueChanged<String> onChanged;
  final String searchHint;
  String selectedItem;

  FilterRadioButton({
    Key key,
    @required this.title,
    @required this.selectedItem,
    @required this.searchHint,
    @required this.checkListItems,
    @required this.onChanged,
  }) : super(key: key);

  @override
  State<FilterRadioButton> createState() => _FilterRadioButtonState();
}

class _FilterRadioButtonState extends State<FilterRadioButton> {
  List<FilterModel> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = widget.checkListItems;
  }

  void _filterList(String query) {
    setState(() {
      filteredItems = widget.checkListItems
          .where(
              (item) => item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("-----------------${widget.selectedItem}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 16,
        ),
        Text(
          widget.title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        SizedBox(
          height: 40,
          width: MediaQuery.of(context).size.width,
          child: TextField(
            onChanged: _filterList,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.grey08, width: 1),
                borderRadius: BorderRadius.circular(40.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.grey08, width: 1),
                borderRadius: BorderRadius.circular(40.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.grey08, width: 1),
                borderRadius: BorderRadius.circular(40.0),
              ),
              contentPadding: const EdgeInsets.only(left: 12, right: 12),
              hintText: widget.searchHint,
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
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Column(
          children: List.generate(
            filteredItems.length,
            (index) => InkWell(
              onTap: () {
                setState(() {
                  widget.selectedItem = filteredItems[index].title;
                });
                widget.onChanged(widget.selectedItem);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 20,
                child: Row(
                  children: [
                    Checkbox(
                      side:
                          const BorderSide(color: AppColors.black40, width: 1),
                      activeColor: AppColors.darkBlue,
                      value: widget.selectedItem == filteredItems[index].title,
                      onChanged: (value) {
                        setState(() {
                          widget.selectedItem = filteredItems[index].title;
                        });
                        widget.onChanged(widget.selectedItem);
                      },
                    ),
                    Text(
                      Helper.capitalize(filteredItems[index].title),
                      style: GoogleFonts.lato(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greys60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        )
      ],
    );
  }
}
