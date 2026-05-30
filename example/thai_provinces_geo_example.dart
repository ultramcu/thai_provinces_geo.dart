// Run: dart run example/thai_provinces_geo_example.dart
import 'package:thai_provinces_geo/thai_provinces_geo.dart';

void main() {
  // A few coordinates (lat, lng) — you bring these from any GPS source.
  const points = [
    (13.7512, 100.4923), // Grand Palace, Bangkok
    (18.7880, 98.9850), // central Chiang Mai
    (7.8780, 98.3980), // Phuket town
  ];

  for (final (lat, lng) in points) {
    final match = nearestSubdistrict(lat, lng);
    if (match == null) {
      print('$lat, $lng -> no match');
      continue;
    }
    print('$lat, $lng -> ${match.subdistrict.nameTh}, '
        '${match.district?.nameTh}, ${match.province?.nameTh} '
        '${match.postcode} (~${match.distanceKm.toStringAsFixed(1)} km)');
  }

  // Or just the subdistrict, with an optional max distance:
  final sub = reverseGeocode(13.7512, 100.4923, maxKm: 50);
  print('reverseGeocode -> ${sub?.nameEn} / ${sub?.province?.nameEn}');
}
