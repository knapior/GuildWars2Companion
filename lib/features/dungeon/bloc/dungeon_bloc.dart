import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:guildwars2_companion/features/dungeon/models/dungeon.dart';
import 'package:guildwars2_companion/features/dungeon/repositories/dungeon.dart';
import 'package:meta/meta.dart';

part 'dungeon_event.dart';
part 'dungeon_state.dart';

class DungeonBloc extends Bloc<DungeonEvent, DungeonState> {
  final DungeonRepository dungeonRepository;

  DungeonBloc({
    this.dungeonRepository
  }): super(LoadingDungeonsState());

  @override
  Stream<DungeonState> mapEventToState(
    DungeonEvent event,
  ) async* {
    if (event is LoadDungeonsEvent) {
      try {
        yield LoadingDungeonsState();

        yield LoadedDungeonsState(await dungeonRepository.getDungeons(event.includeProgress), event.includeProgress);
      } catch(_) {
        yield ErrorDungeonsState(event.includeProgress);
      }
    }
  }
}
