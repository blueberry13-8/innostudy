import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work/firebase/additional_firebase_functions.dart';
import 'package:work/firebase_functions.dart';
import 'package:work/folder.dart';
import 'package:work/group.dart';
import 'package:work/permission_system/permission_object.dart';
import 'package:work/permission_system/permissions_entity.dart';
import 'package:work/permission_system/permissions_functions.dart';

void main() {
  //Setup firestore for testing
  appFirebase = FakeFirebaseFirestore();

  //Test groups
  Group testGroup1 =
      Group(groupName: "group1", folders: [], creator: "user1@gmail.com");

  //Test folders
  Folder testFolder = Folder(
      files: [],
      folders: [],
      parentGroup: testGroup1,
      folderName: "folderNested",
      withFolders: true,
      creator: "user1@gmail.com");

  test("Test on attaching permissions to group/folder", () async {
    await addGroup(testGroup1);
    await addFolder(testGroup1, testFolder, []);

    List<Folder> folders = querySnapshotToFoldersList(
        await appFirebase
            .collection('groups')
            .doc(testGroup1.groupName)
            .collection('folders')
            .get(),
        testGroup1);
    folders.first.parentGroup = testGroup1;

    PermissionableObject handledFolder =
        PermissionableObject.fromFolder(folders.first);
    PermissionableObject handledGroup =
        PermissionableObject.fromGroup(testGroup1);

    await attachPermissionRules(
        PermissionEntity(false, ["papa@gmail.com"], "123"), handledGroup, []);
    await attachPermissionRules(
        PermissionEntity(true, ["a1@gmail.com", "a2@gmail.com"], "qwe"),
        handledFolder, []);
    List<PermissionEntity> entities1 = querySnapshotToListOfPermissionEntities(
        await appFirebase.collection("groups").get());
    List<PermissionEntity> entities2 = querySnapshotToListOfPermissionEntities(
        await appFirebase
            .collection("groups")
            .doc(testGroup1.groupName)
            .collection("folders")
            .get());

    expect(entities1.length, 1);
    expect(entities1[0].allowAll, false);
    expect(entities1[0].password, "123");
    expect(entities1[0].owners, ["papa@gmail.com"]);
    expect(entities2.length, 1);
    expect(entities2[0].allowAll, true);
    expect(entities2[0].password, "qwe");
    expect(entities2[0].owners, ["a1@gmail.com", "a2@gmail.com"]);
  });

  test("Test for adding/removing users from database", () async {
    await addRegisteredUser("papa1@gmail.com");
    await addRegisteredUser("papa2@gmail.com");
    await addRegisteredUser("papa3@gmail.com");

    List<String> userEmails = await getUsersEmails();

    expect(
        userEmails, ["papa1@gmail.com", "papa2@gmail.com", "papa3@gmail.com"]);
  });
}
