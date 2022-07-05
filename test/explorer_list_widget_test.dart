import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work/core/group.dart';
import 'package:work/permission_system/permission_object.dart';
import 'package:work/widgets/explorer_list_widget.dart';

//Test for the most complicated widget in our application.

void main() {
  testWidgets("Full test of explorer list widget", (widgetTester) async {
    List<PermissionableObject> listObjects = [];

    for (int i = 0; i < 3; i++) {
      listObjects.add(PermissionableObject.fromGroup(
          Group(creator: "123@gmail.com", groupName: "test$i", folders: [])));
    }
    int lastDeleted = -1;
    int lastOpened = -1;
    int lastEyePressed = -1;
    int lastSettingsOpened = -1;
    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: ExplorerList(
        listObjects: listObjects,
        objectIcon: Icons.abc,
        openSettingsCondition: (index) {
          if (index == 0) {
            return true;
          }
          return false;
        },
        readactorCondition: (index) {
          if (index == 1) {
            return true;
          }
          return false;
        },
        onDelete: (index) {
          lastDeleted = index;
        },
        onOpen: (index) {
          lastOpened = index;
        },
        onEyePressed: (index) {
          lastEyePressed = index;
        },
        onOpenSettings: (index) {
          lastSettingsOpened = index;
        },
      )),
    ));
    var objectLogo = find.byIcon(Icons.abc);
    expect(objectLogo, findsNWidgets(3));

    expect(find.text("test0"), findsOneWidget);
    expect(find.text("test1"), findsOneWidget);
    expect(find.text("test2"), findsOneWidget);

    var vertButton = find.byIcon(Icons.more_vert);
    expect(vertButton, findsOneWidget);
    var editButton = find.byIcon(Icons.edit);
    expect(editButton, findsOneWidget);
    var eyeButton = find.byIcon(Icons.remove_red_eye_outlined);
    expect(eyeButton, findsOneWidget);
    await widgetTester.tap(eyeButton);
    expect(lastEyePressed, 2);
    await widgetTester.tap(editButton);
    expect(lastEyePressed, 1);

    var button1 = find.byType(ListTile).at(0);
    var button2 = find.byType(ListTile).at(1);
    var button3 = find.byType(ListTile).at(2);

    await widgetTester.tap(button1);
    expect(lastOpened, 0);
    await widgetTester.tap(button2);
    expect(lastOpened, 1);
    await widgetTester.tap(button3);
    expect(lastOpened, 2);

    await widgetTester.tap(vertButton);
    await widgetTester.pumpAndSettle();

    var optionsPrivacySettings = find.text("Privacy settings");
    expect(optionsPrivacySettings, findsOneWidget);

    await widgetTester.tap(optionsPrivacySettings);
    await widgetTester.pumpAndSettle();
    expect(lastSettingsOpened, 0);

    await widgetTester.tap(vertButton);
    await widgetTester.pumpAndSettle();

    var optionDelete = find.text("Delete");
    expect(optionDelete, findsOneWidget);

    await widgetTester.tap(optionDelete);
    expect(lastDeleted, 0);
  });
}
