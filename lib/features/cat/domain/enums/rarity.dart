/// 稀有度枚举
enum Rarity {
  common('普通', 'Common', 0xFF9E9E9E),
  uncommon('稀有', 'Uncommon', 0xFF4CAF50),
  rare('罕见', 'Rare', 0xFF2196F3),
  epic('史诗', 'Epic', 0xFF9C27B0),
  legendary('传说', 'Legendary', 0xFFFF9800);

  const Rarity(this.displayName, this.displayNameEn, this.colorValue);

  final String displayName;
  final String displayNameEn;
  final int colorValue;

  static Rarity fromString(String value) {
    return Rarity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Rarity.common,
    );
  }

  /// 根据已有猫咪数量计算稀有度
  static Rarity calculate(int totalCats) {
    if (totalCats >= 50) return Rarity.legendary;
    if (totalCats >= 20) return Rarity.epic;
    if (totalCats >= 10) return Rarity.rare;
    if (totalCats >= 5) return Rarity.uncommon;
    return Rarity.common;
  }
}
