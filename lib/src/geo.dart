import 'dart:math' as math;

import 'package:thai_provinces/thai_provinces.dart';

import 'centroids.g.dart';

/// The result of a reverse-geocode: the matched [subdistrict] plus the
/// great-circle distance (in kilometres) from the query point to that
/// subdistrict's reference point.
class GeoMatch {
  /// Creates a geocode match.
  const GeoMatch({required this.subdistrict, required this.distanceKm});

  /// The nearest subdistrict (ตำบล/แขวง).
  final Subdistrict subdistrict;

  /// Great-circle distance (km) from the query point to the subdistrict's
  /// reference point.
  final double distanceKm;

  /// The owning district, or `null` if unknown.
  District? get district => subdistrict.district;

  /// The owning province, or `null` if unknown.
  Province? get province => subdistrict.province;

  /// The subdistrict's 5-digit postal code.
  int get postcode => subdistrict.postcode;
}

/// Mean radius of the Earth in kilometres (WGS84 mean).
const double _earthRadiusKm = 6371.0;

/// Degrees-to-radians conversion factor.
const double _degToRad = math.pi / 180.0;

/// Great-circle distance in kilometres between two points given in decimal
/// degrees (WGS84), via the haversine formula.
double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
  final dLat = (lat2 - lat1) * _degToRad;
  final dLng = (lng2 - lng1) * _degToRad;
  final rLat1 = lat1 * _degToRad;
  final rLat2 = lat2 * _degToRad;

  final sinDLat = math.sin(dLat / 2);
  final sinDLng = math.sin(dLng / 2);
  final a =
      sinDLat * sinDLat + math.cos(rLat1) * math.cos(rLat2) * sinDLng * sinDLng;
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return _earthRadiusKm * c;
}

/// Returns the [Subdistrict] whose reference point is nearest to the
/// coordinate ([lat], [lng]) in decimal degrees (WGS84), or `null` when
/// [maxKm] is given and the nearest reference point is farther than that.
///
/// This is a nearest-reference-point lookup, accurate to the subdistrict
/// *area*; it can mis-resolve right at a subdistrict border.
Subdistrict? reverseGeocode(double lat, double lng, {double? maxKm}) =>
    nearestSubdistrict(lat, lng, maxKm: maxKm)?.subdistrict;

/// Like [reverseGeocode] but also returns the matched distance via [GeoMatch],
/// or `null` when nothing matches (empty dataset or beyond [maxKm]).
///
/// Scans every subdistrict reference point linearly (~7.4k entries) and keeps
/// the one with the smallest haversine distance. Reference points whose code
/// does not resolve via [subdistrictByCode] are skipped. When [maxKm] is given,
/// the result is `null` if the closest resolvable subdistrict is farther than
/// [maxKm] kilometres. A non-finite [lat]/[lng] (NaN/Infinity) returns `null`.
GeoMatch? nearestSubdistrict(double lat, double lng, {double? maxKm}) {
  // A non-finite coordinate has no nearest point; bail rather than return a
  // garbage match with a NaN distance.
  if (!lat.isFinite || !lng.isFinite) return null;

  Subdistrict? best;
  var bestDistKm = double.infinity;

  for (final entry in kSubdistrictCentroids.entries) {
    final point = entry.value;
    if (point.length < 2) continue;
    final d = _haversineKm(lat, lng, point[0], point[1]);
    if (d >= bestDistKm) continue;

    final sub = subdistrictByCode(entry.key);
    if (sub == null) continue; // code in dataset but not in core data
    best = sub;
    bestDistKm = d;
  }

  if (best == null) return null; // empty dataset or nothing resolvable
  if (maxKm != null && bestDistKm > maxKm) return null;
  return GeoMatch(subdistrict: best, distanceKm: bestDistKm);
}
