import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

const southStops = [
  LatLng(31.77517571199855, 76.9863637588779),
  LatLng(31.7722880819878, 76.98468011765827),
  LatLng(31.771401615116226, 76.98367321897823),
];

const northStops = [
  LatLng(31.781985431603733, 76.99521399095738),
  LatLng(31.78173213908091, 76.99425742005533),
  LatLng(31.780299780354888, 76.99356604127993),
];

class MapScreen extends StatefulWidget {
  final String tripId;

  const MapScreen({super.key, required this.tripId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  Position? _userLocation;
  late StreamSubscription<Position> _locationSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _busSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _currentBusData;
  bool _isBusLive = false;

  @override
  void initState() {
    super.initState();
    _getInitialLocation();
    _startLocationTracking();
    _listenToBus();
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    _busSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _getInitialLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _userLocation = position);
      _updateMarkers();
    } catch (e) {
      debugPrint('Error getting initial location: $e');
    }
  }

  void _startLocationTracking() {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (!mounted) return;
      setState(() => _userLocation = position);
      _updateMarkers();
    });
  }

  void _listenToBus() {
    if (widget.tripId.isEmpty) return;
    _busSubscription = _firestore
        .collection('live_buses')
        .doc(widget.tripId)
        .snapshots()
        .listen((docSnap) {
      if (!mounted) return;
      if (docSnap.exists) {
        _currentBusData = docSnap.data();
        _isBusLive = true;
      } else {
        _currentBusData = null;
        _isBusLive = false;
      }
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    final Set<Marker> merged = {};

    // Bus marker (only the selected bus when it is live)
    if (_currentBusData != null && _isBusLive) {
      final data = _currentBusData!;
      double lat = 31.7783;
      double lng = 76.9920;
      final rawLat = data['lat'];
      final rawLng = data['lng'];
      if (rawLat is num) lat = rawLat.toDouble();
      if (rawLng is num) lng = rawLng.toDouble();
      final driverSeats = (data['driver_seats_left'] ?? 0) as num;
      final studentDelta = (data['student_delta'] ?? 0) as num;
      final seatsLeft = (driverSeats + studentDelta).toInt().clamp(0, 999);
      final eta = (data['eta_minutes'] ?? 0) as int;

      merged.add(
        Marker(
          markerId: MarkerId(widget.tripId),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: 'Bus ${widget.tripId.replaceAll('bus_', '').toUpperCase()}',
            snippet: 'Seats: $seatsLeft   ETA: ${eta}m',
          ),
        ),
      );
    }

    // South campus stops (cyan)
    for (int i = 0; i < southStops.length; i++) {
      merged.add(
        Marker(
          markerId: MarkerId('south_stop_${i + 1}'),
          position: southStops[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueCyan,
          ),
          infoWindow: InfoWindow(title: 'South Stop ${i + 1}'),
        ),
      );
    }

    // North campus stops (green)
    for (int i = 0; i < northStops.length; i++) {
      merged.add(
        Marker(
          markerId: MarkerId('north_stop_${i + 1}'),
          position: northStops[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(title: 'North Stop ${i + 1}'),
        ),
      );
    }

    // User marker (violet)
    merged.removeWhere((m) => m.markerId == const MarkerId('you'));
    merged.add(
      Marker(
        markerId: const MarkerId('you'),
        position: _userLocation != null
            ? LatLng(_userLocation!.latitude, _userLocation!.longitude)
            : const LatLng(31.7783, 76.9920),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    if (mounted) {
      setState(() {
        _markers
          ..clear()
          ..addAll(merged);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Location – Live'),
        elevation: 0,
      ),
      body: Stack(children: [
  GoogleMap(
    initialCameraPosition: const CameraPosition(target: LatLng(31.7783, 76.9920), zoom: 14),
    markers: _markers,
    onMapCreated: (c) => _controller = c,
  ),
  // Legend (top-right)
  Positioned(
    right: 12,
    top: 12,
    child: Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _LegendRow(color: Colors.red, label: 'Bus'),
            SizedBox(height: 4),
            _LegendRow(color: Colors.purple, label: 'You'),
            SizedBox(height: 4),
            _LegendRow(color: Colors.cyan, label: 'South Stop'),
            SizedBox(height: 4),
            _LegendRow(color: Colors.green, label: 'North Stop'),
          ],
        ),
      ),
    ),
  ),
  // Bus not live banner
  if (!_isBusLive)
    Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: Card(
        color: Colors.orange,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            const Icon(Icons.location_off, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Bus not sharing live location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text('Driver will start tracking soon', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
            ])),
          ]),
        ),
      ),
    ),
]),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
