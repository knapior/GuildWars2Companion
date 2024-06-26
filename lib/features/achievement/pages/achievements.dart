import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guildwars2_companion/core/widgets/accent.dart';
import 'package:guildwars2_companion/core/widgets/appbar.dart';
import 'package:guildwars2_companion/features/error/widgets/error.dart';
import 'package:guildwars2_companion/core/widgets/list_view.dart';
import 'package:guildwars2_companion/features/achievement/bloc/achievement_bloc.dart';
import 'package:guildwars2_companion/features/achievement/models/achievement_category.dart';
import 'package:guildwars2_companion/features/achievement/widgets/achievement_button.dart';

class AchievementsPage extends StatelessWidget {
  final AchievementCategory achievementCategory;

  AchievementsPage(this.achievementCategory);

  @override
  Widget build(BuildContext context) {
    return CompanionAccent(
      lightColor: Colors.blueGrey,
      child: Scaffold(
        appBar: CompanionAppBar(
          title: achievementCategory.name,
          color: Colors.blueGrey,
        ),
        body: BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, state) {
            if (state is ErrorAchievementsState) {
              return Center(
                child: CompanionError(
                  title: 'the achievements',
                  onTryAgain: () =>
                    BlocProvider.of<AchievementBloc>(context).add(LoadAchievementsEvent(
                      includeProgress: state.includesProgress
                    )),
                ),
              );
            }

            if (state is LoadedAchievementsState) {
              AchievementCategory _achievementCategory = _getAchievementsCategory(state);

              if (_achievementCategory != null) {
                return RefreshIndicator(
                  backgroundColor: Theme.of(context).accentColor,
                  color: Theme.of(context).cardColor,
                  onRefresh: () async {
                    BlocProvider.of<AchievementBloc>(context).add(LoadAchievementsEvent(
                      includeProgress: state.includesProgress
                    ));
                    await Future.delayed(Duration(milliseconds: 200), () {});
                  },
                  child: CompanionListView(
                    children: _achievementCategory.achievementsInfo
                      .map((a) => AchievementButton(
                        achievement: a,
                        categoryIcon: _achievementCategory.icon,
                        includeProgression: state.includesProgress,
                      ))
                      .toList(),
                  ),
                );
              }
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  AchievementCategory _getAchievementsCategory(LoadedAchievementsState state) {
    AchievementCategory category;

    state.achievementGroups.forEach((group) {
      if (category == null) {
        category = group.categoriesInfo.firstWhere((t) => t.id == achievementCategory.id, orElse: () => null);
      }
    });

    return category;
  }
}