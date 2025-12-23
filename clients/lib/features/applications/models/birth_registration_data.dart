/// Model for birth registration data
/// Represents the complete structure of birth registration payload
class BirthRegistrationData {
  /// Child information
  final ChildData child;

  /// Parents information
  final ParentsData parents;

  const BirthRegistrationData({
    required this.child,
    required this.parents,
  });

  /// Convert to JSON map for API submission
  Map<String, dynamic> toJson() {
    return {
      'child': child.toJson(),
      'parents': parents.toJson(),
    };
  }

  /// Create from JSON map (for backward compatibility)
  factory BirthRegistrationData.fromJson(Map<String, dynamic> json) {
    return BirthRegistrationData(
      child: ChildData.fromJson(json['child'] as Map<String, dynamic>),
      parents: ParentsData.fromJson(json['parents'] as Map<String, dynamic>),
    );
  }
}

/// Child data model
class ChildData {
  final String? name;
  final DateTime? dateOfBirth;
  final String? placeOfBirth;
  final String? gender;

  const ChildData({
    this.name,
    this.dateOfBirth,
    this.placeOfBirth,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'placeOfBirth': placeOfBirth,
      'gender': gender,
    };
  }

  factory ChildData.fromJson(Map<String, dynamic> json) {
    return ChildData(
      name: json['name'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      placeOfBirth: json['placeOfBirth'] as String?,
      gender: json['gender'] as String?,
    );
  }
}

/// Parents data model
class ParentsData {
  final ParentInfo father;
  final ParentInfo mother;
  final String? nationalId;

  const ParentsData({
    required this.father,
    required this.mother,
    this.nationalId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'father': father.toJson(),
      'mother': mother.toJson(),
    };
    if (nationalId != null && nationalId!.isNotEmpty) {
      map['nationalId'] = nationalId;
    }
    return map;
  }

  factory ParentsData.fromJson(Map<String, dynamic> json) {
    return ParentsData(
      father: ParentInfo.fromJson(
        (json['father'] as Map<String, dynamic>?) ?? {},
      ),
      mother: ParentInfo.fromJson(
        (json['mother'] as Map<String, dynamic>?) ?? {},
      ),
      nationalId: json['nationalId'] as String?,
    );
  }
}

/// Parent information model
class ParentInfo {
  final String? name;

  const ParentInfo({this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  factory ParentInfo.fromJson(Map<String, dynamic> json) {
    return ParentInfo(
      name: json['name'] as String?,
    );
  }
}

