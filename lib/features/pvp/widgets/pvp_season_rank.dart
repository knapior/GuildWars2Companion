import 'package:flutter/material.dart';
import 'package:guildwars2_companion/features/pvp/models/season.dart';
import 'package:guildwars2_companion/features/pvp/models/standing.dart';
import 'package:guildwars2_companion/core/widgets/cached_image.dart';

class PvpSeasonRankBadge extends StatelessWidget {
  final PvpSeasonRank rank;
  final PvpStanding standing;

  PvpSeasonRankBadge({
    @required this.rank,
    @required this.standing
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CompanionCachedImage(
            height: 42.0,
            imageUrl: rank.overlay,
            color: Colors.white,
            iconSize: 20,
            fit: null,
          ),
          if (standing.current.rating != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: rank.tiers
                .map((r) => Container(
                  height: 12.0,
                  width: 12.0,
                  margin: EdgeInsets.symmetric(horizontal: 2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9.0),
                    border: Border.all(color: Colors.white, width: 2.0),
                    color: standing.current.rating >= r.rating ? Colors.white : null,
                  ),
                ))
                .toList(),
            )
        ],
      ),
    );
  }
}