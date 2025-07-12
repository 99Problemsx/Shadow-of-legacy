# Window Lights Plugin

Lässt Fenster in Häusern nachts leuchten mit sanfter Animation.

## Features

- **Automatische Lichter**: Lichter gehen von 19:00 bis 06:00 Uhr an
- **Sanfte Animation**: Lichter pulsieren leicht für lebendigen Effekt
- **Wetterabhängig**: Lichter gehen auch bei Regen/Sturm an
- **Event-basiert**: Erstelle Events mit "Licht", "Light", "Fenster" oder "Window" im Namen
- **Tile-basiert**: Automatische Erkennung von Fenster-Tiles (konfigurierbar)

## Verwendung

### Methode 1: Events erstellen
1. Erstelle ein Event an der Position wo ein Licht sein soll
2. Benenne das Event mit einem dieser Wörter:
   - "Licht" oder "Light"
   - "Fenster" oder "Window"
3. Das Event kann leer sein (nur der Name ist wichtig)

### Methode 2: Tile-IDs konfigurieren
1. Öffne `WindowLights.rb`
2. Finde die Methode `is_window_tile?`
3. Füge die Tile-IDs deiner Fenster-Tiles hinzu:
   ```ruby
   window_tile_ids = [
     1234, 1235, 1236  # Ersetze mit deinen Tile-IDs
   ]
   ```

## Konfiguration

In `WindowLights.rb` kannst du folgende Einstellungen ändern:

```ruby
LIGHT_OPACITY_MIN = 80        # Minimale Helligkeit
LIGHT_OPACITY_MAX = 160       # Maximale Helligkeit
ANIMATION_SPEED = 2           # Geschwindigkeit der Animation
LIGHT_COLOR = Color.new(255, 255, 150, 120)  # Lichtfarbe (R,G,B,A)

LIGHTS_ON_HOUR = 19    # Lichter an um 19:00 Uhr
LIGHTS_OFF_HOUR = 6    # Lichter aus um 06:00 Uhr
```

## Beispiel-Events

Erstelle Events mit diesen Namen:
- "Haus Licht 1"
- "Fenster Wohnzimmer"
- "Light Kitchen"
- "Window Bedroom"

## Tipps

- Platziere Events leicht versetzt zu den tatsächlichen Fenstern für besseren Effekt
- Verwende mehrere Events pro Haus für realistischere Beleuchtung
- Die Lichter erscheinen automatisch nur nachts oder bei schlechtem Wetter
- Die Animation ist subtil - die Lichter pulsieren sanft 