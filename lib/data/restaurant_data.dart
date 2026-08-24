import '../models/restaurant.dart';

class RestaurantData {
  static Restaurant buildInitial() => Restaurant(
        id: 'restaurant_1',
        name: 'Café Central',
        elements: [
          RestaurantElement(id: 'fachada', name: 'Fachada', cost: 200),
          RestaurantElement(id: 'puerta', name: 'Puerta', cost: 150),
          RestaurantElement(id: 'ventanas', name: 'Ventanas', cost: 180),
          RestaurantElement(id: 'cocina', name: 'Cocina', cost: 300),
          RestaurantElement(id: 'horno', name: 'Horno', cost: 350),
          RestaurantElement(id: 'mesas', name: 'Mesas', cost: 220),
          RestaurantElement(id: 'sillas', name: 'Sillas', cost: 160),
          RestaurantElement(id: 'barra', name: 'Barra', cost: 280),
          RestaurantElement(id: 'iluminacion', name: 'Iluminación', cost: 190),
          RestaurantElement(id: 'terraza', name: 'Terraza', cost: 400),
        ],
      );
}
