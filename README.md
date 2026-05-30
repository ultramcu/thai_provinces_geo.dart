# thai_provinces_geo

[![pub package](https://img.shields.io/pub/v/thai_provinces_geo.svg)](https://pub.dev/packages/thai_provinces_geo)
[![pub points](https://img.shields.io/pub/points/thai_provinces_geo)](https://pub.dev/packages/thai_provinces_geo/score)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Offline GPS reverse-geocoding for Thailand — turn a latitude/longitude into its
**ตำบล → อำเภอ → จังหวัด + รหัสไปรษณีย์** (subdistrict → district → province +
postcode). Pure Dart, **no network and no GPS plugin** (you bring the
coordinate), built on the [`thai_provinces`](https://pub.dev/packages/thai_provinces)
data core.

## Install

```sh
dart pub add thai_provinces_geo
```

Pulls in exactly one thing: the `thai_provinces` data core (which is
re-exported, so `Subdistrict`/`District`/`Province` are available without a
second import).

## Usage

```dart
import 'package:thai_provinces_geo/thai_provinces_geo.dart';

// Bring a coordinate from any source (a GPS plugin, a map tap, a stored point).
final sub = reverseGeocode(13.7512, 100.4923); // Grand Palace, Bangkok
print('${sub?.nameTh}, ${sub?.district?.nameTh}, ${sub?.province?.nameTh} '
    '${sub?.postcode}');
// พระบรมมหาราชวัง, เขตพระนคร, กรุงเทพมหานคร 10200

// Need the distance too, or an optional cutoff?
final match = nearestSubdistrict(7.8780, 98.3980, maxKm: 50);
print('${match?.province?.nameEn} (${match?.distanceKm.toStringAsFixed(1)} km)');
// Phuket (1.2 km)
```

- `reverseGeocode(lat, lng, {maxKm})` → the nearest `Subdistrict?` (or `null`
  when `maxKm` is given and the nearest reference point is farther).
- `nearestSubdistrict(lat, lng, {maxKm})` → a `GeoMatch?` with the
  `subdistrict`, the great-circle `distanceKm`, and `district` / `province` /
  `postcode` getters.

Pairs naturally with
[`thai_provinces_flutter`](https://pub.dev/packages/thai_provinces_flutter):
prefill an address picker from a coordinate via
`controller.setFromCodes(subdistrictCode: reverseGeocode(lat, lng)?.code)`.

## Accuracy

This is a **nearest-reference-point** lookup: each of the 7,452 subdistricts has
one representative point, and a query resolves to the subdistrict whose point is
closest. That is accurate to the subdistrict *area* and ideal for prefilling a
form (the user confirms), but it can resolve to a neighbour right at a
subdistrict border. True point-in-polygon would need a much larger boundary
dataset; it is out of scope here.

## Data source & license

This package is [MIT](LICENSE) licensed.

The subdistrict reference points are derived from the **Department of Provincial
Administration (กรมการปกครอง, DOPA)** subdistrict coordinate dataset — government
administrative data; the factual coordinates and geocodes are not subject to
copyright. Gaps are filled from
[`kongvut/thai-province-data`](https://github.com/kongvut/thai-province-data)
(MIT). Credit DOPA when redistributing the coordinate data.

The embedded table (`lib/src/centroids.g.dart`) is regenerated with
`tool/gen_centroids.py`.
