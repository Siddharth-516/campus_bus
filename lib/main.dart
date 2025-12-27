import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_screen.dart';
import 'seed_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

// ======= ETA HELPERS =======
const double southGateLat = 31.7783;
const double southGateLng = 76.9920;

double distanceMeters({
  required double fromLat,
  required double fromLng,
  required double toLat,
  required double toLng,
}) {
  return Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
}

int computeEtaMinutes(double distanceMeters, {double speedMps = 5.56}) {
  if (speedMps <= 0) return 0;
  final seconds = distanceMeters / speedMps;
  final minutes = (seconds / 60).round();
  if (minutes < 0) return 0;
  if (minutes > 120) return 120;
  return minutes;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CampusBusApp());
}

// ======= CREDITS SCREEN =======
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const SizedBox.shrink(),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_bus,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Campus Bus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Live Bus Tracking',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Development Team',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _TeamMemberCard(name: 'Siddharth Gupta'),
                  const SizedBox(height: 12),
                  _TeamMemberCard(name: 'Dev Pratap Singh Baghel'),
                  const SizedBox(height: 12),
                  _TeamMemberCard(name: 'Ritesh Poswal'),
                  const SizedBox(height: 12),
                  _TeamMemberCard(name: 'Ramdayal Dhattarwal'),
                  const SizedBox(height: 32),
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Campus Bus is a real-time bus tracking application built for IIT Mandi students and drivers.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Features include live location tracking, real-time seat availability, and interactive maps.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Built with Flutter & Firebase.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.school,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Indian Institute of Technology',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        Text(
                          'Mandi',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final String name;

  const _TeamMemberCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

String formatBusId(String raw) {
  if (raw.startsWith('bus_') && raw.length >= 5) {
    final letter = raw.substring(4).toUpperCase();
    return 'Bus $letter';
  }
  return raw;
}

class CampusBusApp extends StatefulWidget {
  const CampusBusApp({super.key});

  @override
  State<CampusBusApp> createState() => _CampusBusAppState();
}

class _CampusBusAppState extends State<CampusBusApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'system';
    setState(() {
      _themeMode = switch (theme) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };
    });
  }

  void _setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      _ => 'system',
    };
    await prefs.setString('theme', modeStr);
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Bus',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066CC),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066CC),
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: RoleSelectionScreen(onThemeChange: _setTheme),
    );
  }
}

// ==================== ROLE SELECTION ====================
class RoleSelectionScreen extends StatelessWidget {
  final Function(ThemeMode) onThemeChange;

  const RoleSelectionScreen({super.key, required this.onThemeChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_bus,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Campus Bus',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Live Bus Tracking for IIT Mandi',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person),
                    label: const Text('Continue as Student'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StudentHomeScreen(onThemeChange: onThemeChange),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.directions_bus),
                    label: const Text('Continue as Driver'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DriverLoginScreen(onThemeChange: onThemeChange),
                        ),
                      );
                    },
                  ),
                ),
                // debug-only seed moved to Student menu
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== STUDENT FLOW ====================
class StudentHomeScreen extends StatelessWidget {
  final Function(ThemeMode) onThemeChange;

  const StudentHomeScreen({super.key, required this.onThemeChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Buses'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
  onSelected: (value) {
    switch (value) {
      case 'home':
        Navigator.pop(context);
        break;
      case 'schedule':
        _openBusSchedule(context);
        break;
      case 'credits':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreditsScreen()),
        );
        break;
      case 'seed':
        if (kDebugMode) {
          _seedData(context);
        }
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(
              onThemeChange: onThemeChange,
            ),
          ),
        );
        break;
    }
  },
  itemBuilder: (_) => [
    const PopupMenuItem(value: 'home', child: Text('Home')),
    const PopupMenuItem(value: 'schedule', child: Text('Bus Schedule')),
    const PopupMenuItem(value: 'credits', child: Text('Credits')),
    if (kDebugMode) const PopupMenuItem(value: 'seed', child: Text('Seed Demo Data')),
    const PopupMenuItem(value: 'settings', child: Text('Settings')),
  ],
),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('live_buses')
            .orderBy('eta_minutes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_bus_filled,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No buses running right now',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
                final busId = data['bus_id'] ?? docs[index].id;
                final code = data['code'];
                final eta = data['eta_minutes'] ?? 0;
                final driverSeats = data['driver_seats_left'] ?? 0;
                final studentDelta = data['student_delta'] ?? 0;
                final seatsLeft = (driverSeats + studentDelta).clamp(0, 999);
                final route = data['route'] ?? 'South ↔ North Campus';

                final busName = code != null
                  ? 'Bus $code'
                  : 'Bus ${busId.toString().replaceAll('bus_', '').toUpperCase()}';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapScreen(tripId: busId),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              busName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'ETA: ${eta}m',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          route,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.event_seat,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$seatsLeft seats available',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openBusSchedule(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bus Schedule'),
        content: const Text(
          'Open the official IIT Mandi bus schedule PDF.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse(
                'https://drive.google.com/uc?export=download&id=1-CXpkP3STL3xBLvvG6SyzFxioBFgzErx',
              );
              // Prefer launching in the system browser on Android; fallback to
              // an in-app browser view if that fails.
              final launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );

              if (!launched) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.inAppBrowserView,
                );
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Open PDF'),
          ),
        ],
      ),
    );
  }

  void _seedData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seed Demo Data'),
        content: const Text(
          'This will create Buses A–H in Firestore.\n\nUse this only for testing in development mode.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await seedBusData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Buses A–H seeded to Firestore'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Seed'),
          ),
        ],
      ),
    );
  }
}

// ==================== DRIVER FLOW ====================
class DriverLoginScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChange;

  const DriverLoginScreen({super.key, required this.onThemeChange});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _controller = TextEditingController();
  String? _error;

  void _login() {
    final id = _controller.text.trim();
    if (id.isEmpty) {
      setState(() => _error = 'Enter a driver ID');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverBusSelectionScreen(
          driverId: id,
          onThemeChange: widget.onThemeChange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Login'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Enter Driver ID',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Driver ID',
                    errorText: _error,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.badge),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DriverBusSelectionScreen extends StatelessWidget {
  final String driverId;
  final Function(ThemeMode) onThemeChange;

  const DriverBusSelectionScreen({
    super.key,
    required this.driverId,
    required this.onThemeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver: $driverId'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      onThemeChange: onThemeChange,
                    ),
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('buses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_bus,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No buses configured',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final busId = data['bus_id'] ?? docs[index].id;
              final code = data['code'];
              final displayName =
                  code != null ? 'Bus $code' : 'Bus ${busId.replaceAll('bus_', '').toUpperCase()}';
              final route = data['route'] ?? 'Route TBD';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DriverSeatPanelScreen(
                          driverId: driverId,
                          busId: busId,
                          onThemeChange: onThemeChange,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          route,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: $busId',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DriverSeatPanelScreen extends StatefulWidget {
  final String driverId;
  final String busId;
  final Function(ThemeMode) onThemeChange;

  const DriverSeatPanelScreen({
    super.key,
    required this.driverId,
    required this.busId,
    required this.onThemeChange,
  });

  @override
  State<DriverSeatPanelScreen> createState() => _DriverSeatPanelScreenState();
}

class _DriverSeatPanelScreenState extends State<DriverSeatPanelScreen> {
  int driverSeatsLeft = 0;
  int studentDelta = 0;
  int totalSeats = 27;
  bool loading = true;
  bool isLiveTracking = false;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void dispose() {
    _stopLiveTracking();
    super.dispose();
  }

  void _subscribe() {
    final liveRef = FirebaseFirestore.instance.collection('live_buses').doc(widget.busId);
    liveRef.snapshots().listen((snap) async {
      if (!snap.exists) {
        final busSnap = await FirebaseFirestore.instance
            .collection('buses')
            .doc(widget.busId)
            .get();
        final total = busSnap.data()?['total_seats'] ?? 27;

        // Compute an initial ETA instead of hardcoding 5 minutes.
        final initialDistance = distanceMeters(
          fromLat: 31.7783,
          fromLng: 76.9920,
          toLat: southGateLat,
          toLng: southGateLng,
        );
        final initialEta = computeEtaMinutes(initialDistance);

        await liveRef.set({
          'bus_id': widget.busId,
          'lat': 31.7783,
          'lng': 76.9920,
          'driver_seats_left': total,
          'student_delta': 0,
          'eta_minutes': initialEta,
          'code': busSnap.data()?['code'],
          'route': busSnap.data()?['route'],
        });

        if (!mounted) return;
        setState(() {
          driverSeatsLeft = total;
          studentDelta = 0;
          totalSeats = total;
          loading = false;
        });
      } else {
        final data = snap.data() as Map;
        if (!mounted) return;
        final ds = data['driver_seats_left'];
        final sd = data['student_delta'];
        setState(() {
          driverSeatsLeft = ds is num ? ds.toInt() : (ds ?? driverSeatsLeft);
          studentDelta = sd is num ? sd.toInt() : (sd ?? studentDelta);
          loading = false;
        });
      }
    });
  }

  Future<void> _startLiveTracking() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📍 Location permission required')));
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Location permission denied permanently')));
        return;
      }

      setState(() => isLiveTracking = true);
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
      ).listen((Position position) => _updateBusLocation(position.latitude, position.longitude));

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🚀 Live location tracking started'), duration: Duration(seconds: 2)));
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _stopLiveTracking() {
    if (isLiveTracking && _positionSubscription != null) {
      _positionSubscription?.cancel();
      setState(() => isLiveTracking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⛔ Live location tracking stopped'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateBusLocation(double lat, double lng) async {
    // 1. Pick a reference stop (South Campus gate)
    const stopLat = 31.7783;
    const stopLng = 76.9920;

    // 2. Distance in meters
    final distance = Geolocator.distanceBetween(
      lat,
      lng,
      stopLat,
      stopLng,
    );

    // 3. Convert distance -> ETA (assume 20 km/h = 5.56 m/s)
    final seconds = distance / 5.56;
    var etaMinutes = (seconds / 60).round();
    if (etaMinutes < 0) etaMinutes = 0;
    if (etaMinutes > 120) etaMinutes = 120;

    // 4. Write everything back to Firestore (including new eta)
    await FirebaseFirestore.instance
        .collection('live_buses')
        .doc(widget.busId)
        .update({
      'lat': lat,
      'lng': lng,
      'eta_minutes': etaMinutes,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateDriverSeats(int delta) async {
    final liveRef = FirebaseFirestore.instance.collection('live_buses').doc(widget.busId);

    try {
      await FirebaseFirestore.instance.runTransaction((txn) async {
        final snap = await txn.get(liveRef);

        // If doc doesn't exist, create it first with sensible defaults
        if (!snap.exists) {
          await txn.set(liveRef, {
            'bus_id': widget.busId,
            'driver_seats_left': totalSeats,
            'student_delta': 0,
            'lat': 31.7783,
            'lng': 76.9920,
            'eta_minutes': 5,
            'code': '',
            'route': 'South - North Campus',
          });

          // Re-read to apply the delta on the newly created doc
          final newSnap = await txn.get(liveRef);
          final data = newSnap.data() as Map<String, dynamic>;
          final currentRaw = data['driver_seats_left'] ?? 0;
          final current = currentRaw is num ? currentRaw.toInt() : (currentRaw as int? ?? 0);
          var next = current + delta;
          if (next < 0) next = 0;
          if (next > totalSeats) next = totalSeats;
          txn.update(liveRef, {
            'driver_seats_left': next,
            'last_updated_by': widget.driverId,
            'updated_at': FieldValue.serverTimestamp(),
          });
          return;
        }

        // Doc exists, apply the delta
        final data = snap.data() as Map<String, dynamic>;
        final currentRaw = data['driver_seats_left'] ?? 0;
        final current = currentRaw is num ? currentRaw.toInt() : (currentRaw as int? ?? 0);
        var next = current + delta;
        if (next < 0) next = 0;
        if (next > totalSeats) next = totalSeats;
        txn.update(liveRef, {
          'driver_seats_left': next,
          'last_updated_by': widget.driverId,
          'updated_at': FieldValue.serverTimestamp(),
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seats updated'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating seats: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSeats = (driverSeatsLeft + studentDelta).clamp(0, 999);
    return Scaffold(
      appBar: AppBar(title: Text('Bus ${widget.busId.replaceAll('bus_', '').toUpperCase()}'), elevation: 0),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: isLiveTracking ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        Row(children: [
                          Icon(isLiveTracking ? Icons.location_on : Icons.location_off,
                              color: isLiveTracking ? Colors.green : Colors.orange),
                          const SizedBox(width: 12),
                          Text(isLiveTracking ? '📍 Live Location: ON' : '⛔ Live Location: OFF',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isLiveTracking ? Colors.green : Colors.orange,
                              )),
                        ]),
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, child: !isLiveTracking
                            ? ElevatedButton.icon(onPressed: _startLiveTracking, icon: const Icon(Icons.play_arrow), label: const Text('Start Live Location'))
                            : ElevatedButton.icon(onPressed: _stopLiveTracking, icon: const Icon(Icons.stop), label: const Text('Stop Live Location'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red))),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                      Text('Total Seats', style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 8),
                      Text('$totalSeats', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
                    ])))),
                    const SizedBox(width: 12),
                    Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                      Text('Available Seats', style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 8),
                      Text('$effectiveSeats', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
                    ])))),
                  ]),
                  const SizedBox(height: 16),
                  Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                    Text('Shown to Students', style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 8),
                    Text('$effectiveSeats seats left', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: effectiveSeats > 10 ? Colors.green : effectiveSeats > 5 ? Colors.orange : Colors.red,
                    )),
                  ]))),
                  const SizedBox(height: 32),
                  Row(children: [
                    Expanded(child: ElevatedButton.icon(onPressed: !loading ? () => _updateDriverSeats(-1) : null, icon: const Icon(Icons.remove), label: const Text('One Boarded'))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton.icon(onPressed: !loading ? () => _updateDriverSeats(1) : null, icon: const Icon(Icons.add), label: const Text('One Left'))),
                  ]),
                ],
              ),
            ),
    );
  }
}

// ==================== SETTINGS SCREEN ====================
class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChange;

  const SettingsScreen({super.key, required this.onThemeChange});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _currentMode;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'system';
    setState(() {
      _currentMode = switch (theme) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };
    });
  }

  void _setTheme(ThemeMode mode) {
    widget.onThemeChange(mode);
    setState(() => _currentMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode'),
                  value: ThemeMode.light,
                  groupValue: _currentMode,
                  onChanged: (mode) {
                    if (mode != null) _setTheme(mode);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Mode'),
                  value: ThemeMode.dark,
                  groupValue: _currentMode,
                  onChanged: (mode) {
                    if (mode != null) _setTheme(mode);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: _currentMode,
                  onChanged: (mode) {
                    if (mode != null) _setTheme(mode);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
