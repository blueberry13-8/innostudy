import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FolderTypeSwitch extends StatefulWidget {
  const FolderTypeSwitch({Key? key, required this.callback}) : super(key: key);

  final Function(bool) callback;

  @override
  State<FolderTypeSwitch> createState() => _FolderTypeSwitchState();
}

class _FolderTypeSwitchState extends State<FolderTypeSwitch> {
  bool withFolder = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'With Files',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 17,
          ),
        ),
        CupertinoSwitch(
          trackColor: Theme.of(context).focusColor,
          value: withFolder,
          onChanged: (value) {
            withFolder = !withFolder;
            setState(() {});
            widget.callback(withFolder);
          },
        ),
        Text(
          'With Folders',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 17,
          ),
        ),
      ],
    );
  }
}
