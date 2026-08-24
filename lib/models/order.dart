class Order {
  final String id;
  final String customerId;
  final List<String> recipeIds; // uno o varios platos pedidos
  final int rewardCoins;
  final int rewardXp;
  bool delivered;

  Order({
    required this.id,
    required this.customerId,
    required this.recipeIds,
    required this.rewardCoins,
    required this.rewardXp,
    this.delivered = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'recipeIds': recipeIds,
        'rewardCoins': rewardCoins,
        'rewardXp': rewardXp,
        'delivered': delivered,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        recipeIds: List<String>.from(json['recipeIds'] as List),
        rewardCoins: json['rewardCoins'] as int,
        rewardXp: json['rewardXp'] as int,
        delivered: json['delivered'] as bool? ?? false,
      );
}
