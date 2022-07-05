import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work/widgets/switch.dart';

void main() {
  testWidgets("Test our custom folder type switcher widget",
      ((widgetTester) async {
    bool flag = false;
    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(body: FolderTypeSwitch(callback: (value) {
        flag = value;
      })),
    ));
    var actualSwitcher = find.byType(CupertinoSwitch);

    //Checks if cupertino switcher generated
    expect(actualSwitcher, findsOneWidget);

    //Checking switching
    await widgetTester.tap(actualSwitcher);
    expect(flag, true);

    await widgetTester.tap(actualSwitcher);
    expect(flag, false);
  }));
}
