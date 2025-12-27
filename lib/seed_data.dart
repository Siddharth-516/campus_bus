import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedBusData() async {
  final db = FirebaseFirestore.instance;

  final buses = [
    {
      'bus_id': 'bus_a',
      'code': 'A',
      'route': 'South ↔ North Campus',
      'total_seats': 27,
    },
    {
      'bus_id': 'bus_b',
      'code': 'B',
      'route': 'South ↔ North Campus',
      'total_seats': 27,
    },
    {
      'bus_id': 'bus_c',
      'code': 'C',
      'route': 'North ↔ South Campus',
      'total_seats': 27,
    },
    {
      'bus_id': 'bus_d',
      'code': 'D',
      'route': 'North ↔ South Campus',
      'total_seats': 27,
    },
    {
      'bus_id': 'bus_e',
      'code': 'E',
      'route': 'South ↔ Mandi',
      'total_seats': 27,
    },
    {
      'bus_id': 'bus_f',
      'code': 'F',
      'route': 'South ↔ Mandi',
      'total_seats': 27,
    },
    {
      'bus_id': 'bus_g',
      'code': 'G',
      'route': 'Campus ↔ Mandi',
      'total_seats': 27,
    },
    {
      'bus_id': 'bus_h',
      'code': 'H',
      'route': 'South ↔ North Campus',
      'total_seats': 27,
    },
  ];

  final batch = db.batch();
  for (final bus in buses) {
    final id = bus['bus_id'] as String;
    final docRef = db.collection('buses').doc(id);
    batch.set(docRef, bus);
  }

  await batch.commit();
}
