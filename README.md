```markdown
# 🚌 Bus Buddy

**Live Bus Tracking for IIT Mandi**

Tired of checking WhatsApp groups to figure out if there's space on the next bus? Bus Buddy gives you real-time seat availability, live GPS tracking, and a dead-simple interface to never miss your bus again.

## What's the Problem?

You're standing at the bus stop. You have 10 minutes before your next class. You have no idea if Bus C has any seats left. You ask a friend. They don't know either. So you wait. You might miss it. Or worse, you squeeze in.

This happens to IIT Mandi students every single day.

## How Bus Buddy Fixes It

- **Open the app** → See all live buses sorted by arrival time
- **Tap a bus** → See live location on the map + exactly how many seats are available
- **Board with confidence** → Color-coded seat indicators: green (plenty) → orange (tight) → red (full)
- **As a driver** → One tap per student boarding/leaving → all students see it instantly

No refreshing. No confusion. No missed buses.

## Features

✨ **Live Bus Tracking**  
Real-time GPS location for every active bus on campus. Updated every time a bus moves.

💺 **Real-time Seat Availability**  
Drivers report seat counts with a single tap. Students see updates instantly (< 2 seconds).

🗺️ **Campus Map**  
See your bus, your location, and all 8 stops in one view. North Campus, South Campus, Mandi Town—all mapped out.

🌙 **Dark Mode + Light Mode**  
Built on Material Design 3. Looks good at 3 PM and 3 AM.

📋 **Bus Schedule**  
Quick access to the official IIT Mandi bus timetable. No separate PDF hunting.

🔐 **Dual Role System**  
Students log in as students. Drivers log in with their driver ID. Different interfaces for different jobs.

## Tech Stack

- **Frontend:** Flutter (cross-platform, beautiful, fast)
- **Backend:** Firebase Firestore (real-time database that actually works)
- **Maps:** Google Maps Flutter plugin (live location rendering)
- **Location:** Geolocator (continuous GPS streaming with smart filtering)

## Why This Matters

**For Students:**
- Stop wasting time asking around about bus availability
- Make informed decisions about which bus to take
- Coordinate better with friends

**For Campus:**
- Less congestion complaints from students
- Better utilization data for route optimization
- Modern, tech-forward campus experience

## Getting Started

### Prerequisites

- Flutter 3.10+ ([install here](https://flutter.dev/docs/get-started/install))
- Firebase account (free tier works fine)
- Android SDK 21+ or iOS 13+

### Installation

1. **Clone the repo**
   ```
   git clone https://github.com/yourusername/bus-buddy.git
   cd bus-buddy
   ```

2. **Install dependencies**
   ```
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable Firestore Database (test mode for dev, switch to production rules later)
   - Enable Google Maps API in GCP console
   - Download `google-services.json` (Android) and place in `android/app/`
   - For iOS, add GoogleService-Info.plist to Xcode

4. **Run the app**
   ```
   flutter run
   ```

### Seeding Demo Data

Open the app in debug mode and tap the **"Seed Demo Data"** button on the login screen. This will create 8 buses in Firestore with names (A–H) and routes. Then log in as any driver to test seat updates.

## How to Use

### As a Student

1. Tap **"Continue as Student"** on the home screen
2. See all live buses in your list
3. Tap any bus to see it on the map + exact seat count
4. Watch the seat count update in real-time as drivers report changes

### As a Driver

1. Tap **"Continue as Driver"**
2. Enter your driver ID (e.g., `driver_1` for Bus A) and hit continue
3. Select your bus
4. In the **Seat Panel**, tap **"+"** when a student boards, **"−"** when they leave
5. Watch all students see the update instantly

**Pro tip:** Tap **"Start Live Location"** to stream your GPS coordinates to students in real-time.

## File Structure

```
lib/
├── main.dart                 # App entry, theme setup, role selection
├── map_screen.dart          # Map view with markers and legend
├── seed_data.dart           # Demo bus data for testing
pubspec.yaml                 # Dependencies
android/app/build.gradle     # Android config
```

## Architecture

```
┌─────────────────────────────────────┐
│      Student & Driver Apps          │
│  (Flutter, Material Design 3)        │
├─────────────────────────────────────┤
│   Firestore Real-time Listeners      │
│  (Live seat sync, location updates)  │
├─────────────────────────────────────┤
│  Firebase Firestore (NoSQL DB)       │
│  -  livebuses/{busId} - live tracking │
│  -  buses/{busId} - static metadata   │
├─────────────────────────────────────┤
│  Google Maps API + Geolocator        │
└─────────────────────────────────────┘
```

**Data Flow:**
- Driver updates seat count → Firestore transaction processes it (atomic, no race conditions)
- Firestore notifies all listening devices → Student app refreshes in < 1 second
- GPS location streamed continuously → Map updates in real-time

## Key Implementation Details

### Firestore Structure

**collections/livebuses/{busId}**
```
{
  "busid": "busa",
  "lat": 31.7783,
  "lng": 76.9920,
  "driverseatsleft": 15,
  "studentdelta": 2,
  "etaminutes": 5,
  "code": "A",
  "route": "South - North Campus",
  "updatedat": "2025-12-27T19:30:00Z"
}
```

**collections/buses/{busId}** (static metadata)
```
{
  "busid": "busa",
  "code": "A",
  "route": "South - North Campus",
  "totalseats": 27
}
```

### Seat Logic

**Shown to Students:**
```
availableSeats = driverSeatsLeft - studentDelta
```

So if the driver says there are 15 seats left (`driverseatsleft`) but 2 students are boarding (`studentdelta`), students see 13 seats available. This prevents overbooking and keeps data consistent.

### Transactional Updates

Seat updates use Firestore transactions to ensure:
- No two updates happen simultaneously on the same bus
- Seats never go negative or exceed capacity
- Even with latency, the final state is always correct

## Building for Release

### Android

```
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

To sign with a key (for Play Store):
- Create a keystore (one-time setup)
- Add signing config to `android/app/build.gradle`
- Then rebuild

### iOS

```
flutter build ipa --release
```

You'll need an Apple Developer account and valid signing certificates.

## Future Roadmap

📍 **Phase 2:** Dynamic ETA from distance + average speed (currently fixed at 5 min placeholder)  
🔔 **Phase 3:** Push notifications when your bus is 5 mins away  
📊 **Phase 4:** Analytics dashboard for campus mobility insights  
⭐ **Phase 5:** Rating system for driver + bus feedback  
📱 **Phase 6:** Multi-campus rollout (make it generic for any college)

## Known Limitations

- **ETA:** Currently fixed at 5 minutes. Will compute dynamically from distance + speed in v2.
- **GPS:** Requires location permissions and continuous internet (3G+ recommended).
- **Offline Mode:** Not yet implemented. App requires live connection to Firebase.
- **iOS:** Tested on emulator, needs real device testing before release.

## Contributing

Found a bug? Have a feature idea? Open an issue or submit a PR. We'd love your help.

## Credits

Built with ❤️ at IIT Mandi for the Google Developer Group TechSprint 2025.

**Team:** Siddhant Singh, Dev Pratap Singh Baghel, [Other team members]

## License

MIT License – feel free to fork, modify, and use in your own campus.

---

**Got questions?** Feel free to reach out or open an issue. Happy bussing! 🚌✨

```

***
