import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/customers_data.dart';
import '../data/decorations_data.dart';
import '../data/generators_data.dart';
import '../data/ingredients_data.dart';
import '../data/missions_data.dart';
import '../data/recipes_data.dart';
import '../data/restaurant_data.dart';
import '../game/discovery_engine.dart';
import '../game/merge_engine.dart';
import '../game/recipe_engine.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'achievement.dart';
import 'decoration_item.dart';
import 'discovery.dart';
import 'enums.dart';
import 'generator.dart';
import 'merge_item.dart';
import 'mission.dart';
import 'order.dart';
import 'player.dart';
import 'recipe.dart';
import 'restaurant.dart';

/// El "cerebro" del juego. Mantiene todo el estado y notifica a la UI
/// cuando algo cambia (patrón ChangeNotifier + Provider). Delega la lógica
/// pesada en los motores (MergeEngine, RecipeEngine, DiscoveryEngine) para
/// no mezclar reglas de juego con la interfaz.
class GameState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final AudioService audio = AudioService();
  final MergeEngine mergeEngine = MergeEngine();
  late final RecipeEngine recipeEngine;
  late final DiscoveryEngine discoveryEngine;
  final _uuid = const Uuid();

  Player player = Player();
  List<MergeItem?> board = List<MergeItem?>.filled(kBoardSize, null);
  List<Generator> generators = GeneratorsData.buildInitial();
  List<Recipe> recipes = RecipesData.buildInitial();
  Discovery discovery = Discovery();
  List<Mission> missions = MissionsData.buildInitial();
  List<Achievement> achievements = _buildAchievements();
  Restaurant restaurant = RestaurantData.buildInitial();
  List<DecorationItem> decorations = DecorationsData.buildInitial();
  List<Order> activeOrders = [];

  bool freeCookMode = false;

  // Estación de cocina: uids de items del tablero que el jugador colocó
  // para intentar preparar un plato.
  List<String> cookingSelection = [];

  // Últimos eventos para que la UI muestre popups (descubrimiento, etc.)
  String? lastPopupTitle;
  String? lastPopupSubtitle;

  // Última fusión exitosa, para que el tablero dispare la animación de
  // partículas/destello en esa celda exacta. Se limpia desde la UI una vez
  // reproducida (ver MergeBoard/MergeTile).
  int? lastMergeCellIndex;
  Rarity? lastMergeRarity;

  static List<Achievement> _buildAchievements() => [
        Achievement(
            id: 'a_primer_plato',
            name: 'Primer Plato',
            description: 'Prepara tu primera receta',
            emoji: '🍽️'),
        Achievement(
            id: 'a_maestro_pizza',
            name: 'Maestro de la Pizza',
            description: 'Prepara 10 pizzas',
            emoji: '🍕'),
        Achievement(
            id: 'a_chef_experimental',
            name: 'Chef Experimental',
            description: 'Descubre una receta secreta',
            emoji: '🧪'),
        Achievement(
            id: 'a_coleccionista',
            name: 'Coleccionista Gastronómico',
            description: 'Descubre 15 ingredientes',
            emoji: '📖'),
        Achievement(
            id: 'a_restaurante_famoso',
            name: 'Restaurante Famoso',
            description: 'Restaura todo el restaurante',
            emoji: '🏆'),
        Achievement(
            id: 'a_maestro_culinario',
            name: 'Maestro Culinario',
            description: 'Descubre todas las recetas secretas',
            emoji: '👨‍🍳'),
      ];

  Future<void> init() async {
    recipeEngine = RecipeEngine(recipes);
    discoveryEngine = DiscoveryEngine(discovery);
    await _load();
    if (activeOrders.isEmpty) {
      _generateOrder();
      _generateOrder();
    }
    isReady = true;
    notifyListeners();
  }

  bool isReady = false;

  // ---------------------------------------------------------------------
  // TABLERO / MERGE
  // ---------------------------------------------------------------------

  bool isCellEmpty(int index) => board[index] == null;

  /// Un generador coloca un ingrediente base en una celda vacía.
  bool generateInto(String generatorId, int cellIndex) {
    if (!isCellEmpty(cellIndex)) return false;
    final generator = generators.firstWhere((g) => g.id == generatorId);
    final options = generator.availableIngredientIds;
    if (options.isEmpty) return false;
    final ingredientId = options[DateTime.now().microsecond % options.length];
    board[cellIndex] = mergeEngine.spawn(ingredientId);
    _registerIngredientDiscovery(ingredientId);
    _save();
    notifyListeners();
    return true;
  }

  /// Intenta mover/fusionar el item de [from] hacia [to].
  void moveOrMerge(int from, int to) {
    final source = board[from];
    if (source == null) return;
    final target = board[to];

    if (target == null) {
      board[to] = source;
      board[from] = null;
      _save();
      notifyListeners();
      return;
    }

    if (mergeEngine.canMerge(source, target)) {
      final result = mergeEngine.merge(source, target,
          alreadyDiscovered: discovery.discoveredIngredientIds);
      if (result.success) {
        board[to] = result.resultItem;
        board[from] = null;
        audio.playMerge();
        lastMergeCellIndex = to;
        lastMergeRarity = result.resultIngredient?.rarity;
        _incrementMissionProgress(MissionType.mergeCount, amount: 1);
        if (result.isNewDiscovery) {
          _registerIngredientDiscovery(result.resultIngredient!.id,
              showPopup: true);
        }
        _save();
        notifyListeners();
      }
      return;
    }
    // No son compatibles: simplemente no hace nada (sin castigo).
  }

  /// Llamado por la UI una vez reproducida la animación de fusión en la
  /// celda [lastMergeCellIndex], para no repetirla en el siguiente rebuild.
  void clearMergeEvent() {
    lastMergeCellIndex = null;
    lastMergeRarity = null;
  }

  void sellItem(int index) {
    final item = board[index];
    if (item == null) return;
    final ingredient = IngredientsData.byId[item.ingredientId]!;
    final value = 5 * ingredient.level;
    player.addCoins(value);
    board[index] = null;
    audio.playCoins();
    _incrementMissionProgress(MissionType.earnCoins, amount: value);
    _save();
    notifyListeners();
  }

  void _registerIngredientDiscovery(String ingredientId,
      {bool showPopup = false}) {
    final isNew = discoveryEngine.discoverIngredient(ingredientId);
    if (isNew) {
      final ingredient = IngredientsData.byId[ingredientId]!;
      discoveryEngine.discoverTree(ingredient.treeId.name);
      _incrementMissionProgress(MissionType.discoverIngredients, amount: 1);
      if (showPopup) {
        audio.playDiscovery();
        _showPopup('¡Nuevo ingrediente!', ingredient.name);
      }
    }
  }

  // ---------------------------------------------------------------------
  // GENERADORES
  // ---------------------------------------------------------------------

  bool upgradeGenerator(String generatorId) {
    final generator = generators.firstWhere((g) => g.id == generatorId);
    final cost = generator.nextUpgradeCost;
    if (cost == null) return false;
    if (!player.spendCoins(cost)) return false;
    generator.level++;
    _save();
    notifyListeners();
    return true;
  }

  // ---------------------------------------------------------------------
  // ESTACIÓN DE COCINA / RECETAS
  // ---------------------------------------------------------------------

  void addToCookingSelection(int cellIndex) {
    final item = board[cellIndex];
    if (item == null) return;
    cookingSelection.add(item.uid);
    notifyListeners();
  }

  void removeFromCookingSelection(String uid) {
    cookingSelection.remove(uid);
    notifyListeners();
  }

  void clearCookingSelection() {
    cookingSelection.clear();
    notifyListeners();
  }

  /// Intenta cocinar con los items actualmente seleccionados (por uid).
  /// Si coincide con una receta: consume los ingredientes del tablero,
  /// otorga XP/monedas, registra el descubrimiento si es nuevo.
  Recipe? tryCook() {
    final selectedIds = <String>[];
    final cellsUsed = <int>[];
    for (var i = 0; i < board.length; i++) {
      final item = board[i];
      if (item != null && cookingSelection.contains(item.uid)) {
        selectedIds.add(item.ingredientId);
        cellsUsed.add(i);
      }
    }
    if (selectedIds.isEmpty) return null;

    final match = recipeEngine.findMatch(selectedIds);
    if (!match.matched) return null;

    final recipe = match.recipe!;
    for (final cell in cellsUsed) {
      board[cell] = null;
    }
    cookingSelection.clear();

    recipe.registerPreparation();
    player.addXp(recipe.xpReward);
    player.addCoins(recipe.coinReward);
    _incrementMissionProgress(MissionType.earnCoins, amount: recipe.coinReward);

    final isNewRecipe = discoveryEngine.discoverRecipe(recipe.id);
    if (isNewRecipe) {
      audio.playDiscovery();
      _showPopup(
          '¡Receta descubierta!', '${recipe.name} · +${recipe.xpReward} XP');
      if (recipe.isSecret) {
        _unlockAchievement('a_chef_experimental');
      }
    }
    if (recipe.id == 'r_pizza_clasica' || recipe.timesPrepared == 1) {
      _unlockAchievement('a_primer_plato');
    }
    _incrementMissionProgress(MissionType.discoverRecipes,
        amount: isNewRecipe ? 1 : 0);
    _incrementMissionProgress(MissionType.prepareRecipe,
        targetId: recipe.id, amount: 1);

    _checkOrdersForRecipe(recipe.id);
    _save();
    notifyListeners();
    return recipe;
  }

  void _checkOrdersForRecipe(String recipeId) {
    // Marca disponibilidad de entrega si el jugador ya tiene el plato hecho.
    // (La entrega real se confirma con deliverOrder desde la UI cuando el
    // jugador tiene el plato correspondiente ya preparado en inventario lógico.)
  }

  // ---------------------------------------------------------------------
  // PEDIDOS / CLIENTES
  // ---------------------------------------------------------------------

  void _generateOrder() {
    if (activeOrders.length >= 3) return;
    final visibleRecipes =
        recipeEngine.visibleInBook(discovery.discoveredRecipeIds);
    final pool = visibleRecipes.where((r) => !r.isLegendary).toList();
    if (pool.isEmpty) return;
    final recipe = pool[DateTime.now().millisecond % pool.length];
    final customer =
        CustomersData.all[DateTime.now().second % CustomersData.all.length];
    activeOrders.add(Order(
      id: _uuid.v4(),
      customerId: customer.id,
      recipeIds: [recipe.id],
      rewardCoins: recipe.coinReward,
      rewardXp: recipe.xpReward,
    ));
  }

  /// Entrega un pedido siempre que el jugador confirme tener el plato listo.
  /// En esta versión inicial, entregar un pedido simplemente exige haber
  /// preparado esa receta al menos una vez (modelo simplificado y sin
  /// bloqueos artificiales; una versión futura puede exigir stock exacto).
  bool deliverOrder(String orderId) {
    final order = activeOrders.firstWhere((o) => o.id == orderId,
        orElse: () => Order(
            id: '',
            customerId: '',
            recipeIds: [],
            rewardCoins: 0,
            rewardXp: 0));
    if (order.id.isEmpty || order.delivered) return false;
    final recipe = recipeEngine.byId(order.recipeIds.first);
    if (recipe == null || recipe.timesPrepared <= 0) return false;

    order.delivered = true;
    player.addCoins(order.rewardCoins);
    player.addXp(order.rewardXp);
    audio.playOrderDelivered();
    activeOrders.removeWhere((o) => o.id == orderId);
    _incrementMissionProgress(MissionType.deliverOrders, amount: 1);
    _incrementMissionProgress(MissionType.earnCoins, amount: order.rewardCoins);
    _generateOrder();
    _save();
    notifyListeners();
    return true;
  }

  void skipOrder(String orderId) {
    activeOrders.removeWhere((o) => o.id == orderId);
    _generateOrder();
    _save();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // RESTAURANTE / DECORACIÓN
  // ---------------------------------------------------------------------

  bool restoreElement(String elementId) {
    final element = restaurant.elements.firstWhere((e) => e.id == elementId);
    if (element.restored) return false;
    if (!player.spendCoins(element.cost)) return false;
    element.restored = true;
    player.addXp(100);
    audio.playRestoration();
    _incrementMissionProgress(MissionType.restoreElements, amount: 1);
    if (restaurant.restoredCount == restaurant.elements.length) {
      _unlockAchievement('a_restaurante_famoso');
    }
    _save();
    notifyListeners();
    return true;
  }

  bool unlockDecoration(String id) {
    final deco = decorations.firstWhere((d) => d.id == id);
    if (deco.unlocked) return false;
    if (!player.spendCoins(deco.cost)) return false;
    deco.unlocked = true;
    _incrementMissionProgress(MissionType.unlockDecorations, amount: 1);
    _save();
    notifyListeners();
    return true;
  }

  void togglePlaceDecoration(String id) {
    final deco = decorations.firstWhere((d) => d.id == id);
    if (!deco.unlocked) return;
    deco.placed = !deco.placed;
    _save();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // MISIONES / LOGROS
  // ---------------------------------------------------------------------

  void _incrementMissionProgress(MissionType type,
      {String? targetId, int amount = 1}) {
    if (amount <= 0) return;
    for (final mission in missions) {
      if (mission.type != type || mission.claimed) continue;
      if (mission.targetId != null && mission.targetId != targetId) continue;
      mission.progress =
          (mission.progress + amount).clamp(0, mission.targetCount);
    }
  }

  bool claimMission(String missionId) {
    final mission = missions.firstWhere((m) => m.id == missionId);
    if (!mission.isComplete || mission.claimed) return false;
    mission.claimed = true;
    player.addCoins(mission.rewardCoins);
    player.addXp(mission.rewardXp);
    _save();
    notifyListeners();
    return true;
  }

  void _unlockAchievement(String id) {
    final achievement = achievements.firstWhere((a) => a.id == id);
    if (!achievement.unlocked) {
      achievement.unlocked = true;
      _showPopup('¡Logro desbloqueado!', achievement.name);
    }
  }

  // ---------------------------------------------------------------------
  // FREE COOK MODE
  // ---------------------------------------------------------------------

  void toggleFreeCook() {
    freeCookMode = !freeCookMode;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // POPUPS
  // ---------------------------------------------------------------------

  void _showPopup(String title, String subtitle) {
    lastPopupTitle = title;
    lastPopupSubtitle = subtitle;
  }

  void clearPopup() {
    lastPopupTitle = null;
    lastPopupSubtitle = null;
  }

  // ---------------------------------------------------------------------
  // GUARDADO
  // ---------------------------------------------------------------------

  Future<void> _save() async {
    final data = {
      'player': player.toJson(),
      'board': board.map((i) => i?.toJson()).toList(),
      'generators': generators.map((g) => g.toJson()).toList(),
      'recipes': recipes.map((r) => r.toJson()).toList(),
      'discovery': discovery.toJson(),
      'missions': missions.map((m) => m.toJson()).toList(),
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'restaurant': restaurant.elements.map((e) => e.toJson()).toList(),
      'decorations': decorations.map((d) => d.toJson()).toList(),
      'orders': activeOrders.map((o) => o.toJson()).toList(),
    };
    await _storage.save(data);
  }

  Future<void> _load() async {
    final data = await _storage.load();
    if (data == null) return;

    try {
      player = Player.fromJson(data['player'] as Map<String, dynamic>);

      final boardJson = data['board'] as List?;
      if (boardJson != null) {
        board = boardJson
            .map((e) => e == null
                ? null
                : MergeItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      final generatorsJson = data['generators'] as List?;
      if (generatorsJson != null) {
        for (final gj in generatorsJson) {
          final map = gj as Map<String, dynamic>;
          final match = generators.where((g) => g.id == map['id']);
          if (match.isNotEmpty) match.first.applySave(map);
        }
      }

      final recipesJson = data['recipes'] as List?;
      if (recipesJson != null) {
        for (final rj in recipesJson) {
          final map = rj as Map<String, dynamic>;
          final match = recipes.where((r) => r.id == map['id']);
          if (match.isNotEmpty) match.first.applySave(map);
        }
      }

      if (data['discovery'] != null) {
        discovery =
            Discovery.fromJson(data['discovery'] as Map<String, dynamic>);
        discoveryEngine = DiscoveryEngine(discovery);
      }

      final missionsJson = data['missions'] as List?;
      if (missionsJson != null) {
        for (final mj in missionsJson) {
          final map = mj as Map<String, dynamic>;
          final match = missions.where((m) => m.id == map['id']);
          if (match.isNotEmpty) match.first.applySave(map);
        }
      }

      final achievementsJson = data['achievements'] as List?;
      if (achievementsJson != null) {
        for (final aj in achievementsJson) {
          final map = aj as Map<String, dynamic>;
          final match = achievements.where((a) => a.id == map['id']);
          if (match.isNotEmpty) match.first.applySave(map);
        }
      }

      final restaurantJson = data['restaurant'] as List?;
      if (restaurantJson != null) {
        for (final ej in restaurantJson) {
          final map = ej as Map<String, dynamic>;
          final match = restaurant.elements.where((e) => e.id == map['id']);
          if (match.isNotEmpty) match.first.applySave(map);
        }
      }

      final decorationsJson = data['decorations'] as List?;
      if (decorationsJson != null) {
        for (final dj in decorationsJson) {
          final map = dj as Map<String, dynamic>;
          final match = decorations.where((d) => d.id == map['id']);
          if (match.isNotEmpty) match.first.applySave(map);
        }
      }

      final ordersJson = data['orders'] as List?;
      if (ordersJson != null) {
        activeOrders = ordersJson
            .map((o) => Order.fromJson(o as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Guardado corrupto: continuar con una partida nueva en lugar de
      // romper el arranque de la aplicación.
    }
  }

  Future<void> hardReset() async {
    await _storage.clear();
    player = Player();
    board = List<MergeItem?>.filled(kBoardSize, null);
    generators = GeneratorsData.buildInitial();
    recipes = RecipesData.buildInitial();
    discovery = Discovery();
    discoveryEngine = DiscoveryEngine(discovery);
    missions = MissionsData.buildInitial();
    achievements = _buildAchievements();
    restaurant = RestaurantData.buildInitial();
    decorations = DecorationsData.buildInitial();
    activeOrders = [];
    _generateOrder();
    _generateOrder();
    notifyListeners();
  }
}
