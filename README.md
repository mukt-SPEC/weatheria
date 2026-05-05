# Weatheria 🌤️

Weatheria is a premium, high-performance weather application built with Flutter. It delivers real-time weather insights, precise forecasts, and a sophisticated multi-location management system, all within a stunning, cross-platform UI.

---

## 🔗 Project Links

| Platform | Link |
| :--- | :--- |
| 📱 **Appetize (Mobile Demo)** | [View on Appetize](https://appetize.io/app/b_gcvof55hetjozru3aowqmivwfm) |
| 🌐 **Live Web App** | [Launch Weatheria Web](https://weatheriaa.vercel.app/) |
| ☁️ **Cloud Drive (Assets/APKs)** | [Google Drive Folder](https://drive.google.com/drive/folders/1bdns2guz_EiyKlzWc1TFL7UqCHU1C802?usp=drive_link) |

---

## 📸 Screenshots & Demo

### 📱 Mobile Experience
<div align="center">
  <table>
    <tr>
      <td><img width="1280" height="2856" alt="Image" src="https://github.com/user-attachments/assets/04610e46-fb2c-473f-ba3c-5bf7974d8263" /></td>
      <td><img src="https://raw.githubusercontent.com/placeholder-screenshots/weatheria-mobile-2.png" width="200" alt="Search Screen"></td>
      <td><img src="https://raw.githubusercontent.com/placeholder-screenshots/weatheria-mobile-3.png" width="200" alt="Forecast View"></td>
    </tr>
  </table>
</div>

### 🖥️ Desktop & Web
<div align="center">
  <img src="https://raw.githubusercontent.com/placeholder-screenshots/weatheria-desktop.png" width="800" alt="Desktop Dashboard">
</div>

### 🎬 Video Walkthrough
[▶️ Watch the Demo Video](https://drive.google.com/drive/folders/1bdns2guz_EiyKlzWc1TFL7UqCHU1C802?usp=drive_link)

---

## 🚀 Platform Adaptation & Support

Weatheria is designed to be truly adaptive, providing a native-feel experience across all major platforms.

- **📱 Mobile (Android & iOS)**:
  - Touch-optimized gestures and haptic feedback.
  - Adaptive bottom sheets for search and location management.
  - SafeArea integration for notches and home indicators.
- **🌐 Web**:
  - Fully responsive layout that scales from mobile view to wide-screen dashboard.
  - SEO optimized with fast load times.
  - Browser-native interactions and URL handling.
- **🖥️ Desktop (Windows, macOS, Linux)**:
  - **Dynamic Breakpoints**: UI transitions from compact mobile lists to expanded grid layouts (Compact < 600px, Medium < 840px, Expanded >= 840px).
  - **Platform-Specific Menus**: Native menu bar integration and keyboard shortcuts (Ctrl+F for search, Ctrl+L for locations, F5 for refresh).
  - **Hover States**: Interactive micro-animations for pointer-based navigation.

---

## ✨ Features & Functionality

- **Smart Location Intelligence**: Automatic current location detection with a fallback system for enhanced reliability.
- **Global Search**: Search any city worldwide with real-time suggestions and previews.
- **Multi-Location Hub**: Save and manage your favorite cities with high-performance local persistence.
- **Deep Weather Metrics**:
  - **Real-time**: Feels Like, Wind Speed, Humidity, UV Index, Visibility, and Pressure.
  - **Hourly**: 24-hour horizontal forecast with condition icons.
  - **Daily**: 5-day outlook with high/low temperatures.
- **Premium Aesthetics**:
  - **Theme Engine**: Seamless switching between Light and Dark modes.
  - **Animations**: Typer effects for text, shimmer loading states, and smooth transitions using `flutter_animate`.
- **Offline Mode**: Robust connectivity monitoring ensures data is always available via smart Hive caching.

---

## 🏗️ Architecture & Technology Stack

Weatheria follows a **Feature-First Architecture**, promoting high modularity and scalability.

- **Framework**: [Flutter](https://flutter.dev/) (3.11.5+)
- **State Management**: [Riverpod](https://riverpod.dev/) (Notifier, FutureProvider, StreamProvider)
- **Networking**: [Dio](https://pub.dev/packages/dio) with Retrofit for type-safe API calls and interceptors for offline caching.
- **Persistence**: [Hive](https://pub.dev/packages/hive) (High-performance NoSQL database for locations and settings).
- **Icons & UI**: [Phosphor Icons](https://phosphoricons.com/), [Google Fonts](https://fonts.google.com/).
- **Utilities**: `geolocator` & `geocoding` for location services, `connectivity_plus` for network monitoring, and `intl` for formatting.

---

## ⚙️ Setup & Installation

Follow these steps to get a local development environment running:

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- A code editor (VS Code or Android Studio).
- A valid [WeatherAPI](https://www.weatherapi.com/) key.

### 2. Clone the Repository
```bash
git clone https://github.com/your-username/weatheria.git
cd weatheria
```

### 3. Environment Configuration
Create a `.env` file in the root directory and add your API key:
```env
API_KEY=your_weather_api_key_here
```

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Generate Code
Weatheria uses `envied` and `retrofit`. Run the generator to build required files:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. Run the App
```bash
flutter run
```

---

Built with ❤️ using Flutter.

