import 'package:flutter/material.dart';

class BottomStickyActionBar extends StatelessWidget {
  const BottomStickyActionBar({
    Key key,
    this.children,
  }) : super(key: key);

  final children;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      bottom: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          decoration: BoxDecoration(
              border: Border(top: BorderSide()), color: Colors.white),
          width: MediaQuery.of(context).size.width,
          child: Row(children: children),
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

// BottomStickyActionBar(
//   children: <Widget>[
//     BottomStickyActionItem(
//       child: Icon(
//         FontAwesomeIcons.bold,
//         size: 16,
//       ),
//       callback: () => addCharacterAndMoveCaret(
//         character: '****',
//         offset: 2,
//       ),
//     ),
//     BottomStickyActionItem(
//       child: Icon(
//         FontAwesomeIcons.italic,
//         size: 16,
//       ),
//       callback: () => addCharacterAndMoveCaret(
//         character: '**',
//         offset: 1,
//       ),
//     ),
//     BottomStickyActionItem(
//       child: Icon(
//         FontAwesomeIcons.strikethrough,
//         size: 16,
//       ),
//       callback: () => addCharacterAndMoveCaret(
//         character: '~~',
//         offset: 1,
//       ),
//     ),
//     BottomStickyActionItem(
//       child: Icon(
//         FontAwesomeIcons.quoteLeft,
//         size: 16,
//       ),
//       callback: () => addCharacterAndMoveCaret(
//         character: '> ',
//       ),
//     ),
//     BottomStickyActionItem(
//       child: Icon(
//         FontAwesomeIcons.hashtag,
//         size: 16,
//       ),
//       callback: () =>
//           addCharacterAndMoveCaret(character: '#'),
//     ),
//     BottomStickyActionItem(
//       child: Icon(
//         FontAwesomeIcons.listUl,
//         size: 16,
//       ),
//       callback: () =>
//           addCharacterAndMoveCaret(character: '- '),
//     ),
//     BottomStickyActionItem(
//       child: Icon(
//         FontAwesomeIcons.listOl,
//         size: 16,
//       ),
//       callback: () =>
//           addCharacterAndMoveCaret(character: '1. '),
//     ),
//     BottomStickyActionItem(
//       child: Icon(
//         FontAwesomeIcons.checkSquare,
//         size: 16,
//       ),
//       callback: () =>
//           addCharacterAndMoveCaret(character: '- [ ] '),
//     ),
//   ],
// )
