import 'package:flutter/material.dart';
import 'package:next_page/widgets/no_glow_scroll_behavior.dart';

class BottomStickyActionBar extends StatelessWidget {
  const BottomStickyActionBar({
    Key key,
    this.children,
  }) : super(key: key);

  final children;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: Positioned(
        left: 0.0,
        bottom: 1.0,
        width: MediaQuery.of(context).size.width,
        height: 40,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          decoration: BoxDecoration(
              border: Border(top: BorderSide()), color: Colors.white),
          width: MediaQuery.of(context).size.width,
          child: ListView(scrollDirection: Axis.horizontal, children: children),
        ),
      ),
    );
  }
}

class BottomStickyActionItem extends StatelessWidget {
  const BottomStickyActionItem({Key key, @required this.child, this.callback})
      : super(key: key);
  final Widget child;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: child,
      ),
    );
  }
}
