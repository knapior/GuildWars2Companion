import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guildwars2_companion/blocs/account/bloc.dart';
import 'package:guildwars2_companion/blocs/character/bloc.dart';
import 'package:guildwars2_companion/models/character/character.dart';
import 'package:guildwars2_companion/models/character/crafting.dart';
import 'package:guildwars2_companion/pages/character/equipment.dart';
import 'package:guildwars2_companion/pages/character/inventory.dart';
import 'package:guildwars2_companion/utils/guild_wars.dart';
import 'package:guildwars2_companion/utils/guild_wars_icons.dart';
import 'package:guildwars2_companion/widgets/button.dart';
import 'package:guildwars2_companion/widgets/error.dart';
import 'package:guildwars2_companion/widgets/header.dart';
import 'package:guildwars2_companion/widgets/info_box.dart';

class CharacterPage extends StatelessWidget {

  final Character _character;

  CharacterPage(this._character);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(accentColor: _character.professionColor),
      child: Scaffold(
        body: Column(
          children: <Widget>[
            CompanionHeader(
              includeBack: true,
              color: _character.professionColor,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 28,
                        height: 28,
                        child: Hero(
                          child: ColorFiltered(
                            child: CachedNetworkImage(
                              imageUrl: _character.professionInfo.iconBig,
                              placeholder: (context, url) => Theme(
                                data: Theme.of(context).copyWith(accentColor: Colors.white),
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Center(child: Icon(
                                FontAwesomeIcons.dizzy,
                                size: 20,
                                color: Colors.white,
                              )),
                              fit: BoxFit.contain,
                            ),
                            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcATop),
                          ),
                          tag: _character.name,
                        ),
                      ),
                      Text(
                        _character.name,
                        style: Theme.of(context).textTheme.title.merge(TextStyle(
                          color: Colors.white
                        ))
                      )
                    ],
                  ),
                  if (_character.titleName != null && _character.titleName.isNotEmpty)
                    Text(
                      _character.titleName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0
                      ),
                    ),
                  Container(height: 8.0,),
                  Container(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      runSpacing: 16.0,
                      children: <Widget>[
                        CompanionInfoBox(
                          header: 'Level',
                          text: _character.level.toString(),
                          loading: false,
                        ),
                        CompanionInfoBox(
                          header: 'Playtime',
                          text: GuildWarsUtil.calculatePlayTime(_character.age).toString() + 'h',
                          loading: false,
                        ),
                        CompanionInfoBox(
                          header: 'Deaths',
                          text: _character.deaths.toString(),
                          loading: false,
                        ),
                      ],
                    ),
                  ),
                  if (_character.crafting != null && _character.crafting.isNotEmpty)
                    _buildCrafting(_character.crafting)
                ],
              ),
            ),
            BlocBuilder<CharacterBloc, CharacterState>(
              builder: (context, state) {
                if (state is ErrorCharactersState) {
                  return Expanded(
                    child: Center(
                      child: CompanionError(
                        title: 'the character',
                        onTryAgain: () =>
                          BlocProvider.of<CharacterBloc>(context).add(LoadCharactersEvent()),
                      ),
                    ),
                  );
                }

                if (state is LoadedCharactersState) {
                  return _buildButtons(context, state);
                }

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCrafting(List<Crafting> crafting) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white, width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.only(top: 16.0),
      padding: EdgeInsets.only(top: 4.0),
      child: Column(
        children: <Widget>[
          Text(
            'Crafting disciplines',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0
            ),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: crafting
              .where((c) => GuildWarsUtil.validDisciplines().contains(c.discipline))
              .map((c) => Padding(
                padding: EdgeInsets.all(6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Image.asset('assets/crafting/${c.discipline.toLowerCase()}.png'),
                    Text(
                      c.rating.toString(),
                      style: TextStyle(
                        color: Colors.white
                      ),
                    )
                  ],
                ),
              ))
              .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, LoadedCharactersState characterState) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AuthenticatedState) {
          return MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: Expanded(
              child: RefreshIndicator(
                backgroundColor: Theme.of(context).accentColor,
                color: Colors.white,
                onRefresh: () async {
                  BlocProvider.of<CharacterBloc>(context).add(LoadCharactersEvent());
                  await Future.delayed(Duration(milliseconds: 200), () {});
                },
                child: ListView(
                  padding: EdgeInsets.only(top: 8.0),
                  children: <Widget>[
                    if (state.tokenInfo.permissions.contains('inventories')
                      && state.tokenInfo.permissions.contains('builds'))
                      CompanionButton(
                        color: Colors.teal,
                        onTap: () {
                          if (!characterState.itemsLoaded && !characterState.itemsLoading) {
                            BlocProvider.of<CharacterBloc>(context).add(LoadCharacterItemsEvent(characterState.characters));
                          }

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EquipmentPage(_character),
                          ));
                        },
                        title: 'Equipment',
                        leading: Icon(
                          GuildWarsIcons.equipment,
                          size: 48.0,
                          color: Colors.white,
                        ),
                      ),
                    if (state.tokenInfo.permissions.contains('inventories'))
                      CompanionButton(
                        color: Colors.indigo,
                        onTap: () {
                          if (!characterState.itemsLoaded && !characterState.itemsLoading) {
                            BlocProvider.of<CharacterBloc>(context).add(LoadCharacterItemsEvent(characterState.characters));
                          }

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => InventoryPage(_character),
                          ));
                        },
                        title: 'Inventory',
                        leading: Icon(
                          GuildWarsIcons.inventory,
                          size: 48.0,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        return Container();
      },
    );
  }
}
