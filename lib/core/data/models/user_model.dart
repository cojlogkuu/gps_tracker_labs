class UserModel {
  final String id;
  final String fullName;
  final String email;
  final double? baseLatitude;
  final double? baseLongitude;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.baseLatitude,
    this.baseLongitude,
  });

  bool get hasBaseCoords => baseLatitude != null && baseLongitude != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'baseLatitude': baseLatitude,
    'baseLongitude': baseLongitude,
  };

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'] as String,
    fullName: j['fullName'] as String,
    email: j['email'] as String,
    baseLatitude: (j['baseLatitude'] as num?)?.toDouble(),
    baseLongitude: (j['baseLongitude'] as num?)?.toDouble(),
  );
}
