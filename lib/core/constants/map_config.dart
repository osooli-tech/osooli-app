/// Mapbox raster tiles, matching the styles the web dashboard uses
/// (light-v11 and satellite-streets-v12). Set [token] to the same
/// MAPBOX_TOKEN the web uses; while it is empty the app falls back to
/// OpenStreetMap tiles so the map still renders.
class MapConfig {
  static const token = String.fromEnvironment(
    'MAPBOX_TOKEN',
    defaultValue:
        'pk.eyJ1Ijoic2FrdWtpMTIzNCIsImEiOiJjbXF0Z2FvMjkwZDRkMnlzYmFhdXdmNDBsIn0.yAsK_j_dwG2tN9wipHEOuw',
  );

  static const _lightStyle = 'mapbox/light-v11';
  static const _satelliteStyle = 'mapbox/satellite-streets-v12';
  static const _osmFallback = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static String get standardTiles => _tiles(_lightStyle);

  static String get satelliteTiles => _tiles(_satelliteStyle);

  static String _tiles(String style) => token.isEmpty
      ? _osmFallback
      : 'https://api.mapbox.com/styles/v1/$style/tiles/256/{z}/{x}/{y}@2x?access_token=$token';
}
