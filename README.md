# Culinary Fusion — Merge · Cook · Discover

Primera versión funcional, jugable de principio a fin, siguiendo el
"Prompt Maestro" que definiste: sin energía, sin vidas, sin esperas
obligatorias, sin gemas premium. Todo se desbloquea jugando.

## Cómo ejecutarlo

Este entorno no tiene el SDK de Flutter instalado, así que el proyecto
no se pudo compilar aquí — pero está listo para correr en tu máquina:

```bash
flutter pub get
flutter run
```

Requiere Flutter 3.19+ (usa `onWillAcceptWithDetails`/`onAcceptWithDetails`
de `DragTarget`, disponibles desde esa versión) y Dart SDK >=3.3.0.

## Qué incluye esta primera versión

- **1 restaurante** (Café Central) con 10 elementos restaurables
- **9 generadores** (Huerto, Molino, Lechería, Jardín de Hierbas, Carnicería, Gallinero, Muelle de Pesca, Huerto Frutal, Tostadero de Café) — producción inmediata, sin temporizadores
- **9 árboles gastronómicos** (trigo, tomate, queso, hierbas, carne, pollo, pescado, fruta, café) con ~50 ingredientes
- **23 recetas** (17 visibles desde el inicio + 6 secretas, incluyendo 3 legendarias)
- **Pedidos de clientes** con 8 tipos de cliente
- **5 misiones** y **6 logros**
- **10 elementos de decoración**
- Sistema de **monedas y XP**, sin moneda premium
- **Modo Free Cook** (laboratorio sin pedidos ni presión)
- **Árbol Gastronómico visual** (ingredientes no descubiertos aparecen como `❓`)
- **Libro de recetas** (las secretas no se muestran hasta descubrirlas)
- **Guardado local automático y offline** (`shared_preferences`), tolerante a datos corruptos
- Animación básica de fusión (drag & drop + resaltado); hooks de audio listos en `AudioService` para conectar sonidos reales

## Arquitectura

```
lib/
  models/     Player, Ingredient, MergeItem, Generator, Recipe, Order,
              Customer, Restaurant, DecorationItem, Mission, Achievement,
              Discovery, GameState (el ChangeNotifier central)
  game/       MergeEngine, RecipeEngine, DiscoveryEngine
  data/       Definición de ingredientes, recetas, generadores, clientes,
              restaurante, decoraciones y misiones (todo por datos)
  services/   StorageService (persistencia), AudioService (hooks de sonido)
  screens/    Cocina, Recetas, Restaurante, Árbol Gastronómico, Misiones,
              Free Cook
  widgets/    MergeBoard, MergeTile
```

## Próximos pasos sugeridos

1. Reemplazar los emojis por sprites/arte propio en `Ingredient.emoji` y equivalentes.
2. Conectar sonidos reales en `AudioService` (los métodos ya están listos).
3. Añadir animación de "acercarse → destello → transformación → rebote → partículas" en la fusión (hoy hay resaltado + drag, falta la secuencia completa de partículas).
4. ~~Ampliar árboles adicionales (pollo, pescado, frutas, café, etc.)~~ ✅ Hecho: 4 árboles nuevos (Pollo, Pescado, Fruta, Café) con sus generadores y 8 recetas nuevas que los usan.
5. Añadir un tutorial interactivo para los primeros 5 minutos (sección 51-52 de tu prompt).
6. Considerar nuevos clientes/pedidos (`customers_data.dart`) que pidan específicamente platos de los árboles nuevos, para darles más presencia en el ciclo de pedidos.
7. Añadir logros/misiones que celebren el descubrimiento de los árboles nuevos (por ejemplo, "descubre tu primer Pollo Gourmet").
