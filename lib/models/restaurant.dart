class RestaurantElement {
  final String id;
  final String name; // fachada, puerta, ventanas, cocina, mesas...
  final int cost;
  bool restored;

  RestaurantElement({
    required this.id,
    required this.name,
    required this.cost,
    this.restored = false,
  });

  Map<String, dynamic> toJson() => {'id': id, 'restored': restored};

  void applySave(Map<String, dynamic> json) {
    restored = json['restored'] as bool? ?? false;
  }
}

class Restaurant {
  final String id;
  final String name;
  final List<RestaurantElement> elements;

  Restaurant({required this.id, required this.name, required this.elements});

  int get restoredCount => elements.where((e) => e.restored).length;
  double get restorationProgress =>
      elements.isEmpty ? 0 : restoredCount / elements.length;
}
