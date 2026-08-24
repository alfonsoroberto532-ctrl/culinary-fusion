import 'enums.dart';

/// Plantilla estática de un ingrediente/objeto dentro de un árbol gastronómico.
/// No es una instancia en el tablero (eso es [MergeItem]), sino la definición
/// de "qué es" ese objeto: nombre, nivel, en qué árbol vive y en qué se convierte.
class Ingredient {
  final String id;
  final String name;
  final String emoji; // Marcador visual temporal (sustituible por assets/sprites)
  final TreeId treeId;
  final int level; // Nivel dentro de la cadena de fusión (1 = base)
  final Rarity rarity;
  final String? nextId; // Resultado al fusionar dos de este mismo id
  final bool isBaseGenerated; // Si un generador puede producirlo directamente

  const Ingredient({
    required this.id,
    required this.name,
    required this.emoji,
    required this.treeId,
    required this.level,
    required this.rarity,
    this.nextId,
    this.isBaseGenerated = false,
  });

  bool get canMergeFurther => nextId != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'treeId': treeId.name,
        'level': level,
        'rarity': rarity.name,
        'nextId': nextId,
        'isBaseGenerated': isBaseGenerated,
      };
}
