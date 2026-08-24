/// Instancia concreta de un [Ingredient] colocada en una celda del tablero.
class MergeItem {
  final String uid; // identificador único de esta instancia
  final String ingredientId; // referencia a Ingredient.id

  MergeItem({required this.uid, required this.ingredientId});

  Map<String, dynamic> toJson() => {'uid': uid, 'ingredientId': ingredientId};

  factory MergeItem.fromJson(Map<String, dynamic> json) => MergeItem(
        uid: json['uid'] as String,
        ingredientId: json['ingredientId'] as String,
      );
}
