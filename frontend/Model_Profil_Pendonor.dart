class DonorProfile {
  final int? idPendonor;
  final int? userId;
  final String namaLengkap;
  final String nimIdCivitas;
  final String noTelepon;
  final String fakultasUnit;
  final String golonganDarah;
  final bool bersediaDonor;

  const DonorProfile({
    this.idPendonor,
    this.userId,
    required this.namaLengkap,
    required this.nimIdCivitas,
    required this.noTelepon,
    required this.fakultasUnit,
    required this.golonganDarah,
    required this.bersediaDonor,
  });

  factory DonorProfile.fromJson(Map<String, dynamic> json) {
    final rawBersedia = json['bersedia_donor'];
    final bool isWilling = rawBersedia == true ||
        rawBersedia == 1 ||
        rawBersedia?.toString() == '1' ||
        rawBersedia?.toString().toLowerCase() == 'true';

    return DonorProfile(
      idPendonor: json['id_pendonor'] is int
          ? json['id_pendonor'] as int
          : int.tryParse(json['id_pendonor']?.toString() ?? ''),
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? ''),
      namaLengkap: json['nama_lengkap']?.toString() ?? '',
      nimIdCivitas: json['nim_id_civitas']?.toString() ?? '',
      noTelepon: json['no_telepon']?.toString() ?? '',
      fakultasUnit: json['fakultas_unit']?.toString() ?? '',
      golonganDarah: json['golongan_darah']?.toString() ?? 'Belum Tahu',
      bersediaDonor: isWilling,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idPendonor != null) 'id_pendonor': idPendonor,
      if (userId != null) 'user_id': userId,
      'nama_lengkap': namaLengkap,
      'nim_id_civitas': nimIdCivitas,
      'no_telepon': noTelepon,
      'fakultas_unit': fakultasUnit,
      'golongan_darah': golonganDarah,
      'bersedia_donor': bersediaDonor,
    };
  }
}
