import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guildwars2_companion/core/utils/assets.dart';
import 'package:guildwars2_companion/core/widgets/button.dart';
import 'package:guildwars2_companion/core/widgets/cached_image.dart';
import 'package:guildwars2_companion/core/widgets/coin.dart';
import 'package:guildwars2_companion/features/achievement/bloc/achievement_bloc.dart';
import 'package:guildwars2_companion/features/achievement/models/achievement.dart';
import 'package:guildwars2_companion/features/achievement/pages/achievement.dart';

class AchievementButton extends StatelessWidget {
  final bool includeProgression;
  final Achievement achievement;
  final String categoryIcon;
  final String levels;
  final String hero;

  AchievementButton({
    @required this.achievement,
    this.includeProgression = true,
    this.categoryIcon,
    this.levels,
    this.hero,
  });

  @override
  Widget build(BuildContext context) {
    return CompanionButton(
      title: achievement.name,
      height: 64.0,
      color: Colors.blueGrey,
      onTap: () {
        if (!achievement.loaded && !achievement.loading) {
          BlocProvider.of<AchievementBloc>(context).add(LoadAchievementDetailsEvent(
            achievementId: achievement.id,
          ));
        }

        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AchievementPage(
            achievement: achievement,
            categoryIcon: categoryIcon,
            hero: hero != null ? hero : achievement.id.toString(),
          )
        ));
      },
      leading: _Leading(
        achievement: achievement,
        categoryIcon: categoryIcon,
        includeProgression: includeProgression,
        hero: hero,
      ),
      trailing: _Trailing(achievement: achievement),
      subtitles: this.levels != null
        ? [this.levels]
        : null,
    );
  }
}

class _Trailing extends StatelessWidget {
  final Achievement achievement;

  _Trailing({
    @required this.achievement
  });

  @override
  Widget build(BuildContext context) {
    int points = 0;
    achievement.tiers.forEach((t) => points += t.points);

    if (achievement.maxPoints != null) {
      points = achievement.maxPoints;
    }

    int coin = 0;
    bool item = false;
    String region;
    bool title = false;

    if (achievement.rewards != null) {
      achievement.rewards.forEach((reward) {
        switch(reward.type) {
          case 'Coins':
            coin = reward.count;
            return;
          case 'Item':
            item = true;
            return;
          case 'Mastery':
            region = reward.region;
            return;
          case 'Title':
            title = true;
            return;
        }
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (points > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                points.toString(),
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Colors.white
                ),
              ),
              Container(width: 4.0,),
              Image.asset(
                Assets.progressionAp,
                height: 16.0,
              )
            ],
          ),
        if (item || title || region != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (region != null)
                Image.asset(
                  Assets.getMasteryAsset(region),
                  height: 16.0,
                  width: 16.0,
                ),
              if (item)
                Padding(
                  padding: region != null ? EdgeInsets.only(left: 4.0) : EdgeInsets.zero,
                  child: Image.asset(
                    Assets.progressionChest,
                    height: 16.0,
                    width: 16.0,
                  ),
                ),
              if (title)
                Padding(
                  padding: region != null || item ? EdgeInsets.only(left: 4.0) : EdgeInsets.zero,
                  child: Image.asset(
                    Assets.progressionTitle,
                    width: 16.0,
                    height: 16.0,
                  ),
                )
            ],
          ),
        if (coin > 0)
          CompanionCoin(
            coin,
            color: Colors.white,
            includeZero: false,
          ),
      ],
    );
  }
}

class _Leading extends StatelessWidget {
  final Achievement achievement;
  final bool includeProgression;
  final String categoryIcon;
  final String hero;

  _Leading({
    @required this.achievement,
    @required this.includeProgression,
    @required this.categoryIcon,
    this.hero
  });

  @override
  Widget build(BuildContext context) {
    if (!includeProgression) {
      return _Icon(
        achievement: achievement,
        categoryIcon: categoryIcon,
        hero: hero,
      );
    }

    int points = 0;
    achievement.tiers.forEach((t) => points += t.points);

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: 
            achievement.progress != null && !achievement.progress.done
            ? MainAxisAlignment.spaceBetween : MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            if (achievement.progress != null && achievement.progress.unlocked != null && !achievement.progress.unlocked)
              Icon(
                FontAwesomeIcons.lock,
                color: Colors.black87,
                size: 28.0,
              )
            else
              _Icon(
                achievement: achievement,
                categoryIcon: categoryIcon,
                hero: hero,
                height: 40.0
              ),
            if (achievement.progress != null && achievement.progress.current != null && achievement.progress.max != null)
              Builder(
                builder: (context) {
                  double progress = achievement.progress.repeated != null
                    ? achievement.progress.points / achievement.maxPoints
                    : achievement.progress.current / achievement.progress.max;

                  return Column(
                    children: <Widget>[
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      LinearProgressIndicator(
                        value: progress,
                        color: Colors.white,
                        backgroundColor: Colors.transparent,
                      )
                    ],
                  );
                },
              )
          ],
        ),
        if (achievement.progress != null && achievement.progress.done || (
          achievement.maxPoints != null && achievement.progress != null &&
          achievement.progress.repeated != null && achievement.progress.points >= achievement.maxPoints
        ))
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white60,
            alignment: Alignment.center,
            child: Icon(
              FontAwesomeIcons.check,
              color: Colors.black87,
              size: 28.0,
            ),
          ),
      ],
    );
  }
}

class _Icon extends StatelessWidget {
  final Achievement achievement;
  final String categoryIcon;
  final String hero;
  final double height;

  _Icon({
    @required this.achievement,
    @required this.categoryIcon,
    this.height = 48.0,
    this.hero,
  });

  @override
  Widget build(BuildContext context) {
    if (achievement.icon == null && categoryIcon != null && categoryIcon.contains('assets')) {
      return Hero(
        tag: hero != null ? hero : achievement.id.toString(),
        child: Image.asset(categoryIcon, height: height,),
      );
    }

    if (achievement.icon != null || categoryIcon != null) {
      return Hero(
        tag: hero != null ? hero : achievement.id.toString(),
        child: CompanionCachedImage(
          height: height,
          imageUrl: achievement.icon != null ? achievement.icon : categoryIcon,
          color: Colors.white,
          iconSize: 28,
          fit: BoxFit.fill,
        ),
      );
    }

    return Container();
  }
}