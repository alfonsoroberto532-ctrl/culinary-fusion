import 'package:uuid/uuid.dart';
import '../data/ingredients_data.dart';
import '../models/ingredient.dart';
import '../models/merge_item.dart';

const int kBoardColumns = 7;
const int kBoardRows = 9;
const int kBoardSize = kBoardColumns * kBoardRows;

class MergeResult {
  final bool success;
  final MergeItem? resultItem;
  final Ingredient? resultIngredient;
  final bool isNewDiscovery;

  MergeResult.fail()
      : success = false,
        resultItem = null,
        resultIngredient = null,
        isNewDiscovery = false;

  MergeResult.success(this.resultItem, this.resultIngredient, this.isNewDiscovery)
      : success = true;
}

/// Motor de fusión. Contiene TODA la lógica de compatibilidad y resultados;
/// la interfaz solo le pide "fusiona A con B" y pinta lo que él devuelva.
class MergeEngine {
  final _uuid = const Uuid();

  /// Determina si dos items del tablero pueden fusionarse.
  bool canMerge(MergeItem a, MergeItem b) {
    if (a.uid == b.uid) return false;
    if (a.ingredientId != b.ingredientId) return false;
    final ingredient = IngredientsData.byId[a.ingredientId];
    return ingredient != null && ingredient.canMergeFurther;
  }

  /// Ejecuta la fusión y devuelve el nuevo item. No modifica el tablero;
  /// eso lo hace GameState, que es quien conoce las posiciones.
  MergeResult merge(MergeItem a, MergeItem b, {required Set<String> alreadyDiscovered}) {
    if (!canMerge(a, b)) return MergeResult.fail();
    final current = IngredientsData.byId[a.ingredientId]!;
    final nextIngredient = IngredientsData.byId[current.nextId!];
    if (nextIngredient == null) return MergeResult.fail();

    final newItem = MergeItem(uid: _uuid.v4(), ingredientId: nextIngredient.id);
    final isNew = !alreadyDiscovered.contains(nextIngredient.id);
    return MergeResult.success(newItem, nextIngredient, isNew);
  }

  MergeItem spawn(String ingredientId) =>
      MergeItem(uid: _uuid.v4(), ingredientId: ingredientId);
}
