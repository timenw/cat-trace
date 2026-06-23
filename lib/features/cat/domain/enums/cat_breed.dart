/// 猫咪品种枚举
enum CatBreed {
  unknown('未知', 'Unknown'),
  domesticShorthair('中华田园猫', 'Domestic Shorthair'),
  domesticLonghair('中华田园长毛猫', 'Domestic Longhair'),
  siamese('暹罗猫', 'Siamese'),
  persian('波斯猫', 'Persian'),
  britishShorthair('英短', 'British Shorthair'),
  americanShorthair('美短', 'American Shorthair'),
  ragdoll('布偶猫', 'Ragdoll'),
  scottishFold('折耳猫', 'Scottish Fold'),
  maineCoon('缅因猫', 'Maine Coon'),
  bengal('孟加拉猫', 'Bengal'),
  russianBlue('俄罗斯蓝猫', 'Russian Blue'),
  norwegianForest('挪威森林猫', 'Norwegian Forest'),
  exoticShorthair('异国短毛猫', 'Exotic Shorthair'),
  mixed('混种', 'Mixed');

  const CatBreed(this.displayName, this.displayNameEn);

  final String displayName;
  final String displayNameEn;

  static CatBreed fromString(String value) {
    return CatBreed.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CatBreed.unknown,
    );
  }
}
