enum UserRole { mahasiswa, admin }

class UserModel {
  final String id;
  final String nim;
  final String fullName;
  final String email;
  final String fakultas;
  final String prodi;
  final String angkatan;
  final String phoneNumber;
  final UserRole role;
  final String avatarUrl;

  const UserModel({
    required this.id,
    required this.nim,
    required this.fullName,
    required this.email,
    required this.fakultas,
    required this.prodi,
    required this.angkatan,
    required this.phoneNumber,
    this.role = UserRole.mahasiswa,
    this.avatarUrl = '',
  });

  UserModel copyWith({
    String? id,
    String? nim,
    String? fullName,
    String? email,
    String? fakultas,
    String? prodi,
    String? angkatan,
    String? phoneNumber,
    UserRole? role,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      nim: nim ?? this.nim,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      fakultas: fakultas ?? this.fakultas,
      prodi: prodi ?? this.prodi,
      angkatan: angkatan ?? this.angkatan,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
