class Customer {
  final String id;
  final String name;
  final String emoji;
  final String type; // estudiante, turista, familia, empresario, artista...
  final String? favoriteTag; // p.ej. "picante", "dulce" - da bonificación si coincide
  final String greeting;

  const Customer({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    this.favoriteTag,
    this.greeting = '¡Hola! Tengo hambre.',
  });
}
