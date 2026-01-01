# 🔌 TanamCareApps Dashboard - API & Database Integration Guide

## Overview
Dashboard redesign fully integrated dengan:
- ✅ GardenProvider (State Management)
- ✅ PlantService (API/Database Operations)
- ✅ AuthProvider (User Context)
- ✅ WeatherService (Real-time Data)

---

## 📡 API Endpoints Used

### 1. Load All Plant Species
**Endpoint**: `GET /api/plant-species` atau yang setara
**Provider**: `GardenProvider.loadAllSpecies()`
**Usage**: Home screen plant grid population

```dart
// In home_screen.dart - initState
final garden = Provider.of<GardenProvider>(context, listen: false);
garden.loadAllSpecies();
```

**Response Expected**:
```json
[
  {
    "id": 1,
    "name": "Tomat",
    "scientificName": "Solanum lycopersicum",
    "description": "Tomat adalah...",
    "imageUrl": "https://...",
    "soilRecommendation": "Tanah Subur, Gembur, Berhumus",
    "plantingDistance": "50-60 cm x 40-50 cm",
    "sunlightNeeds": "Full Sun",
    "optimalTempMin": 20,
    "optimalTempMax": 30,
    "harvestDurationDays": 60
  },
  // ... more plants
]
```

---

### 2. Add Plant to Garden
**Endpoint**: `POST /api/user-plants` atau yang setara
**Provider**: `GardenProvider.addPlantToGarden()`
**Usage**: Submit form di plant input screen

```dart
// In plant_input_screen.dart - _submitForm()
await gardenProvider.addPlantToGarden(
  userId: authProvider.userId,
  speciesId: widget.plant.id,
  nickname: _nicknameController.text,
  locationType: _selectedLocationType,
  plantingDate: _selectedDate?.toIso8601String(),
);
```

**Request Body**:
```json
{
  "user_id": 1,
  "species_id": 1,
  "nickname": "Tomat Saya",
  "location_type": "Pot",
  "planting_date": "2024-01-01T00:00:00Z"
}
```

**Response Expected**:
```json
{
  "success": true,
  "message": "Plant added to garden",
  "data": {
    "id": 10,
    "user_id": 1,
    "species_id": 1,
    "nickname": "Tomat Saya",
    "location_type": "Pot",
    "planting_date": "2024-01-01",
    "growth_stage": "seedling",
    "status": "healthy",
    "created_at": "2024-01-01T10:30:00Z",
    "updated_at": "2024-01-01T10:30:00Z"
  }
}
```

---

### 3. Load User Plants
**Endpoint**: `GET /api/user/{userId}/plants` atau yang setara
**Provider**: `GardenProvider.loadUserPlants()`
**Usage**: MyGardenScreen & plant counter display

```dart
// In home_screen.dart - initState
final garden = Provider.of<GardenProvider>(context, listen: false);
garden.loadUserPlants();
```

**Response Expected**:
```json
[
  {
    "id": 10,
    "species_id": 1,
    "nickname": "Tomat Saya",
    "location_type": "Pot",
    "planting_date": "2024-01-01",
    "growth_stage": "seedling",
    "status": "healthy",
    "speciesName": "Tomat",
    "imageUrl": "https://..."
  }
]
```

---

### 4. Delete Plant
**Endpoint**: `DELETE /api/user-plants/{plantId}` atau yang setara
**Provider**: `GardenProvider.deletePlant()`
**Usage**: MyGardenScreen (ready untuk integration)

```dart
// Example usage (untuk future implementation)
await gardenProvider.deletePlant(plantId: userPlantId);
```

---

### 5. Get Weather Data
**Endpoint**: `External API (OpenWeatherMap)` atau internal API
**Service**: `WeatherService.getCurrentWeather()`
**Usage**: Header temperature display

```dart
// In home_screen.dart
final weather = await _weatherService.getCurrentWeather();
final temp = weather['temperature']; // 27
```

**Response Expected**:
```json
{
  "temperature": 27,
  "condition": "Sunny",
  "humidity": 65,
  "wind_speed": 10
}
```

---

## 🔐 Authentication

### User Context
**Provider**: `AuthProvider`
**Usage**: Obtain user ID untuk database operations

```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final userId = authProvider.userId; // Example: 1
final user = authProvider.user; // User model with name, email, etc
```

**User Model Expected**:
```dart
class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final DateTime createdAt;
}
```

---

## 🗄️ Database Schema

### Table: plant_species
```sql
CREATE TABLE plant_species (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  scientific_name VARCHAR(150),
  description LONGTEXT,
  image_url VARCHAR(255),
  soil_recommendation VARCHAR(255),
  planting_distance VARCHAR(100),
  sunlight_needs VARCHAR(100),
  optimal_temp_min INT,
  optimal_temp_max INT,
  harvest_duration_days INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Table: user_plants
```sql
CREATE TABLE user_plants (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  species_id INT NOT NULL,
  nickname VARCHAR(100),
  location_type VARCHAR(50),
  planting_date DATETIME,
  growth_stage VARCHAR(50),
  status VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (species_id) REFERENCES plant_species(id)
);
```

---

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────┐
│         HOME SCREEN                          │
├─────────────────────────────────────────────┤
│ ↓ initState (onLoad)                        │
│ ├─ AuthProvider.loadUser()                  │
│ ├─ GardenProvider.loadAllSpecies()          │
│ │  └─ API: GET /api/plant-species           │
│ └─ GardenProvider.loadUserPlants()          │
│    └─ API: GET /api/user/{id}/plants       │
│                                             │
│ ↓ Display                                   │
│ ├─ WeatherService.getCurrentWeather()      │
│ ├─ Show plant grid from allSpecies          │
│ └─ Show garden counter from userPlants      │
└─────────────────────────────────────────────┘
                    ↓ User taps "Tanam"
        ┌───────────────────────────────┐
        │   PLANT DETAIL SCREEN         │
        ├───────────────────────────────┤
        │ Display plant specs           │
        │ User taps "Input Data"        │
        └───────────────────────────────┘
                    ↓
        ┌───────────────────────────────┐
        │   PLANT INPUT SCREEN          │
        ├───────────────────────────────┤
        │ User fills:                   │
        │ - nickname                    │
        │ - location_type               │
        │ - planting_date               │
        │                               │
        │ User taps "Lanjut"            │
        │ ↓ Validate & Submit            │
        │ └─ API: POST /api/user-plants │
        │    + Save to GardenProvider   │
        └───────────────────────────────┘
                    ↓
        ┌───────────────────────────────┐
        │  RECOMMENDATION SCREEN        │
        ├───────────────────────────────┤
        │ Show calculation (85%)        │
        │ Show recipe & tips            │
        │ Show summary                  │
        │ User taps "Selesai"           │
        └───────────────────────────────┘
                    ↓ Navigate back
        ┌───────────────────────────────┐
        │   HOME SCREEN (UPDATED)       │
        ├───────────────────────────────┤
        │ ├─ GardenProvider updates     │
        │ └─ "My Garden" count +1       │
        │    (from cached data)         │
        └───────────────────────────────┘
```

---

## ⚙️ Error Handling

### Common Errors & Solutions

#### 1. Network Error - Plant tidak load
```dart
// GardenProvider automatically retries
// UI shows: "Tidak ada tanaman tersedia"
// Solution: Check internet connection & API endpoint
```

#### 2. Database Save Fails
```dart
// SnackBar shows: "Gagal menambahkan tanaman"
// Solution: 
// - Check user authentication
// - Verify species_id exists
// - Check database connection
```

#### 3. Weather API Timeout
```dart
// Shows: error icon (❌) in header
// Solution: Has fallback, doesn't block UI
```

---

## 🧪 Testing Endpoints

### Test with cURL

#### 1. Get all plant species
```bash
curl -X GET http://your-api.com/api/plant-species
```

#### 2. Add plant to garden
```bash
curl -X POST http://your-api.com/api/user-plants \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "user_id": 1,
    "species_id": 1,
    "nickname": "Tomat Saya",
    "location_type": "Pot",
    "planting_date": "2024-01-01"
  }'
```

#### 3. Get user plants
```bash
curl -X GET http://your-api.com/api/user/1/plants \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### 4. Delete plant
```bash
curl -X DELETE http://your-api.com/api/user-plants/10 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📊 Data Validation

### Input Validation (Client-side)

#### Plant Input Form
| Field | Required | Validation | Error Message |
|-------|----------|-----------|--------------|
| nickname | ✅ | Not empty | "Nama tanaman tidak boleh kosong" |
| location_type | ✅ | From dropdown list | Auto-selected |
| planting_date | ✅ | Not future date | Auto-selected (today) |

---

## 🔄 Caching Strategy

### GardenProvider Caching
```dart
// Default: 5 minute cache
// Plants reload automatically if:
// 1. Cache expired
// 2. Manual refresh (gardens.clearCache())
// 3. New plant added (updates local list)
```

**Benefits**:
- ✅ Reduces API calls
- ✅ Faster UI response
- ✅ Works offline (cached data)

---

## 📱 State Management Flow

```
AuthProvider
├── user: User?
├── userId: int
├── isAuthenticated: bool
└── Methods: loadUser(), loadToken(), logout()

GardenProvider
├── allSpecies: List<PlantSpeciesModel>
├── userPlants: List<UserPlantModel>
├── isLoading: bool
├── cachedPlants: Map (with timestamp)
└── Methods:
    ├── loadAllSpecies()
    ├── loadUserPlants()
    ├── addPlantToGarden()
    ├── deletePlant()
    └── clearCache()
```

---

## 🎯 Next Steps for Integration

### Immediate (Ready)
✅ Dashboard UI - **Complete**
✅ Database integration points - **Identified**
✅ API endpoint mapping - **Documented**

### Short-term (Recommended)
⏳ Delete plant functionality in MyGardenScreen
⏳ Search/filter plants
⏳ Edit plant details
⏳ Plant health tracking

### Future Enhancements
⏳ Fertilizer reminders
⏳ Disease detection via AI
⏳ Watering schedule calculator
⏳ Community sharing features

---

## 🚨 Important Notes

1. **User Context Required**: All operations need valid `user_id` from AuthProvider
2. **Token Management**: Ensure auth token is sent in API headers (likely handled by interceptor)
3. **Date Formatting**: API expects ISO8601 format (implemented in code)
4. **Image URLs**: Plant images should be valid URLs or handled gracefully (fallback icon implemented)
5. **Error Handling**: All network errors have UI feedback (SnackBars)

---

**Last Updated**: Current Session
**Status**: ✅ Ready for Backend Connection
