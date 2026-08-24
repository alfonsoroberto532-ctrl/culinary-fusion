/// Registro permanente de descubrimientos. Una vez algo se descubre,
/// queda registrado para siempre (nunca se "olvida" ni se re-bloquea).
class Discovery {
  final Set<String> discoveredIngredientIds;
  final Set<String> discoveredRecipeIds;
  final Set<String> discoveredTreeIds;

  Discovery({
    Set<String>? discoveredIngredientIds,
    Set<String>? discoveredRecipeIds,
    Set<String>? discoveredTreeIds,
  })  : discoveredIngredientIds = discoveredIngredientIds ?? <String>{},
        discoveredRecipeIds = discoveredRecipeIds ?? <String>{},
        discoveredTreeIds = discoveredTreeIds ?? <String>{};

  bool hasIngredient(String id) => discoveredIngredientIds.contains(id);
  bool hasRecipe(String id) => discoveredRecipeIds.contains(id);

  /// Devuelve true si es la PRIMERA vez que se descubre (para disparar el popup).
  bool registerIngredient(String id) => discoveredIngredientIds.add(id);
  bool registerRecipe(String id) => discoveredRecipeIds.add(id);
  bool registerTree(String id) => discoveredTreeIds.add(id);

  Map<String, dynamic> toJson() => {
        'ingredients': discoveredIngredientIds.toList(),
        'recipes': discoveredRecipeIds.toList(),
        'trees': discoveredTreeIds.toList(),
      };

  factory Discovery.fromJson(Map<String, dynamic> json) => Discovery(
        discoveredIngredientIds:
            Set<String>.from(json['ingredients'] as List? ?? const []),
        discoveredRecipeIds:
            Set<String>.from(json['recipes'] as List? ?? const []),
        discoveredTreeIds: Set<String>.from(json['trees'] as List? ?? const []),
      );
}
