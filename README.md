# Campus Bus Buddy

A real-time campus transit tracking app built with Flutter for Android.

## Problem
Students don’t get accurate bus locations or arrival estimates on campus, leading to long waits, missed rides, and unsafe travel during peak hours.

## Solution
Campus Bus Buddy provides:
- Live bus tracking using Google Maps API
- Clear route directions between campus zones
- Estimated arrival time (ETA) for each stop
- Proximity alerts using real-time database streams
- Simple, reliable UI for daily campus commute

## Tech Stack
- **Flutter** (Android App)
- **Firebase Firestore** (Real-time Database)
- **Google Maps API** (Location Visualization)
- Android Emulator used for testing (API 36)

## Setup & Run
```bash
cd campus_bus
flutter pub get
flutter run -d emulator-5554
