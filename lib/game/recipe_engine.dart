import '../models/recipe.dart';

class RecipeMatchResult {
  final Recipe? recipe;
  final bool matched;

  RecipeMatchResult.none()
      : recipe = null,
        matched = false;
  RecipeMatchResult.found(this.recipe) : matched = true;
}

/// Motor gastronómico: dado un conjunto de ingredientes colocados en la
/// estación de cocina, determina si forman una receta válida (visible o
/// secreta). Las recetas están definidas por datos en RecipesData.
class RecipeEngine {
  final List<Recipe> allRecipes;

  RecipeEngine(this.allRecipes);

  /// [selectedIngredientIds] es el multiset de ingredientes que el jugador
  /// colocó en la estación de cocina (puede repetir ids).
  RecipeMatchResult findMatch(List<String> selectedIngredientIds) {
    final selectedSorted = [...selectedIngredientIds]..sort();
    for (final recipe in allRecipes) {
      final requiredSorted = [...recipe.ingredientIds]..sort();
      if (_listsEqual(selectedSorted, requiredSorted)) {
        return RecipeMatchResult.found(recipe);
      }
    }
    return RecipeMatchResult.none();
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<Recipe> visibleInBook(Set<String> discoveredRecipeIds) => allRecipes
      .where((r) => !r.isSecret || discoveredRecipeIds.contains(r.id))
      .toList();

  Recipe? byId(String id) {
    for (final r in allRecipes) {
      if (r.id == id) return r;
    }
    return null;
  }
}
