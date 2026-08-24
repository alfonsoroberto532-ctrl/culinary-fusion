import '../models/decoration_item.dart';

class DecorationsData {
  static List<DecorationItem> buildInitial() => [
        DecorationItem(id: 'd_mesa_madera', name: 'Mesa de Madera', emoji: '🪵', category: 'Mesas', cost: 80),
        DecorationItem(id: 'd_silla_vintage', name: 'Silla Vintage', emoji: '🪑', category: 'Sillas', cost: 60),
        DecorationItem(id: 'd_lampara_calida', name: 'Lámpara Cálida', emoji: '💡', category: 'Lámparas', cost: 70),
        DecorationItem(id: 'd_planta_maceta', name: 'Planta en Maceta', emoji: '🪴', category: 'Plantas', cost: 50),
        DecorationItem(id: 'd_cuadro_paisaje', name: 'Cuadro de Paisaje', emoji: '🖼️', category: 'Cuadros', cost: 90),
        DecorationItem(id: 'd_papel_pared', name: 'Papel de Pared Floral', emoji: '🧱', category: 'Paredes', cost: 100),
        DecorationItem(id: 'd_piso_madera', name: 'Piso de Madera Clara', emoji: '🟫', category: 'Pisos', cost: 120),
        DecorationItem(id: 'd_cortinas', name: 'Cortinas de Lino', emoji: '🪟', category: 'Ventanas', cost: 65),
        DecorationItem(id: 'd_estanteria_cocina', name: 'Estantería de Cocina', emoji: '🍽️', category: 'Cocina', cost: 110),
        DecorationItem(id: 'd_cartel_bienvenida', name: 'Cartel de Bienvenida', emoji: '🪧', category: 'Carteles', cost: 55),
      ];
}
