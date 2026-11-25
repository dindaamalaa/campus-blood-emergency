class PendonorProfile {
  final int? idPendonor;
  final int? userId;
  final String namaLengkap;
  final String nimIdCivitas;
  final String noTelepon;
  final String fakultasUnit;
  final String golonganDarah;
  final bool bersediaDonor;

  PendonorProfile({
    this.idPendonor,
    this.userId,
    required this.namaLengkap,
    required this.nimIdCivitas,
    required this.noTelepon,
    required this.fakultasUnit,
    required this.golonganDarah,
    required this.bersediaDonor,
  });

  factory PendonorProfile.fromJson(Map<String, dynamic> json) {
    final rawBersedia = json['bersedia_donor'];
    final isBersedia = rawBersedia == true || rawBersedia == 1 || rawBersedia == '1';

    return PendonorProfile(
      idPendonor: json['id_pendonor'] as int?,
      userId: json['user_id'] as int?,
      namaLengkap: (json['nama_lengkap'] ?? '').toString(),
      nimIdCivitas: (json['nim_id_civitas'] ?? '').toString(),
      noTelepon: (json['no_telepon'] ?? '').toString(),
      fakultasUnit: (json['fakultas_unit'] ?? '').toString(),
      golonganDarah: (json['golongan_darah'] ?? 'Belum Tahu').toString(),
      bersediaDonor: isBersedia,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_lengkap': namaLengkap,
      'nim_id_civitas': nimIdCivitas,
      'no_telepon': noTelepon,
      'fakultas_unit': fakultasUnit,
      'golongan_darah': golonganDarah,
      'bersedia_donor': bersediaDonor,
    };
  }
}