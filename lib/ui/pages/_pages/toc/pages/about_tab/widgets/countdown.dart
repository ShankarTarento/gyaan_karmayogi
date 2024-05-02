import 'dart:async';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Countdown extends StatefulWidget {
  final Batch batch;
  const Countdown({Key key, @required this.batch}) : super(key: key);

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Duration _remainingTime;
  Timer _timer;

  @override
  void initState() {
    print(DateTime.parse(widget.batch.startDate).difference(DateTime.now()));
    super.initState();
    _remainingTime = DateTime.parse(widget.batch.startDate.replaceAll('Z', ''))
        .difference(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime =
            DateTime.parse(widget.batch.startDate.replaceAll('Z', ''))
                .difference(DateTime.now());
        //  Provider.of<TocServices>(context, listen: false)
        //     .getBatchStartTime()
        //     .difference(DateTime.now());
        if (_remainingTime.inSeconds <= 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int days = _remainingTime.inDays;
    int hours = _remainingTime.inHours.remainder(24);
    int minutes = _remainingTime.inMinutes.remainder(60);

    return _remainingTime.inSeconds <= 0
        ? SizedBox(
            height: 37,
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16, top: 28, bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: AppColors.grey16,
                      ),
                    ),
                    Container(
                      child: Text(
                        AppLocalizations.of(context)
                            .mHomeBlendedProgramBatchStart,
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: AppColors.greys87),
                      ),
                      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.grey16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: AppColors.grey16,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCountdownPart(days,
                      AppLocalizations.of(context).mStaticDays.toUpperCase()),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16),
                    child: Text(":"),
                  ),
                  _buildCountdownPart(hours,
                      AppLocalizations.of(context).mStaticHours.toUpperCase()),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16),
                    child: Text(":"),
                  ),
                  _buildCountdownPart(
                      minutes,
                      AppLocalizations.of(context)
                          .mStaticMinutes
                          .toUpperCase()),
                ],
              ),
              SizedBox(
                height: 17,
              )
            ],
          );
  }

  Widget _buildCountdownPart(int value, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedFlipCounter(
          duration: Duration(milliseconds: 500),
          value: value,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w300,
            fontSize: 36,
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Text(
          unit,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: AppColors.black40,
          ),
        ),
      ],
    );
  }
}
