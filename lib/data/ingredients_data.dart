import '../models/enums.dart';
import '../models/ingredient.dart';

/// Todas las cadenas de fusión (árboles gastronómicos) de la versión inicial.
/// Cada árbol es una lista ordenada de nivel 1 (base, producido por un
/// generador) hasta el nivel más alto (ingrediente elaborado listo para
/// usarse en recetas).
class IngredientsData {
  static const List<Ingredient> all = [
    // ÁRBOL DEL TRIGO
    Ingredient(id: 'wh1', name: 'Trigo', emoji: '🌾', treeId: TreeId.trigo, level: 1, rarity: Rarity.comun, nextId: 'wh2', isBaseGenerated: true),
    Ingredient(id: 'wh2', name: 'Harina', emoji: '🥣', treeId: TreeId.trigo, level: 2, rarity: Rarity.comun, nextId: 'wh3'),
    Ingredient(id: 'wh3', name: 'Masa', emoji: '🥟', treeId: TreeId.trigo, level: 3, rarity: Rarity.comun, nextId: 'wh4'),
    Ingredient(id: 'wh4', name: 'Masa Artesanal', emoji: '🫓', treeId: TreeId.trigo, level: 4, rarity: Rarity.raro, nextId: 'wh5'),
    Ingredient(id: 'wh5', name: 'Base de Pizza', emoji: '🍕', treeId: TreeId.trigo, level: 5, rarity: Rarity.raro),

    // ÁRBOL DEL TOMATE
    Ingredient(id: 'to1', name: 'Tomate', emoji: '🍅', treeId: TreeId.tomate, level: 1, rarity: Rarity.comun, nextId: 'to2', isBaseGenerated: true),
    Ingredient(id: 'to2', name: 'Tomate Maduro', emoji: '🍅', treeId: TreeId.tomate, level: 2, rarity: Rarity.comun, nextId: 'to3'),
    Ingredient(id: 'to3', name: 'Tomate Triturado', emoji: '🥫', treeId: TreeId.tomate, level: 3, rarity: Rarity.comun, nextId: 'to4'),
    Ingredient(id: 'to4', name: 'Salsa', emoji: '🍶', treeId: TreeId.tomate, level: 4, rarity: Rarity.raro, nextId: 'to5'),
    Ingredient(id: 'to5', name: 'Salsa Especial', emoji: '🍷', treeId: TreeId.tomate, level: 5, rarity: Rarity.epico, nextId: 'to6'),
    Ingredient(id: 'to6', name: 'Salsa Gourmet', emoji: '✨', treeId: TreeId.tomate, level: 6, rarity: Rarity.mitico),

    // ÁRBOL DEL QUESO
    Ingredient(id: 'ch1', name: 'Leche', emoji: '🥛', treeId: TreeId.queso, level: 1, rarity: Rarity.comun, nextId: 'ch2', isBaseGenerated: true),
    Ingredient(id: 'ch2', name: 'Cuajada', emoji: '🥣', treeId: TreeId.queso, level: 2, rarity: Rarity.comun, nextId: 'ch3'),
    Ingredient(id: 'ch3', name: 'Queso Fresco', emoji: '🧀', treeId: TreeId.queso, level: 3, rarity: Rarity.comun, nextId: 'ch4'),
    Ingredient(id: 'ch4', name: 'Queso', emoji: '🧀', treeId: TreeId.queso, level: 4, rarity: Rarity.raro, nextId: 'ch5'),
    Ingredient(id: 'ch5', name: 'Queso Curado', emoji: '🧈', treeId: TreeId.queso, level: 5, rarity: Rarity.epico, nextId: 'ch6'),
    Ingredient(id: 'ch6', name: 'Queso Artesanal', emoji: '🌟', treeId: TreeId.queso, level: 6, rarity: Rarity.mitico),

    // ÁRBOL DE LAS HIERBAS
    Ingredient(id: 'he1', name: 'Semilla de Hierba', emoji: '🌱', treeId: TreeId.hierbas, level: 1, rarity: Rarity.comun, nextId: 'he2', isBaseGenerated: true),
    Ingredient(id: 'he2', name: 'Brote', emoji: '🌿', treeId: TreeId.hierbas, level: 2, rarity: Rarity.comun, nextId: 'he3'),
    Ingredient(id: 'he3', name: 'Hierba', emoji: '🍃', treeId: TreeId.hierbas, level: 3, rarity: Rarity.comun, nextId: 'he4'),
    Ingredient(id: 'he4', name: 'Hierbas Frescas', emoji: '🌾', treeId: TreeId.hierbas, level: 4, rarity: Rarity.raro, nextId: 'he5'),
    Ingredient(id: 'he5', name: 'Mezcla de Hierbas', emoji: '🧉', treeId: TreeId.hierbas, level: 5, rarity: Rarity.epico, nextId: 'he6'),
    Ingredient(id: 'he6', name: 'Condimento Gourmet', emoji: '✨', treeId: TreeId.hierbas, level: 6, rarity: Rarity.mitico),

    // ÁRBOL DE LA CARNE
    Ingredient(id: 'me1', name: 'Carne Cruda', emoji: '🥩', treeId: TreeId.carne, level: 1, rarity: Rarity.comun, nextId: 'me2', isBaseGenerated: true),
    Ingredient(id: 'me2', name: 'Carne Preparada', emoji: '🥩', treeId: TreeId.carne, level: 2, rarity: Rarity.comun, nextId: 'me3'),
    Ingredient(id: 'me3', name: 'Carne Condimentada', emoji: '🍖', treeId: TreeId.carne, level: 3, rarity: Rarity.comun, nextId: 'me4'),
    Ingredient(id: 'me4', name: 'Carne Marinada', emoji: '🍖', treeId: TreeId.carne, level: 4, rarity: Rarity.raro, nextId: 'me5'),
    Ingredient(id: 'me5', name: 'Carne Cocinada', emoji: '🍗', treeId: TreeId.carne, level: 5, rarity: Rarity.epico, nextId: 'me6'),
    Ingredient(id: 'me6', name: 'Carne Gourmet', emoji: '👑', treeId: TreeId.carne, level: 6, rarity: Rarity.legendario),

    // ÁRBOL DEL POLLO
    Ingredient(id: 'po1', name: 'Pollo Crudo', emoji: '🐔', treeId: TreeId.pollo, level: 1, rarity: Rarity.comun, nextId: 'po2', isBaseGenerated: true),
    Ingredient(id: 'po2', name: 'Pollo Limpio', emoji: '🍗', treeId: TreeId.pollo, level: 2, rarity: Rarity.comun, nextId: 'po3'),
    Ingredient(id: 'po3', name: 'Pollo Marinado', emoji: '🍗', treeId: TreeId.pollo, level: 3, rarity: Rarity.comun, nextId: 'po4'),
    Ingredient(id: 'po4', name: 'Pollo Condimentado', emoji: '🍖', treeId: TreeId.pollo, level: 4, rarity: Rarity.raro, nextId: 'po5'),
    Ingredient(id: 'po5', name: 'Pollo Asado', emoji: '🍖', treeId: TreeId.pollo, level: 5, rarity: Rarity.epico, nextId: 'po6'),
    Ingredient(id: 'po6', name: 'Pollo Gourmet', emoji: '👑', treeId: TreeId.pollo, level: 6, rarity: Rarity.legendario),

    // ÁRBOL DEL PESCADO
    Ingredient(id: 'fi1', name: 'Pescado Fresco', emoji: '🐟', treeId: TreeId.pescado, level: 1, rarity: Rarity.comun, nextId: 'fi2', isBaseGenerated: true),
    Ingredient(id: 'fi2', name: 'Pescado Limpio', emoji: '🐟', treeId: TreeId.pescado, level: 2, rarity: Rarity.comun, nextId: 'fi3'),
    Ingredient(id: 'fi3', name: 'Filete de Pescado', emoji: '🍥', treeId: TreeId.pescado, level: 3, rarity: Rarity.comun, nextId: 'fi4'),
    Ingredient(id: 'fi4', name: 'Pescado Marinado', emoji: '🍣', treeId: TreeId.pescado, level: 4, rarity: Rarity.raro, nextId: 'fi5'),
    Ingredient(id: 'fi5', name: 'Pescado a la Parrilla', emoji: '🐠', treeId: TreeId.pescado, level: 5, rarity: Rarity.epico, nextId: 'fi6'),
    Ingredient(id: 'fi6', name: 'Pescado Gourmet', emoji: '✨', treeId: TreeId.pescado, level: 6, rarity: Rarity.mitico),

    // ÁRBOL DE LA FRUTA
    Ingredient(id: 'fr1', name: 'Fruta Fresca', emoji: '🍎', treeId: TreeId.fruta, level: 1, rarity: Rarity.comun, nextId: 'fr2', isBaseGenerated: true),
    Ingredient(id: 'fr2', name: 'Fruta Madura', emoji: '🍊', treeId: TreeId.fruta, level: 2, rarity: Rarity.comun, nextId: 'fr3'),
    Ingredient(id: 'fr3', name: 'Puré de Fruta', emoji: '🥣', treeId: TreeId.fruta, level: 3, rarity: Rarity.comun, nextId: 'fr4'),
    Ingredient(id: 'fr4', name: 'Mermelada', emoji: '🍇', treeId: TreeId.fruta, level: 4, rarity: Rarity.raro, nextId: 'fr5'),
    Ingredient(id: 'fr5', name: 'Postre de Frutas', emoji: '🍰', treeId: TreeId.fruta, level: 5, rarity: Rarity.epico),

    // ÁRBOL DEL CAFÉ
    Ingredient(id: 'co1', name: 'Grano de Café', emoji: '🌰', treeId: TreeId.cafe, level: 1, rarity: Rarity.comun, nextId: 'co2', isBaseGenerated: true),
    Ingredient(id: 'co2', name: 'Café Tostado', emoji: '🟤', treeId: TreeId.cafe, level: 2, rarity: Rarity.comun, nextId: 'co3'),
    Ingredient(id: 'co3', name: 'Café Molido', emoji: '☕', treeId: TreeId.cafe, level: 3, rarity: Rarity.comun, nextId: 'co4'),
    Ingredient(id: 'co4', name: 'Café Espresso', emoji: '☕', treeId: TreeId.cafe, level: 4, rarity: Rarity.raro, nextId: 'co5'),
    Ingredient(id: 'co5', name: 'Café Gourmet', emoji: '✨', treeId: TreeId.cafe, level: 5, rarity: Rarity.epico),
  ];

  static final Map<String, Ingredient> byId = {
    for (final i in all) i.id: i,
  };

  static List<Ingredient> byTree(TreeId tree) =>
      all.where((i) => i.treeId == tree).toList()..sort((a, b) => a.level.compareTo(b.level));

  static List<Ingredient> get baseGenerated =>
      all.where((i) => i.isBaseGenerated).toList();
}
