import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../constants/index.dart';
import '../../respositories/_respositories/chatbot_repository.dart';
import '_common/page_loader.dart';

class ChatbotBottomSuggestion extends StatefulWidget {
  @override
  ChatbotBottomSuggestionState createState() => ChatbotBottomSuggestionState();
}

class ChatbotBottomSuggestionState extends State<ChatbotBottomSuggestion> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> getCategory(context) async {
    try {
      return Provider.of<ChatbotRepository>(context, listen: false)
          .infoBottomSuggestions;
    } catch (err) {
      print(err);
      return err;
    }
  }

  _getListData(categoryList) {
    List<Widget> widgets = [];

    widgets.add(Container(
        padding: EdgeInsets.only(left: 12, bottom: 1),
        child: ElevatedButton(
          onPressed: () {},
          child: Text("Show all topics"),
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21.0)),
              textStyle: GoogleFonts.lato(letterSpacing: 0.5, fontSize: 16),
              elevation: 0,
              backgroundColor: AppColors.grey04,
              foregroundColor: AppColors.greys87,
              side: BorderSide(width: 1.0, color: AppColors.grey16) // NEW
              ),
        )));

    for (int i = 0; i < categoryList.length; i++) {
      widgets.add(Container(
          height: 50,
          padding: EdgeInsets.only(left: 12, bottom: 1),
          child: ElevatedButton(
            onPressed: () {},
            child: Text(
              categoryList[i]['catName'],
              style: GoogleFonts.lato(
                  color: AppColors.greys87,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25,
                  height: 1.5),
            ),
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(21.0)),
                textStyle: GoogleFonts.lato(letterSpacing: 0.5, fontSize: 16),
                elevation: 0,
                foregroundColor: AppColors.grey04,
                backgroundColor: AppColors.grey04,
                side: BorderSide(width: 1.0, color: AppColors.grey16)),
          )));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 64,
          padding: EdgeInsets.only(top: 16, bottom: 8),
          child: FutureBuilder(
              future: getCategory(context),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  List<dynamic> list = snapshot.data;
                  return ListView(
                    padding: EdgeInsets.only(left: 16),
                    scrollDirection: Axis.horizontal,
                    children: _getListData(list),
                  );
                } else {
                  return PageLoader();
                }
              }),
        ),
      ],
    );
  }
}
