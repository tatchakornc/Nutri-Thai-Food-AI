# NutriThaiFood AI — Setup Guide

## Prerequisites

- Flutter SDK ≥ 3.0.0 installed ([flutter.dev](https://flutter.dev))
- Dart SDK ≥ 3.0.0 (bundled with Flutter)
- Android Studio or VS Code with Flutter extension
- Firebase account
- Node.js (for FlutterFire CLI)

---

## Step 1: Get dependencies

```bash
flutter pub get
```

---

## Step 2: Set up Firebase

### 2a. Create a Firebase project
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click "Add project" → name it **NutriThaiFood**
3. Enable Google Analytics (optional)

### 2b. Enable Firebase services
In the Firebase console for your project:
- **Authentication**: Enable Email/Password sign-in
- **Cloud Firestore**: Create database in production mode
- **Firebase Storage**: Enable (for food images)
- **Cloud Messaging**: Enable (for push notifications)

### 2c. Connect Flutter app with FlutterFire CLI

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login
firebase login

# Configure (run inside this project directory)
flutterfire configure
```

This will:
- Register Android + iOS apps in Firebase
- Download `google-services.json` → `android/app/`
- Download `GoogleService-Info.plist` → `ios/Runner/`
- Overwrite `lib/firebase_options.dart` with real keys

---

## Step 3: Deploy Firestore Rules and Indexes

```bash
# Install Firebase CLI if not installed
npm install -g firebase-tools

firebase login
firebase init firestore   # select your project

# Deploy rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes
```

---

## Step 4: Seed Thai Food Data

Open `lib/services/food_database_service.dart` and call seed functions once
(e.g., from a temporary button in the app, or via Firebase Console):

```dart
final service = FoodDatabaseService();
await service.seedThaiFoods();
await service.seedIngredients();
```

Or use the Firebase Console to import the seed data from:
- `seed_data/thai_foods.json`
- `seed_data/thai_ingredients.json`

---

## Step 5: Run the app

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Check for issues
flutter doctor
```

---

## Step 6: Connect Real AI (optional)

To replace the mock AI with a real vision API, open:
`lib/services/ai_food_recognition_service.dart`

Uncomment and complete the `OpenAIFoodRecognitionService` stub:
```dart
class OpenAIFoodRecognitionService implements AIFoodRecognitionService {
  final String apiKey;
  // ... implement recognizeFood()
}
```

Then update the Riverpod provider in `lib/providers/food_database_provider.dart`:
```dart
final aiRecognitionServiceProvider = Provider<AIFoodRecognitionService>(
  (ref) => OpenAIFoodRecognitionService(apiKey: 'YOUR_KEY'),
);
```

---

## Project Structure

```
lib/
├── main.dart                         # App entry point
├── app.dart                          # MaterialApp + router binding
├── app_router.dart                   # GoRouter routes
├── firebase_options.dart             # Firebase config (auto-generated)
├── constants/
│   ├── app_colors.dart               # Color palette
│   ├── app_strings.dart              # All Thai UI strings
│   └── app_theme.dart                # Material 3 theme
├── models/                           # Data models (Firestore ↔ Dart)
│   ├── user_model.dart
│   ├── food_model.dart
│   ├── food_log_model.dart
│   ├── water_log_model.dart
│   ├── quest_model.dart
│   ├── streak_model.dart
│   └── ingredient_model.dart
├── services/                         # Business logic
│   ├── auth_service.dart
│   ├── user_profile_service.dart
│   ├── nutrition_calculator_service.dart   ← Pure functions, unit-testable
│   ├── food_database_service.dart          ← Thai food DB + seed data
│   ├── food_log_service.dart
│   ├── water_service.dart
│   ├── streak_service.dart
│   ├── quest_service.dart
│   ├── notification_service.dart
│   └── ai_food_recognition_service.dart    ← Abstract + Mock + stub OpenAI
├── providers/                        # Riverpod state
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── food_log_provider.dart
│   ├── water_provider.dart
│   ├── streak_provider.dart
│   ├── quest_provider.dart
│   └── food_database_provider.dart
├── screens/                          # UI screens
│   ├── splash_screen.dart
│   ├── auth/login_screen.dart
│   ├── auth/register_screen.dart
│   ├── home/home_dashboard_screen.dart
│   ├── food_log/food_log_screen.dart
│   ├── food_log/ai_food_scan_screen.dart
│   ├── food_log/food_history_screen.dart
│   ├── food_log/quick_manual_log_screen.dart
│   ├── food_log/gram_based_calculation_screen.dart
│   ├── random_food/random_food_screen.dart
│   ├── water/water_tracker_screen.dart
│   ├── quest/quest_screen.dart
│   ├── profile/profile_screen.dart
│   ├── profile/profile_setup_screen.dart
│   └── profile/settings_screen.dart
├── widgets/                          # Reusable components
│   ├── main_shell.dart               # Bottom navigation shell
│   ├── nutrition_progress_card.dart
│   ├── macro_progress_bar.dart
│   ├── water_glass_grid.dart
│   ├── food_log_card.dart
│   ├── quest_card.dart
│   ├── streak_fire_widget.dart
│   ├── meal_type_selector.dart
│   ├── primary_button.dart
│   ├── empty_state_widget.dart
│   ├── loading_view.dart
│   └── error_view.dart
└── utils/
    ├── date_utils.dart
    ├── validators.dart
    └── nutrition_utils.dart
```

---

## Firestore Schema

```
users/{userId}
  ├── foodLogs/{logId}          # Daily food entries
  ├── waterLogs/{date}          # Daily water (yyyy-MM-dd)
  ├── quests/{questId}          # Daily health quests
  └── streak/data               # Streak tracking

foods/{foodId}                  # Thai food nutrition DB (read-only)
ingredients/{ingredientId}      # Thai ingredient DB per 100g (read-only)
```

---

## Nutrition Calculation (Mifflin-St Jeor)

| Variable | Formula |
|----------|---------|
| BMR (Male) | 10W + 6.25H − 5A + 5 |
| BMR (Female) | 10W + 6.25H − 5A − 161 |
| TDEE | BMR × activity multiplier |
| Calorie target | TDEE ± adjustment by goal |
| Protein | 2.0g × weight(kg) |
| Fat | 25% of daily calories ÷ 9 |
| Carbs | remaining calories ÷ 4 |

---

## Adding Real AI Vision

The `AIFoodRecognitionService` interface is designed for easy swapping:

```dart
abstract class AIFoodRecognitionService {
  Future<AIRecognitionResult> recognizeFood({File? imageFile, String? imageUrl});
}
```

Implement it for:
- **OpenAI GPT-4 Vision**: Send image URL + prompt in Thai
- **Google Gemini Vision**: Use `gemini-pro-vision` model
- **Custom ML model**: Deploy your model on Firebase ML or Cloud Run
