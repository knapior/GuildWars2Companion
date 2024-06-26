import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guildwars2_companion/core/utils/guild_wars.dart';
import 'package:guildwars2_companion/core/widgets/cached_image.dart';
import 'package:guildwars2_companion/core/widgets/coin.dart';
import 'package:guildwars2_companion/features/error/widgets/error.dart';
import 'package:guildwars2_companion/core/widgets/info_row.dart';
import 'package:guildwars2_companion/features/item/models/item.dart';
import 'package:guildwars2_companion/features/item/pages/item.dart';
import 'package:guildwars2_companion/features/trading_post/bloc/bloc.dart';
import 'package:guildwars2_companion/features/trading_post/models/listing_offer.dart';
import 'package:guildwars2_companion/features/trading_post/models/transaction.dart';

class TradingPostItemPage extends StatelessWidget {
  final Item item;
  final int orderValue;

  TradingPostItemPage({
    @required this.item,
    this.orderValue,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.red : Theme.of(context).cardColor,
          elevation: 0.0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 4.0),
                child: Container(
                  width: 28,
                  height: 28,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: CompanionCachedImage(
                      imageUrl: item.icon,
                      color: Colors.white,
                      iconSize: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              )
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                FontAwesomeIcons.infoCircle,
                size: 20.0,
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ItemPage(
                  item: item,
                ),
              )),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Material(
              color: Theme.of(context).brightness == Brightness.light ? Colors.red : Theme.of(context).cardColor,
              elevation: Theme.of(context).brightness == Brightness.light ? 4.0 : 0.0,
              child: TabBar(
                indicatorColor: Colors.white,
                tabs: [
                  Tab(
                    child: Text(
                      'Buyers',
                      style: TextStyle(
                        fontSize: 16.0
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Sellers',
                      style: TextStyle(
                        fontSize: 16.0
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<TradingPostBloc, TradingPostState>(
                builder: (context, state) {
                  if (state is ErrorTradingPostState) {
                    return Center(
                      child: CompanionError(
                        title: 'the listings',
                        onTryAgain: () =>
                          BlocProvider.of<TradingPostBloc>(context).add(LoadTradingPostEvent()),
                      ),
                    );
                  }

                  if (state is LoadedTradingPostState && state.hasError) {
                    return Center(
                      child: CompanionError(
                        title: 'the listings',
                        onTryAgain: () =>
                          BlocProvider.of<TradingPostBloc>(context).add(LoadTradingPostListingsEvent(
                            itemId: item.id,
                          )),
                      ),
                    );
                  }

                  if (state is LoadedTradingPostState) {
                    TradingPostTransaction tradingPostTransaction = _getTradingPostTransaction(state);

                    if (tradingPostTransaction != null && !tradingPostTransaction.loading && tradingPostTransaction.listing != null) {
                      return TabBarView(
                        children: <Widget>[
                          _ListingTab(
                            offers: tradingPostTransaction.listing.buys,
                            type: 'Ordered',
                            errorMessage: 'No orders found',
                            item: item,
                            orderValue: orderValue,
                          ),
                          _ListingTab(
                            offers: tradingPostTransaction.listing.sells,
                            type: 'Available',
                            errorMessage: 'No items found',
                            item: item,
                            orderValue: orderValue,
                          ),
                        ],
                      );
                    }
                    
                  }

                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TradingPostTransaction _getTradingPostTransaction(LoadedTradingPostState state) {
    TradingPostTransaction transaction;
    [
      state.buying,
      state.selling,
      state.bought,
      state.sold
    ].forEach((transactionList) {
      if (transaction == null) {
        transaction = transactionList.firstWhere((t) => t.itemId == item.id, orElse: () => null);
      }
    });

    return transaction;
  }
}

class _ListingTab extends StatelessWidget {
  final List<ListingOffer> offers;
  final Item item;
  final int orderValue;
  final String type;
  final String errorMessage;

  _ListingTab({
    @required this.offers,
    @required this.item,
    @required this.orderValue,
    @required this.type,
    @required this.errorMessage
  });

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return RefreshIndicator(
        backgroundColor: Theme.of(context).accentColor,
        color: Theme.of(context).cardColor,
        onRefresh: () async {
          BlocProvider.of<TradingPostBloc>(context).add(LoadTradingPostListingsEvent(
            itemId: item.id,
          ));
          await Future.delayed(Duration(milliseconds: 200), () {});
        },
        child: ListView(
          children: <Widget>[
            Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      backgroundColor: Theme.of(context).accentColor,
      color: Theme.of(context).cardColor,
      onRefresh: () async {
        BlocProvider.of<TradingPostBloc>(context).add(LoadTradingPostListingsEvent(
          itemId: item.id,
        ));
        await Future.delayed(Duration(milliseconds: 200), () {});
      },
      child: ListView(
        children: offers.map((o) => Container(
          color: o.unitPrice == orderValue ? (
            Theme.of(context).brightness == Brightness.light ? Colors.red[100] : Colors.white24
          ) : null,
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: CompanionInfoRow(
            header: '${GuildWarsUtil.intToString(o.quantity)} $type',
            widget: CompanionCoin(o.unitPrice),
          ),
        ))
        .toList(),
      ),
    );
  }
}