import '../models/discovery.dart';

/// Envoltorio fino sobre [Discovery] que centraliza el registro de
/// descubrimientos. Una vez algo se registra, queda permanentemente
/// desbloqueado (nunca se revierte).
class DiscoveryEngine {
  final Discovery discovery;

  DiscoveryEngine(this.discovery);

  /// Devuelve true si es la primera vez que se ve este ingrediente.
  bool discoverIngredient(String id) => discovery.registerIngredient(id);

  /// Devuelve true si es la primera vez que se prepara esta receta.
  bool discoverRecipe(String id) => discovery.registerRecipe(id);

  bool discoverTree(String treeId) => discovery.registerTree(treeId);

  int get totalDiscoveredIngredients => discovery.discoveredIngredientIds.length;
  int get totalDiscoveredRecipes => discovery.discoveredRecipeIds.length;
}
