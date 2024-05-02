import 'package:flutter/material.dart';
import 'package:gyaan_karmayogi_resource_list/utils/app_colors.dart';

class CardSkeletonLoading extends StatefulWidget {
  const CardSkeletonLoading({Key key}) : super(key: key);

  @override
  _CardSkeletonLoadingState createState() => _CardSkeletonLoadingState();
}

class _CardSkeletonLoadingState extends State<CardSkeletonLoading>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Color> animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    animation = TweenSequence<Color>(
      [
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey08,
            end: AppColors.grey16,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey08,
            end: AppColors.grey16,
          ),
        ),
      ],
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.repeat();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Container(
          margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
          height: 361,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey16, width: 1),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 217,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                  color: animation.value,
                ),
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(8),
                    height: 18,
                    width: MediaQuery.of(context).size.width / 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: animation.value,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8),
                    height: 18,
                    width: MediaQuery.of(context).size.width / 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: animation.value,
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.all(8),
                height: 18,
                width: MediaQuery.of(context).size.width / 1.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: animation.value,
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                height: 18,
                width: MediaQuery.of(context).size.width / 1.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: animation.value,
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                height: 18,
                width: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: animation.value,
                ),
              )
            ],
          )),
    );
  }
}
