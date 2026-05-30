// Blind test (Tester A) written from spec only.
// Verifies properties of `kSubdistrictCentroids` without inspecting the
// generator or the generated map.
import 'package:test/test.dart';
import 'package:thai_provinces/thai_provinces.dart';

import 'package:thai_provinces_geo/src/centroids.g.dart';

// Thailand bounding box (decimal degrees, WGS84).
const double kLatMin = 5.5;
const double kLatMax = 20.5;
const double kLngMin = 97.0;
const double kLngMax = 105.7;

void main() {
  group('kSubdistrictCentroids', () {
    test('is non-empty and covers the vast majority of subdistricts', () {
      expect(kSubdistrictCentroids, isNotEmpty);
      // 7452 total subdistricts; allow a small shortfall for missing coords.
      expect(kSubdistrictCentroids.length, greaterThanOrEqualTo(7400));
    });

    test('every key resolves to a real subdistrict', () {
      final unresolved = <int>[];
      for (final code in kSubdistrictCentroids.keys) {
        if (subdistrictByCode(code) == null) {
          unresolved.add(code);
        }
      }
      expect(
        unresolved,
        isEmpty,
        reason: 'these codes do not resolve to a real subdistrict: '
            '${unresolved.take(20).toList()}'
            '${unresolved.length > 20 ? ' ... (${unresolved.length} total)' : ''}',
      );
    });

    test('every key is a 6-digit DOPA geocode', () {
      final badCodes = kSubdistrictCentroids.keys
          .where((code) => code < 100000 || code > 999999)
          .toList();
      expect(badCodes, isEmpty,
          reason: 'non 6-digit keys: ${badCodes.take(20).toList()}');
    });

    test('every value is a [lat, lng] pair inside Thailand bounding box', () {
      final badShape = <int>[];
      final outOfBox = <int>[];
      kSubdistrictCentroids.forEach((code, value) {
        if (value.length != 2) {
          badShape.add(code);
          return;
        }
        final lat = value[0];
        final lng = value[1];
        if (lat.isNaN ||
            lng.isNaN ||
            lat < kLatMin ||
            lat > kLatMax ||
            lng < kLngMin ||
            lng > kLngMax) {
          outOfBox.add(code);
        }
      });
      expect(badShape, isEmpty,
          reason: 'values not length-2: ${badShape.take(20).toList()}');
      expect(
        outOfBox,
        isEmpty,
        reason: 'coordinates outside Thailand bbox '
            '(lat $kLatMin..$kLatMax, lng $kLngMin..$kLngMax): '
            '${outOfBox.take(20).toList()}'
            '${outOfBox.length > 20 ? ' ... (${outOfBox.length} total)' : ''}',
      );
    });

    test('Bangkok 100101 is present near (13.751, 100.492)', () {
      final pt = kSubdistrictCentroids[100101];
      expect(pt, isNotNull, reason: 'Bangkok subdistrict 100101 missing');
      expect(pt!.length, 2);
      expect(pt[0], closeTo(13.751, 0.1)); // lat
      expect(pt[1], closeTo(100.492, 0.1)); // lng
    });

    test('a Chiang Mai subdistrict (province 50) is present in the north', () {
      // 500101 = Si Phum, Mueang Chiang Mai (province code 50).
      final pt = kSubdistrictCentroids[500101];
      expect(pt, isNotNull, reason: 'Chiang Mai subdistrict 500101 missing');
      expect(pt!.length, 2);
      final lat = pt[0];
      final lng = pt[1];
      expect(lat, inInclusiveRange(18.0, 20.0),
          reason: 'Chiang Mai lat should be ~18-20, got $lat');
      expect(lng, inInclusiveRange(98.0, 99.0),
          reason: 'Chiang Mai lng should be ~98-99, got $lng');
    });
  });
}
