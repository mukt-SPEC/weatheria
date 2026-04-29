# Weatheria 🌤️

Weatheria is a premium, feature-rich weather application built with Flutter. It provides real-time weather updates, detailed forecasts, and a seamless multi-location management experience, all wrapped in a stunning, high-performance UI.

## 📱 Features & Functionality

- **Smart Location Services**: Automatically detects your current location to provide local weather data instantly.
- **Dynamic Search**: Search for any city worldwide with live weather previews before adding them to your list.
- **Multi-Location Support**: Save your favorite cities and switch between them effortlessly.
- **Comprehensive Forecasts**:
  - **Current Conditions**: Detailed metrics including Feels Like, Wind Speed, Humidity, UV Index, and Visibility.
  - **Hourly Forecast**: A 24-hour horizontal breakdown of temperature and conditions.
  - **Daily Forecast**: 5-day outlook to help you plan ahead.
- **Theme Intelligence**: Beautifully crafted Light and Dark modes with automatic system switching.
- **Offline Reliability**: Built-in connectivity monitoring and smart caching for a smooth experience even when connection is spotty.
- **Data Persistence**: Your saved locations and theme preferences are securely stored locally.

## 🌐 APIs Used

- **WeatherAPI**: Primary source for current, hourly, and forecast weather data.  
  [https://www.weatherapi.com/](https://www.weatherapi.com/)
- **Nominatim OpenStreetMap**: Utilized for forward and reverse geocoding (converting city names to coordinates and vice versa).  
  [https://nominatim.openstreetmap.org/](https://nominatim.openstreetmap.org/)

## 🎬 Animation Highlights

- **Typer Animations**: Smooth, sophisticated "typing" effects for city labels and temperature readings using `AnimatedTextKit`.
- **Shimmer Loading**: Elegant shimmer effects that match the app's design system, providing a premium feel during data fetching.
- **Reactive Transitions**: Real-time UI updates when switching locations or themes, ensuring the interface feels alive and responsive.
- **Micro-interactions**: Subtle hover and tap effects throughout the app to enhance user engagement.

## 🏗️ Architecture & Technology Stack

Weatheria follows a **Feature-First Architecture**, promoting high modularity and scalability.

- **State Management**: Powered by **Riverpod**, utilizing `NotifierProvider`, `FutureProvider`, and `StreamProvider` for a reactive, robust state tree.
- **Networking**: **Dio** with interceptors and **dio_http_cache_lts** for optimized API calls and offline caching.
- **Local Storage**: **Hive** for high-performance NoSQL data persistence of saved locations and settings.
- **Design System**: Vanilla CSS-inspired Flutter styling with a custom theme engine and modern typography (Google Fonts).
- **Security**: **Envied** for secure handling of API keys and sensitive environment variables.
- **Tools & Utilities**:
  - `geolocator` & `geocoding` for location intelligence.
  - `connectivity_plus` for real-time network monitoring.
  - `intl` for precise date and number formatting.
  - `phosphor_flutter` for a consistent, premium iconography set.

---

Built with ❤️ using Flutter.
