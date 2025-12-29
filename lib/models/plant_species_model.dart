class PlantSpeciesModel {
  final int id;
  final String name;
  final String scientificName;
  final String description;
  final String imageUrl;
  final String soilRecommendation;
  final String plantingDistance;
  final String sunlightNeeds;
  final int optimalTempMin;
  final int optimalTempMax;
  final int harvestDurationDays;

  PlantSpeciesModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.imageUrl,
    required this.soilRecommendation,
    required this.plantingDistance,
    required this.sunlightNeeds,
    required this.optimalTempMin,
    required this.optimalTempMax,
    required this.harvestDurationDays,
  });

  factory PlantSpeciesModel.fromJson(Map<String, dynamic> json) {
    return PlantSpeciesModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      soilRecommendation: json['soil_recommendation'] ?? '',
      plantingDistance: json['planting_distance'] ?? '',
      sunlightNeeds: json['sunlight_needs'] ?? '',
      optimalTempMin: json['optimal_temp_min'] ?? 0,
      optimalTempMax: json['optimal_temp_max'] ?? 0,
      harvestDurationDays: json['harvest_duration_days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'description': description,
      'image_url': imageUrl,
      'soil_recommendation': soilRecommendation,
      'planting_distance': plantingDistance,
      'sunlight_needs': sunlightNeeds,
      'optimal_temp_min': optimalTempMin,
      'optimal_temp_max': optimalTempMax,
      'harvest_duration_days': harvestDurationDays,
    };
  }
}
