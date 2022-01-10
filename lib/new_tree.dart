import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:jseen/theme.dart';

class JTree extends StatefulWidget {
  final dynamic json;

  final JSeenTheme theme;

  const JTree(
    this.json, {
    Key? key,
    this.theme = const JSeenTheme(),
  }) : super(key: key);

  @override
  _JTreeState createState() => _JTreeState();
}

class _JTreeState extends State<JTree> {
  late List<TreeNode> nodes;

  bool failed = false;
  @override
  void initState() {
    super.initState();
    try {
      nodes = [mapEntryToNode(jsonDecode(widget.json))];
    } catch (e, s) {
      if (kDebugMode) {
        print('encoding failed: $e\n$s');
      }
      failed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TreeView(
      nodes: nodes,
    );
  }

  TreeNode mapEntryToNode(dynamic entry) {
    if (entry is Map) {
      return TreeNode(
        content: SizedBox.shrink(),
        children: entry.entries.map(mapEntryToNode).toList(),
      );
    } else if (entry is List) {
      return TreeNode(
        content: SizedBox.shrink(),
        children: entry.map(mapEntryToNode).toList(),
      );
    } else if (entry is MapEntry) {
      if (entry.value is Map) {
        return TreeNode(
            content: Text('${entry.key}', style: widget.theme.keyStyle),
            children:
                (entry.value as Map).entries.map(mapEntryToNode).toList());
      } else if (entry.value is List) {
        return TreeNode(
            content: Text('${entry.key}', style: widget.theme.keyStyle),
            children: (entry.value as List).map(mapEntryToNode).toList());
      } else {
        return TreeNode(
          content: SelectableText.rich(
            TextSpan(
                text: '${entry.key}',
                style: widget.theme.keyStyle,
                children: [
                  const TextSpan(text: ': '),
                  TextSpan(
                      text: '${entry.value}',
                      style: mapValueToStyle(entry.value, widget.theme)),
                ]),
          ),
        );
      }
    } else {
      return TreeNode(
        content: SelectableText(
          '$entry',
          style: mapValueToStyle(entry, widget.theme),
        ),
      );
    }
  }
}

TextStyle mapValueToStyle(dynamic value, JSeenTheme theme) {
  if (value is String) {
    return theme.stringStyle;
  } else if (value is int) {
    return theme.intStyle;
  } else if (value is double) {
    return theme.doubleStyle;
  } else if (value is bool) {
    return theme.boolStyle;
  } else {
    return theme.nullStyle;
  }
}
