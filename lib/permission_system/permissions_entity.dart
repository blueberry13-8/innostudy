class PermissionEntity {
  bool allowAll;
  final List<String> owners;

  PermissionEntity(this.allowAll, this.owners);
}

PermissionEntity STANDART_PERMISSIONS_SET = PermissionEntity(true, []);
