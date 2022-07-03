import 'package:flutter/cupertino.dart';

class FolderTypeSwitch extends StatefulWidget {
  FolderTypeSwitch({Key? key, required this.callback}) : super(key: key);

  bool withFolder = false;

  final Function(bool) callback;

  @override
  State<FolderTypeSwitch> createState() => _FolderTypeSwitchState();
}

class _FolderTypeSwitchState extends State<FolderTypeSwitch> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('With Files'),
        CupertinoSwitch(
            value: widget.withFolder,
            onChanged: (value) {
              widget.withFolder = !widget.withFolder;
              //debugPrint(withFolder.toString());
              setState(() {});
              widget.callback(widget.withFolder);
            }),
        const Text('With Folders'),
      ],
    );
  }
}
