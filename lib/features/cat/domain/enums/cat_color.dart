/// 猫咪毛色枚举
enum CatColor {
  unknown('未知', 'Unknown'),
  orange('橘猫', 'Orange'),
  black('黑猫', 'Black'),
  white('白猫', 'White'),
  tabby('虎斑', 'Tabby'),
  calico('三花', 'Calico'),
  tuxedo('奶牛', 'Tuxedo'),
  gray('灰猫', 'Gray'),
  cream('奶油', 'Cream'),
  tortoiseshell('玳瑁', 'Tortoiseshell'),
  bicolor('双色', 'Bicolor'),
  pointed('重点色', 'Pointed'),
  mixed('混色', 'Mixed');

  const CatColor(this.displayName, this.displayNameEn);

  final String displayName;
  final String displayNameEn;

  static CatColor fromString(String value) {
    return CatColor.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CatColor.unknown,
    );
  }
}
