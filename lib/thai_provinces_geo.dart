/// Offline GPS reverse-geocoding for Thailand: map a latitude/longitude to its
/// subdistrict (and thus district, province and postcode), with no network and
/// no GPS plugin — you bring the coordinate.
///
/// Pure Dart, built on the [`thai_provinces`](https://pub.dev/packages/thai_provinces)
/// data core (which is re-exported, so `Subdistrict`/`District`/`Province` are
/// available without a second import).
///
/// ```dart
/// import 'package:thai_provinces_geo/thai_provinces_geo.dart';
///
/// final sub = reverseGeocode(13.751, 100.492); // -> a Subdistrict
/// print('${sub?.nameTh} / ${sub?.district?.nameTh} / ${sub?.province?.nameTh}');
/// ```
///
/// The reference points come from the Department of Provincial Administration
/// (กรมการปกครอง, DOPA) subdistrict coordinate dataset (government factual data),
/// with gaps filled from kongvut/thai-province-data (MIT).
library;

export 'package:thai_provinces/thai_provinces.dart';

export 'src/geo.dart' show reverseGeocode, nearestSubdistrict, GeoMatch;
