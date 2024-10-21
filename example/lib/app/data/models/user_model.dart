class UserModel {
  final int? userId;
  final String? namaLengkap;
  final String? departemen;
  final String? jabatan;
  final String? afdeling;
  final String? lokasiKerja;
  final String? nomorHp;
  final String? aksesLevel;
  final String? departementId;
  final String? jabatanId;
  final String? apiToken;

  UserModel({
    this.userId,
    this.namaLengkap,
    this.departemen,
    this.jabatan,
    this.afdeling,
    this.lokasiKerja,
    this.nomorHp,
    this.aksesLevel,
    this.departementId,
    this.jabatanId,
    this.apiToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      namaLengkap: json['nama_lengkap'],
      departemen: json['departemen'],
      jabatan: json['jabatan'],
      afdeling: json['afdeling'],
      lokasiKerja: json['lokasi_kerja'],
      nomorHp: json['no_hp'],
      aksesLevel: json['akses_level'],
      departementId: json['id_departement'],
      jabatanId: json['id_jabatan'],
      apiToken: json['api_token'],
    );
  }
}
