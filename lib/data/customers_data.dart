import '../models/customer.dart';

class CustomersData {
  static const List<Customer> all = [
    Customer(id: 'c_estudiante', name: 'Mía', emoji: '🎒', type: 'Estudiante', favoriteTag: 'comun', greeting: '¡Tengo poco tiempo entre clases!'),
    Customer(id: 'c_turista', name: 'Hendrik', emoji: '📷', type: 'Turista', favoriteTag: 'raro', greeting: 'Quiero probar algo típico de aquí.'),
    Customer(id: 'c_familia', name: 'Familia Rossi', emoji: '👨‍👩‍👧', type: 'Familia', favoriteTag: 'comun', greeting: 'Algo rico para todos, por favor.'),
    Customer(id: 'c_empresario', name: 'Sra. Kwan', emoji: '💼', type: 'Empresaria', favoriteTag: 'epico', greeting: 'Tengo una reunión en 20 minutos.'),
    Customer(id: 'c_artista', name: 'Rio', emoji: '🎨', type: 'Artista', favoriteTag: 'raro', greeting: 'Sorpréndeme con los colores del plato.'),
    Customer(id: 'c_critico', name: 'Auguste', emoji: '🧐', type: 'Crítico Gastronómico', favoriteTag: 'mitico', greeting: 'Espero que esto valga la reseña.'),
    Customer(id: 'c_chef', name: 'Chef Nadia', emoji: '👩‍🍳', type: 'Chef', favoriteTag: 'legendario', greeting: 'Muéstrame tu mejor técnica.'),
    Customer(id: 'c_aventurero', name: 'Kai', emoji: '🧭', type: 'Aventurero', favoriteTag: 'epico', greeting: '¡Lo más exótico que tengas!'),
    Customer(id: 'c_pescador', name: 'Old Tom', emoji: '🎣', type: 'Pescador', favoriteTag: 'raro', greeting: 'Acabo de volver del muelle, ¡tengo hambre de mar!'),
    Customer(id: 'c_barista', name: 'Noa', emoji: '☕', type: 'Barista', favoriteTag: 'comun', greeting: 'Solo quiero algo rico para acompañar mi café.'),
    Customer(id: 'c_granjero', name: 'Don Pepe', emoji: '🚜', type: 'Granjero', favoriteTag: 'comun', greeting: 'Nada como comer bien después de una mañana de trabajo.'),
    Customer(id: 'c_influencer', name: 'Lulu', emoji: '📱', type: 'Foodie Influencer', favoriteTag: 'epico', greeting: '¡Esto tiene que quedar increíble en la foto!'),
    Customer(id: 'c_viajero_gourmet', name: 'Amara', emoji: '🌍', type: 'Viajera Gourmet', favoriteTag: 'mitico', greeting: 'He probado cocina de medio mundo... impresióname.'),
    Customer(id: 'c_nino', name: 'Tico', emoji: '🧒', type: 'Niño', favoriteTag: 'comun', greeting: '¡Quiero algo divertido y rico!'),
    Customer(id: 'c_abuela', name: 'Doña Carmen', emoji: '👵', type: 'Abuela', favoriteTag: 'raro', greeting: 'Quiero un plato que sepa a hogar.'),
    Customer(id: 'c_deportista', name: 'Bruno', emoji: '🏃', type: 'Deportista', favoriteTag: 'raro', greeting: 'Necesito recargar energías después del entrenamiento.'),
  ];

  static final Map<String, Customer> byId = {for (final c in all) c.id: c};
}
