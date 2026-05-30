// Blind test (Tester B) — written from the SHARED CONTRACT spec only,
// without reading lib/src/geo.dart. Validates reverse-geocoding behavior
// against independently-known Thai coordinates.
//
// Contract under test (from spec):
//   Subdistrict? reverseGeocode(double lat, double lng, {double? maxKm});
//   GeoMatch?    nearestSubdistrict(double lat, double lng, {double? maxKm});
//   class GeoMatch {
//     final Subdistrict subdistrict;
//     final double distanceKm;
//     District? get district;
//     Province? get province;
//     int get postcode;
//   }
//
// Province codes (verified via subdistrictByCode/provinceByCode):
//   Bangkok = 10, Chiang Mai = 50, Phuket = 83,
//   Nakhon Ratchasima = 30, Khon Kaen = 40.

import 'package:test/test.dart';
import 'package:thai_provinces_geo/thai_provinces_geo.dart';

void main() {
  group('reverseGeocode — known city coordinates land in the right province',
      () {
    test('Grand Palace, Bangkok (13.751, 100.492) -> province 10', () {
      final s = reverseGeocode(13.751, 100.492);
      expect(s, isNotNull,
          reason: 'A point in central Bangkok must resolve to a subdistrict.');
      expect(s!.province?.code, 10,
          reason: 'Grand Palace is in Bangkok (province code 10).');
    });

    test('central Chiang Mai (18.788, 98.985) -> province 50', () {
      final s = reverseGeocode(18.788, 98.985);
      expect(s, isNotNull);
      expect(s!.province?.code, 50,
          reason: 'This point is in Mueang Chiang Mai (province code 50).');
    });

    test('Phuket town (7.878, 98.398) -> province 83', () {
      final s = reverseGeocode(7.878, 98.398);
      expect(s, isNotNull);
      expect(s!.province?.code, 83,
          reason: 'Phuket town is in Phuket (province code 83).');
    });

    // Extra unambiguous interior city points (deep inside province, not on a
    // border) chosen + justified from a map:
    //   Khon Kaen city center sits centrally in Khon Kaen province (code 40).
    //   Nakhon Ratchasima (Korat) city center sits centrally in its large
    //   province (code 30). Neither is near a provincial boundary, so a
    //   nearest-centroid match is unambiguous.
    test('Khon Kaen city (16.439, 102.835) -> province 40', () {
      final s = reverseGeocode(16.439, 102.835);
      expect(s, isNotNull);
      expect(s!.province?.code, 40,
          reason: 'Khon Kaen city center is in Khon Kaen (province code 40).');
    });

    test('Nakhon Ratchasima city (14.970, 102.100) -> province 30', () {
      final s = reverseGeocode(14.970, 102.100);
      expect(s, isNotNull);
      expect(s!.province?.code, 30,
          reason: 'Korat city center is in Nakhon Ratchasima (province 30).');
    });
  });

  group('nearestSubdistrict — match agrees with reverseGeocode', () {
    test('returns a GeoMatch whose subdistrict == reverseGeocode result', () {
      // Use Bangkok point.
      final lat = 13.751, lng = 100.492;
      final m = nearestSubdistrict(lat, lng);
      final s = reverseGeocode(lat, lng);

      expect(m, isNotNull);
      expect(s, isNotNull);
      // Same underlying subdistrict (compare by stable 6-digit code).
      expect(m!.subdistrict.code, s!.code,
          reason:
              'nearestSubdistrict and reverseGeocode must agree on the match.');
      // GeoMatch convenience accessors should mirror the subdistrict.
      expect(m.province?.code, s.province?.code);
      expect(m.district?.code, s.district?.code);
      expect(m.postcode, s.postcode);
    });

    test('distanceKm is non-negative and small (<30 km) for an on-land point',
        () {
      final m = nearestSubdistrict(13.751, 100.492);
      expect(m, isNotNull);
      expect(m!.distanceKm, greaterThanOrEqualTo(0.0));
      expect(m.distanceKm, lessThan(30.0),
          reason:
              'A point inside Bangkok should be very close to a subdistrict '
              'centroid.');
    });

    test('distanceKm small for each of the other known city points', () {
      for (final p in const [
        [18.788, 98.985], // Chiang Mai
        [7.878, 98.398], // Phuket
        [16.439, 102.835], // Khon Kaen
        [14.970, 102.100], // Korat
      ]) {
        final m = nearestSubdistrict(p[0], p[1]);
        expect(m, isNotNull, reason: 'on-land point should match: $p');
        expect(m!.distanceKm, greaterThanOrEqualTo(0.0));
        expect(m.distanceKm, lessThan(30.0),
            reason: 'on-land point $p should be near a centroid');
      }
    });
  });

  group('maxKm guard', () {
    // Gulf of Guinea (0, 0): nowhere near Thailand — thousands of km away.
    test('nearestSubdistrict(0, 0, maxKm: 1) -> null', () {
      final m = nearestSubdistrict(0, 0, maxKm: 1);
      expect(m, isNull,
          reason: '(0,0) is thousands of km from Thailand; within 1 km there '
              'is no subdistrict.');
    });

    test('reverseGeocode(0, 0, maxKm: 1) -> null', () {
      final s = reverseGeocode(0, 0, maxKm: 1);
      expect(s, isNull);
    });

    test('without maxKm, (0,0) still returns the nearest (non-null)', () {
      final m = nearestSubdistrict(0, 0);
      expect(m, isNotNull,
          reason: 'With no cap, the nearest subdistrict is always returned.');
      expect(m!.distanceKm, greaterThan(1.0),
          reason: 'The nearest Thai subdistrict to (0,0) is far away.');

      final s = reverseGeocode(0, 0);
      expect(s, isNotNull);
    });

    test('a generous maxKm still resolves an on-land Bangkok point', () {
      final m = nearestSubdistrict(13.751, 100.492, maxKm: 50);
      expect(m, isNotNull);
      expect(m!.province?.code, 10);
    });
  });

  test('non-finite coordinates return null (no garbage match)', () {
    expect(reverseGeocode(double.nan, 100.5), isNull);
    expect(nearestSubdistrict(13.75, double.infinity), isNull);
    expect(nearestSubdistrict(double.negativeInfinity, double.nan), isNull);
  });
}
