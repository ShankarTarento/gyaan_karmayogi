import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../constants/index.dart';

class ReplayWidget extends StatefulWidget {
  final VoidCallback onPressed;
  const ReplayWidget({Key key, @required this.onPressed}) : super(key: key);

  @override
  State<ReplayWidget> createState() => _ReplayWidgetState();
}

class _ReplayWidgetState extends State<ReplayWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onPressed(),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: EdgeInsets.all(6),
          child: Text(
            AppLocalizations.of(context) != null
                ? AppLocalizations.of(context).mReplay
                : '',
            style: GoogleFonts.montserrat(
                color: AppColors.appBarBackground,
                fontWeight: FontWeight.w400,
                fontSize: 16,
                letterSpacing: 0.12),
          ),
        ),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(63),
            color: AppColors.greys87,
          ),
          child: Center(
            child: Icon(
              Icons.replay,
              size: 24,
              color: Colors.white,
            ),
          ),
        )
      ]),
    );
  }
}
