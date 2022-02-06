import 'package:flutter/material.dart';
import 'package:rishtpak/widgets/default_card_border.dart';
import 'package:shimmer/shimmer.dart';

class LoadingCard extends StatelessWidget {
  final double? iconSize;

  const LoadingCard({this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      clipBehavior: Clip.antiAlias,
      shape: defaultCardBorder(),
      child: Shimmer.fromColors(
          child: Icon(Icons.favorite_border, size: iconSize ?? 150),
          baseColor: Colors.grey.withAlpha(70),
          highlightColor: Theme.of(context).accentColor),
    );
  }
}
