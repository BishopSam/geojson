import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart' as map;
import 'package:latlong/latlong.dart';

class _CountriesPageState extends State<CountriesPage> {
  final polygons = <map.Polygon>[];

  @override
  void initState() {
    super.initState();
    processData();
  }

  Future<void> processData() async {
    final geojson = GeoJson();
    geojson.processedMultipolygons.listen((MultiPolygon multiPolygon) {
      for (final polygon in multiPolygon.polygons) {
        final geoSerie = GeoSerie(
            type: GeoSerieType.polygon,
            name: polygon.geoSeries[0].name,
            geoPoints: <GeoPoint>[]);
        for (final serie in polygon.geoSeries) {
          geoSerie.geoPoints.addAll(serie.geoPoints);
        }
        final color =
            Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                .withOpacity(0.3);
        final poly = map.Polygon(
            points: geoSerie.toLatLng(ignoreErrors: true), color: color);
        setState(() => polygons.add(poly));
      }
    });
    geojson.endSignal.listen((bool _) => geojson.dispose());
    // The data is from https://datahub.io/core/geo-countries
    final data = await rootBundle.loadString('assets/countries.geojson');
    final nameProperty = "ADMIN";
    unawaited(geojson.parse(data, nameProperty: nameProperty, verbose: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: map.FlutterMap(
      mapController: map.MapController(),
      options: map.MapOptions(
        center: LatLng(51.0, 0.0),
        zoom: 1.0,
      ),
      layers: [
        map.TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        map.PolygonLayerOptions(
          polygons: polygons,
        ),
      ],
    ));
  }
}

class CountriesPage extends StatefulWidget {
  @override
  _CountriesPageState createState() => _CountriesPageState();
}
