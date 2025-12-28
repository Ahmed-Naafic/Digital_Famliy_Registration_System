/// Identity data from NIRA (via backend)
class IdentityData {
  final String nationalId;
  final String fullName;
  final String? dateOfBirth;
  final String? gender;
  final String? nationality;
  final String? status;

  IdentityData({
    required this.nationalId,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.status,
  });

  factory IdentityData.fromJson(Map<String, dynamic> json) {
    return IdentityData(
      nationalId: json['nationalId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      nationality: json['nationality'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nationalId': nationalId,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'nationality': nationality,
      'status': status,
    };
  }
}

