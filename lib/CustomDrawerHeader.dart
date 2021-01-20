// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:trimmz/globals.dart' as globals;

class _AccountPictures extends StatelessWidget {
  const _AccountPictures({
    Key key,
    this.currentAccountPicture,
    this.otherAccountsPictures,
  }) : super(key: key);

  final Widget currentAccountPicture;
  final List<Widget> otherAccountsPictures;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          top: 0.0,
          end: 0.0,
          child: Row(
            children: (otherAccountsPictures ?? <Widget>[]).take(3).map<Widget>((Widget picture) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 8.0),
                child: Semantics(
                  container: true,
                  child: Container(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    width: 48.0,
                    height: 48.0,
                    child: picture,
                 ),
                )
              );
            }).toList(),
          ),
        ),
        Positioned(
          top: 0.0,
          left: 0.0,
          child: Semantics(
            explicitChildNodes: true,
            child: Align(
              alignment: Alignment.centerLeft,
              // child: SizedBox(
              //   width: 62.0,
              //   height: 62.0,
              //   child: Container(
              //     child: currentAccountPicture,
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       border: Border.all(color: Colors.black)
              //     ),
              //   )
              // ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: currentAccountPicture
              )
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountDetails extends StatelessWidget {
  const _AccountDetails({
    Key key,
    @required this.accountName,
    @required this.accountUsername,
    this.onTap,
    this.isOpen,
  }) : super(key: key);

  final Widget accountName;
  final Widget accountUsername;
  final VoidCallback onTap;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasMaterialLocalizations(context));

    final ThemeData theme = Theme.of(context);
    final List<Widget> children = <Widget>[];

    if (accountName != null) {
      final Widget accountNameLine = LayoutId(
        id: _AccountDetailsLayout.accountName,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: DefaultTextStyle(
            style: theme.primaryTextTheme.bodyText1,
            overflow: TextOverflow.ellipsis,
            child: accountName,
          ),
        ),
      );
      children.add(accountNameLine);
    }

    if (accountUsername != null) {
      final Widget accountUsernameLine = LayoutId(
        id: _AccountDetailsLayout.accountUsername,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: DefaultTextStyle(
            style: theme.primaryTextTheme.bodyText2,
            overflow: TextOverflow.ellipsis,
            child: accountUsername,
          ),
        ),
      );
      children.add(accountUsernameLine);
    }

    if (onTap != null) {
      final MaterialLocalizations localizations = MaterialLocalizations.of(context);
      final Widget dropDownIcon = LayoutId(
        id: _AccountDetailsLayout.dropdownIcon,
        child: Semantics(
          container: true,
          button: true,
          onTap: onTap,
          child: SizedBox(
            height: _kAccountDetailsHeight,
            width: _kAccountDetailsHeight,
            child: Center(
              child: Icon(
                isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.white,
                semanticLabel: isOpen
                    ? localizations.hideAccountsLabel
                    : localizations.showAccountsLabel,
              ),
            ),
          ),
        ),
      );
      children.add(dropDownIcon);
    }

    Widget accountDetails = CustomMultiChildLayout(
      delegate: _AccountDetailsLayout(
        textDirection: Directionality.of(context),
      ),
      children: children,
    );

    if (onTap != null) {
      accountDetails = InkWell(
        onTap: onTap,
        child: accountDetails,
        excludeFromSemantics: true,
      );
    }

    return SizedBox(
      height: _kAccountDetailsHeight,
      child: accountDetails,
    );
  }
}

const double _kAccountDetailsHeight = 56.0;

class _AccountDetailsLayout extends MultiChildLayoutDelegate {

  _AccountDetailsLayout({ @required this.textDirection });

  static const String accountName = 'accountName';
  static const String accountUsername = 'accountUsername';
  static const String dropdownIcon = 'dropdownIcon';

  final TextDirection textDirection;

  @override
  void performLayout(Size size) {
    Size iconSize;
    if (hasChild(dropdownIcon)) {
      // place the dropdown icon in bottom right (LTR) or bottom left (RTL)
      iconSize = layoutChild(dropdownIcon, BoxConstraints.loose(size));
      positionChild(dropdownIcon, _offsetForIcon(size, iconSize));
    }

    final String bottomLine = hasChild(accountUsername) ? accountUsername : (hasChild(accountName) ? accountName : null);

    if (bottomLine != null) {
      final Size constraintSize = iconSize == null ? size : size - Offset(iconSize.width, 0.0);
      iconSize ??= const Size(_kAccountDetailsHeight, _kAccountDetailsHeight);

      // place bottom line center at same height as icon center
      final Size bottomLineSize = layoutChild(bottomLine, BoxConstraints.loose(constraintSize));
      final Offset bottomLineOffset = _offsetForBottomLine(size, iconSize, bottomLineSize);
      positionChild(bottomLine, bottomLineOffset);

      // place account name above account email
      if (bottomLine == accountUsername && hasChild(accountName)) {
        final Size nameSize = layoutChild(accountName, BoxConstraints.loose(constraintSize));
        positionChild(accountName, _offsetForName(size, nameSize, bottomLineOffset));
      }
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => true;

  Offset _offsetForIcon(Size size, Size iconSize) {
    switch (textDirection) {
      case TextDirection.ltr:
        return Offset(size.width - iconSize.width, size.height - iconSize.height);
      case TextDirection.rtl:
        return Offset(0.0, size.height - iconSize.height);
    }
    assert(false, 'Unreachable');
    return null;
  }

  Offset _offsetForBottomLine(Size size, Size iconSize, Size bottomLineSize) {
    final double y = size.height - 0.5 * iconSize.height - 0.5 * bottomLineSize.height;
    switch (textDirection) {
      case TextDirection.ltr:
        return Offset(0.0, y);
      case TextDirection.rtl:
        return Offset(size.width - bottomLineSize.width, y);
    }
    assert(false, 'Unreachable');
    return null;
  }

  Offset _offsetForName(Size size, Size nameSize, Offset bottomLineOffset) {
    final double y = bottomLineOffset.dy - nameSize.height;
    switch (textDirection) {
      case TextDirection.ltr:
        return Offset(0.0, y);
      case TextDirection.rtl:
        return Offset(size.width - nameSize.width, y);
    }
    assert(false, 'Unreachable');
    return null;
  }
}

/// A material design [Drawer] header that identifies the app's user.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [DrawerHeader], for a drawer header that doesn't show user accounts
///  * <https://material.google.com/patterns/navigation-drawer.html>
class CustomUserAccountsDrawerHeader extends StatefulWidget {
  /// Creates a material design drawer header.
  ///
  /// Requires one of its ancestors to be a [Material] widget.
  const CustomUserAccountsDrawerHeader({
    Key key,
    this.decoration,
    this.margin = const EdgeInsets.only(bottom: 8.0),
    this.currentAccountPicture,
    this.otherAccountsPictures,
    @required this.accountName,
    @required this.accountUsername,
    this.otherDetails,
    @required this.headerImage,
    this.onDetailsPressed
  }) : super(key: key);

  /// The header's background. If decoration is null then a [BoxDecoration]
  /// with its background color set to the current theme's primaryColor is used.
  final Decoration decoration;

  /// The margin around the drawer header.
  final EdgeInsetsGeometry margin;

  /// A widget placed in the upper-left corner that represents the current
  /// user's account. Normally a [CircleAvatar].
  final Widget currentAccountPicture;

  /// A list of widgets that represent the current user's other accounts.
  /// Up to three of these widgets will be arranged in a row in the header's
  /// upper-right corner. Normally a list of [CircleAvatar] widgets.
  final List<Widget> otherAccountsPictures;

  /// A widget that represents the user's current account name. It is
  /// displayed on the left, below the [currentAccountPicture].
  final Widget accountName;

  /// A widget that represents the email address of the user's current account.
  /// It is displayed on the left, below the [accountName].
  final Widget accountUsername;

  final Widget otherDetails;

  final ImageProvider<Object> headerImage;

  /// A callback that is called when the horizontal area which contains the
  /// [accountName] and [accountUsername] is tapped.
  final VoidCallback onDetailsPressed;

  @override
  _CustomUserAccountsDrawerHeaderState createState() => _CustomUserAccountsDrawerHeaderState();
}

class _CustomUserAccountsDrawerHeaderState extends State<CustomUserAccountsDrawerHeader> {
  bool _isOpen = false;

  void _handleDetailsPressed() {
    setState(() {
      _isOpen = !_isOpen;
    });
    widget.onDetailsPressed();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    return Semantics(
      container: true,
      label: MaterialLocalizations.of(context).signedInLabel,
      child: DrawerHeader(
        decoration: widget.decoration ?? BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        margin: widget.margin,
        padding: const EdgeInsetsDirectional.only(start: 0.0),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: widget.headerImage,
              fit: BoxFit.cover
            )
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.only(left: 16.0),
                color: globals.darkModeEnabled ? Color.fromARGB(230, 0, 0, 0) : Color.fromARGB(230, 255, 255, 255),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(top: 5, end: 16.0),
                          child: _AccountPictures(
                            currentAccountPicture: widget.currentAccountPicture,
                            otherAccountsPictures: widget.otherAccountsPictures,
                          ),
                        )
                      ),
                      _AccountDetails(
                        accountName: widget.accountName,
                        accountUsername: widget.accountUsername,
                        isOpen: _isOpen,
                        onTap: widget.onDetailsPressed == null ? null : _handleDetailsPressed,
                      ),
                      widget.otherDetails
                    ],
                  ),
                ),
              )
            )
          )
        )
      ),
    );
  }
}
