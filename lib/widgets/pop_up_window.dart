import 'package:flutter/material.dart';

class PopUpWindow extends StatelessWidget {
  final String creator;
  final String description;

  const PopUpWindow(
      {Key? key, required this.creator, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).focusColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      title: Column(
        children: [
          Center(
            child: Text(
              'Created by:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Center(
            child: Text(
              creator,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          description != ''
              ? Divider(
                  height: 10,
                  color: Theme.of(context).colorScheme.background,
                  thickness: 2,
                )
              : const SizedBox(),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
