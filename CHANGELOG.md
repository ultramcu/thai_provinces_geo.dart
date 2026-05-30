## 0.1.1

- Docs: cite the source dataset — the Department of Provincial Administration
  (กรมการปกครอง, DOPA) subdistrict coordinate data published on
  [data.go.th](https://data.go.th/dataset/item_c6d42e1b-3219-47e1-b6b7-dfe914f27910)
  — in the data-source section. No code changes.

## 0.1.0

- Initial release. Offline GPS reverse-geocoding for Thailand: `reverseGeocode(lat, lng)`
  and `nearestSubdistrict(lat, lng, {maxKm})` map a coordinate to its subdistrict
  (and thus district, province and postcode) via a nearest-reference-point lookup
  over an embedded table of DOPA subdistrict points.
- Pure Dart, BYO coordinates (no GPS plugin, no network); depends only on
  `thai_provinces` (re-exported, so `Subdistrict`/`District`/`Province` come along).
- `GeoMatch` carries the matched subdistrict plus the great-circle distance.
- Reference points: 7,452 subdistricts (Department of Provincial Administration /
  กรมการปกครอง dataset, gaps filled from kongvut/thai-province-data, MIT).
