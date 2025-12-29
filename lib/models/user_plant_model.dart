class UserPlantModel {
  final int id;
  final int userId;
  final int speciesId;
  final String nickname;
  final String locationType;
  final String plantingDate;
  final String growthStage;
  final String status;

  UserPlantModel({
    required this.id,
    required this.userId,
    required this.speciesId,
    required this.nickname,
    required this.locationType,
    required this.plantingDate,
    required this.growthStage,
    required this.status,
  });

  factory UserPlantModel.fromJson(Map<String, dynamic> json) {
    return UserPlantModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      speciesId: json['species_id'] ?? 0,
      nickname: json['nickname'] ?? '',
      locationType: json['location_type'] ?? '',
      plantingDate: json['planting_date'] ?? '',
      growthStage: json['growth_stage'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'species_id': speciesId,
      'nickname': nickname,
      'location_type': locationType,
      'planting_date': plantingDate,
      'growth_stage': growthStage,
      'status': status,
    };
  }
}
