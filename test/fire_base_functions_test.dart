import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:work/firebase/additional_firebase_functions.dart';
import 'package:work/firebase_functions.dart';
import 'package:work/folder.dart';
import 'package:work/group.dart';

//This module contains tests for adding/removing folders and groups from database
//Also tests the parsing system

void main() {
  //Setup firestore for testing
  appFirebase = FakeFirebaseFirestore();

  //Test groups
  Group testGroup1 =
      Group(groupName: "group1", folders: [], creator: "user1@gmail.com");
  Group testGroup2 =
      Group(groupName: "group2", folders: [], creator: "user2@gmail.com");

  //Test folders
  Folder testFolderNested = Folder(
      files: [],
      folders: [],
      parentGroup: testGroup1,
      folderName: "folderNested",
      withFolders: true,
      creator: "user1@gmail.com");
  Folder testFolderFile = Folder(
      files: [],
      folders: [],
      parentGroup: testGroup1,
      folderName: "folderFiles",
      withFolders: false,
      creator: "user1@gmail.com");

  Folder internalFolder = Folder(
      files: [],
      folders: [],
      parentGroup: testGroup1,
      folderName: "internal",
      withFolders: false,
      creator: "user1@gmail.com");

  appFirebase.collection("groups");

  test("Test for adding group and query snapshot parser", () async {
    await addGroup(testGroup1);
    await addGroup(testGroup2);
    List<Group> groups =
        querySnapshotToGroupList(await appFirebase.collection('groups').get());
    expect(groups.length, 2);
  });

  test("Test for nested folders and file folders (Also query snapshot parser)",
      () async {
    await addFolder(testGroup1, testFolderNested, []);
    await addFolder(testGroup1, testFolderFile, []);

    List<Folder> folders = querySnapshotToFoldersList(
        await appFirebase
            .collection('groups')
            .doc(testGroup1.groupName)
            .collection('folders')
            .get(),
        testGroup1);

    expect(folders.length, 2);

    //Testing nested folders
    await addFolder(testGroup1, internalFolder, [testFolderNested]);

    var ref = appFirebase
        .collection('groups')
        .doc(testGroup1.groupName)
        .collection('folders')
        .doc(testFolderNested.folderName)
        .collection("folders");
    folders = querySnapshotToFoldersList(await ref.get(), testGroup1);

    expect(folders[0].folderName, "internal");
  });

  test("Deleting groups, folders", () async {
    await deleteFolder(testGroup1, testFolderNested, []);
    List<Folder> folders = querySnapshotToFoldersList(
        await appFirebase
            .collection('groups')
            .doc(testGroup1.groupName)
            .collection('folders')
            .get(),
        testGroup1);

    expect(folders.length, 1);

    await deleteGroup(testGroup1);
    List<Group> groups =
        querySnapshotToGroupList(await appFirebase.collection('groups').get());
    expect(groups.length, 1);
  });
}
