class PermissionEntity {
  bool allowAll;
  String password;
  final List<String> owners;

  PermissionEntity(this.allowAll, this.owners, this.password);
}

PermissionEntity getStandartPermissionSet() => PermissionEntity(false, [], "");
