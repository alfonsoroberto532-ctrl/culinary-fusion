import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../models/decoration_item.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';

/// Convención de rutas de assets ilustrados: un PNG por elemento, nombrado
/// exactamente con su `id`, dentro de la carpeta de su categoría. No hace
/// falta declarar nada por ingrediente/receta/cliente: basta con soltar el
/// archivo con el nombre correcto y GameVisual lo recoge solo.
///
/// Ejemplos:
///   assets/images/ingredients/wh1.png   (Trigo)
///   assets/images/recipes/r_pizza_clasica.png
///   assets/images/customers/c_turista.png
///   assets/images/decorations/d_mesa_madera.png
extension IngredientVisualAsset on Ingredient {
  String get imagePath => 'assets/images/ingredients/$id.png';
}

extension RecipeVisualAsset on Recipe {
  String get imagePath => 'assets/images/recipes/$id.png';
}

extension CustomerVisualAsset on Customer {
  String get imagePath => 'assets/images/customers/$id.png';
}

extension DecorationVisualAsset on DecorationItem {
  String get imagePath => 'assets/images/decorations/$id.png';
}

/// Muestra la ilustración en [assetPath] si el archivo existe; si todavía
/// no fue generado/agregado, cae de vuelta al [emoji] sin romper nada.
/// Así se puede ir agregando arte poco a poco sin dejar la app rota.
class GameVisual extends StatelessWidget {
  final String assetPath;
  final String emoji;
  final double size;

  const GameVisual({
    super.key,
    required this.assetPath,
    required this.emoji,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Text(emoji, style: TextStyle(fontSize: size));
      },
    );
  }
}
