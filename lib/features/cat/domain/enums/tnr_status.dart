/// TNR 状态枚举
enum TnrStatus {
  none('未绝育', 'Not Neutered'),
  earTip('已耳缺', 'Ear Tipped'),
  neutered('已绝育', 'Neutered');

  const TnrStatus(this.displayName, this.displayNameEn);

  final String displayName;
  final String displayNameEn;

  static TnrStatus fromString(String value) {
    return TnrStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TnrStatus.none,
    );
  }
}
