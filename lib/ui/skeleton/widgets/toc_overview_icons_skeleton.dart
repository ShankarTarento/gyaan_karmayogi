import 'package:flutter/material.dart';

import '../index.dart';

class TabOverviewIconSkeleton extends StatelessWidget {
  final Color color;

  const TabOverviewIconSkeleton({Key key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
            height: 55,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GetItems(color: color),
              GetItems(color: color),
              GetItems(color: color),
              GetItems(color: color),
              GetItems(color: color),
            ])));
  }
}

class GetItems extends StatelessWidget {
  const GetItems({
    Key key,
    @required this.color,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        children: [
          ContainerSkeleton(
            height: 16,
            width: 20,
            color: color,
          ),
          SizedBox(height: 8),
          ContainerSkeleton(
            height: 16,
            width: 60,
            color: color,
          ),
        ],
      ),
    );
  }
}
