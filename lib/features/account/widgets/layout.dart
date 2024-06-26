import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guildwars2_companion/core/utils/assets.dart';
import 'package:guildwars2_companion/core/widgets/header.dart';

class TokenLayout extends StatelessWidget {
  final String darkThemeTitle;
  final Widget child;

  TokenLayout({
    @required this.child,
    this.darkThemeTitle = 'Api Keys'
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light
      ),
      child: Stack(
        children: <Widget>[
          _Footer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Header(darkThemeTitle: darkThemeTitle),
              Expanded(child: child)
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String darkThemeTitle;

  _Header({
    @required this.darkThemeTitle
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return CompanionHeader(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              Assets.tokenHeaderLogo,
              height: 64.0,
            ),
            Container(width: 8.0,),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'GW2 Companion',
                  style: Theme.of(context).textTheme.headline1.copyWith(
                    fontWeight: FontWeight.w500
                  ),
                ),
                if (darkThemeTitle != null)
                  Text(
                    darkThemeTitle,
                    style: Theme.of(context).textTheme.headline1.copyWith(
                      fontWeight: FontWeight.w300
                    ),
                  ),
              ],
            )
          ],
        ),
      );
    }

    return Stack(
      children: <Widget>[
        Image.asset(
          Assets.tokenHeader,
          height: 170.0,
          width: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Image.asset(
                Assets.tokenHeaderLogo,
                height: 72.0,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Container();
    }

    return Align(
      child: Image.asset(
        Assets.tokenFooter,
        width: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.bottomLeft,
      ),
      alignment: Alignment.bottomLeft,
    );
  }
}