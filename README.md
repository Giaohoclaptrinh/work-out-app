# Fitness Tracker App - 3-in-1 Complete Solution

A comprehensive Flutter-based fitness application inspired by the [fitness_workout_app_flutter_3_ui](https://github.com/codeforany/fitness_workout_app_flutter_3_ui) repository. This app combines workout tracking, meal planning, and sleep monitoring in one beautiful interface.

## 🏋️ Features

### **🏠 Home Dashboard**
- **BMI Calculator**: Visual pie chart showing body mass index
- **Activity Progress**: Interactive line charts with touch feedback
- **Today's Target**: Quick access to daily goals
- **Latest Workouts**: Progress tracking with completion indicators
- **Welcome Screen**: Personalized greeting with statistics

### **💪 Workout Tracker**
- **Exercise Library**: Comprehensive database with instructions
- **Progress Tracking**: Visual progress indicators and charts
- **Workout Scheduling**: Calendar integration for planning
- **Activity History**: Track completed workouts and performance
- **Custom Routines**: Create and manage personalized workout plans

### **🍽️ Meal Planner**
- **Nutrition Charts**: Daily calorie tracking with line graphs
- **Meal Categories**: Breakfast, lunch, dinner, and snacks organization
- **Food Database**: Detailed nutritional information
- **Meal Scheduling**: Plan meals throughout the day
- **Calorie Counter**: Track daily nutritional intake

### **😴 Sleep Tracker**
- **Sleep Quality Charts**: Visual sleep pattern analysis
- **Sleep Schedule**: Bedtime and wake-up alarm management
- **Deep Sleep Tracking**: Monitor sleep phases and quality
- **Sleep Statistics**: Duration and quality metrics
- **Smart Alarms**: Intelligent wake-up timing

### **👤 Profile Management**
- **Personal Data**: Height, weight, age tracking
- **Achievement System**: Progress milestones and rewards
- **Activity History**: Complete fitness journey overview
- **Settings**: Customizable app preferences
- **Notifications**: Smart reminders and alerts

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── common/                      # Shared utilities
│   ├── color_extension.dart    # App color scheme and themes
│   └── common_widgets.dart     # Reusable UI components
├── models/                      # Data models
│   ├── exercise.dart           # Exercise model and sample data
│   └── workout.dart            # Workout and WorkoutSet models
└── views/                      # UI screens organized by feature
    ├── main_tab/               # Bottom navigation
    │   └── main_tab_view.dart  # Main tab controller
    ├── home/                   # Dashboard
    │   └── home_view.dart      # Home screen with charts
    ├── workout/                # Fitness tracking
    │   └── workout_tracker_view.dart
    ├── meal/                   # Nutrition planning
    │   └── meal_planner_view.dart
    ├── sleep/                  # Sleep monitoring
    │   └── sleep_tracker_view.dart
    └── profile/                # User management
        └── profile_view.dart
```

## 🎨 **UI/UX Design**

### **Modern Design System**
- **Gradient Themes**: Beautiful color gradients for each feature
- **Interactive Charts**: Touch-responsive data visualization
- **Bottom Navigation**: Smooth animated tab switching
- **Card-based Layout**: Clean, organized information display
- **Consistent Typography**: Professional font hierarchy

### **Color Scheme**
- **Primary**: Blue gradient (`#92A3FD` → `#9DCEFF`)
- **Secondary**: Purple gradient (`#C58BF2` → `#EEA4CE`)
- **Workout**: Red theme (`#FF6B6B`)
- **Meal**: Teal theme (`#4ECDC4`)
- **Sleep**: Purple theme (`#667eea`)

## Getting Started

### **Prerequisites**

- **Flutter SDK**: 3.32.5 or later
- **Xcode**: 16.4+ (for iOS development)
- **iOS Simulator**: iPhone 16 Pro or similar
- **Physical iOS Device**: iOS 18.5+ (optional)

### **Dependencies**

```yaml
dependencies:
  flutter: sdk: flutter
  cupertino_icons: ^1.0.8
  fl_chart: ^0.69.0                    # Interactive charts
  table_calendar: ^3.1.2              # Calendar widgets
  intl: ^0.19.0                        # Internationalization
  animated_bottom_navigation_bar: ^1.3.3  # Bottom navigation
  percent_indicator: ^4.2.3            # Progress indicators
  provider: ^6.1.2                     # State management
```

### **Installation**

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd fitness-tracker-app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   # On iOS simulator (recommended)
   flutter run -d "iPhone 16 Pro"
   
   # On physical iOS device
   flutter run -d "device-name"
   
   # List available devices
   flutter devices
   ```

## Development

### Running the App

- **Hot Reload**: Save files to see changes instantly
- **Hot Restart**: Press `R` in terminal for full restart
- **Debug Mode**: Use `flutter run` for development builds

### Key Components

1. **WorkoutApp**: Main application widget with theme configuration
2. **WorkoutHomePage**: Dashboard with workout statistics and navigation
3. **WorkoutListScreen**: Browse available workouts with detailed views
4. **Exercise & Workout Models**: Data structures for workout management

### Sample Data

The app includes sample workouts and exercises:
- Upper Body Strength (Push-ups)
- Lower Body Power (Squats)  
- Core Blast (Plank)

## Future Enhancements

- [ ] Workout session tracking
- [ ] Custom workout creation
- [ ] Progress analytics
- [ ] Exercise timer
- [ ] Data persistence
- [ ] User profiles

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on iOS devices
5. Submit a pull request

## License

This project is licensed under the MIT License.
