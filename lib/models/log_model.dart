class LogModel {
  final int id;
  final int userPlantId;
  final String activityType;
  final String description;
  final String logDate;
  final String? plantNickname;
  final String? plantSpecies;

  LogModel({
    required this.id,
    required this.userPlantId,
    required this.activityType,
    required this.description,
    required this.logDate,
    this.plantNickname,
    this.plantSpecies,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id'] ?? 0,
      userPlantId: json['user_plant_id'] ?? 0,
      activityType: json['activity_type'] ?? '',
      description: json['description'] ?? '',
      logDate: json['log_date'] ?? '',
      plantNickname: json['plant_nickname'],
      plantSpecies: json['plant_species'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_plant_id': userPlantId,
      'activity_type': activityType,
      'description': description,
      'log_date': logDate,
    };
  }
}
