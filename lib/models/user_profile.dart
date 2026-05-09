class UserProfile {
  final String uid;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? email;
  final String? birthdate;
  final String? address;
  final String? phone;
  final String? photoUrl;

  UserProfile({
    required this.uid,
    this.firstName,
    this.lastName,
    this.middleName,
    this.email,
    this.birthdate,
    this.address,
    this.phone,
    this.photoUrl,
  });

  String get displayName {
    final parts = [firstName, middleName, lastName]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    return parts.isEmpty ? '' : parts.join(' ');
  }

  String get initials {
    final f = firstName?.isNotEmpty == true ? firstName![0].toUpperCase() : '';
    final l = lastName?.isNotEmpty == true ? lastName![0].toUpperCase() : '';
    return '$f$l'.isEmpty ? '?' : '$f$l';
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'first_name': firstName,
        'last_name': lastName,
        'middle_name': middleName,
        'email': email,
        'birthdate': birthdate,
        'address': address,
        'phone': phone,
        'photo_url': photoUrl,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        uid: map['uid'] as String? ?? '',
        firstName: map['first_name'] as String?,
        lastName: map['last_name'] as String?,
        middleName: map['middle_name'] as String?,
        email: map['email'] as String?,
        birthdate: map['birthdate'] as String?,
        address: map['address'] as String?,
        phone: map['phone'] as String?,
        photoUrl: map['photo_url'] as String?,
      );

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? birthdate,
    String? address,
    String? phone,
    String? photoUrl,
  }) =>
      UserProfile(
        uid: uid,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        middleName: middleName ?? this.middleName,
        email: email ?? this.email,
        birthdate: birthdate ?? this.birthdate,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        photoUrl: photoUrl ?? this.photoUrl,
      );
}
