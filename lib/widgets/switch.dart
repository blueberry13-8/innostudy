import 'package:flutter/cupertino.dart';

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
        const Text('With Files'),
        CupertinoSwitch(
            value: withFolder,
            onChanged: (value) {
              withFolder = !withFolder;
              //debugPrint(withFolder.toString());
              setState(() {});
              widget.callback(withFolder);
            }),
        const Text('With Folders'),
      ],
    );
  }
}
