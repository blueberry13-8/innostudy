import 'package:flutter/material.dart';
class PopUpWindow extends StatelessWidget {
  final String creator;
  final String description;

  const PopUpWindow({Key? key, required this.creator, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
        backgroundColor: Theme.of(context).focusColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        title: Column(
          children: [
            Center(
                child: Text(
                  'Created by:',
                  style: Theme.of(context).textTheme.bodyText1,
                )),
             Center(
                child: Text(
                  creator,
                  style: Theme.of(context).textTheme.bodyText1,
                )),
            const SizedBox(height: 5,),
            Divider(height: 10, color: Theme.of(context).backgroundColor, thickness: 2,),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ));
  }
}
