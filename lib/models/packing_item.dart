class PackingItem {
  final String id;
  final String journeyId;
  final String name;
  final String category; // e.g., Clothes, Toiletries, Medicines, Tech
  final int quantity;
  final double weight; // per item weight in kg
  final bool checked;

  const PackingItem({
    required this.id,
    required this.journeyId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.weight,
    required this.checked,
  });

  double totalWeight() => quantity * weight;

  PackingItem copyWith({
    String? id,
    String? journeyId,
    String? name,
    String? category,
    int? quantity,
    double? weight,
    bool? checked,
  }) => PackingItem(
        id: id ?? this.id,
        journeyId: journeyId ?? this.journeyId,
        name: name ?? this.name,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        weight: weight ?? this.weight,
        checked: checked ?? this.checked,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'journeyId': journeyId,
        'name': name,
        'category': category,
        'quantity': quantity,
        'weight': weight,
        'checked': checked,
      };

  factory PackingItem.fromMap(Map<String, dynamic> map) => PackingItem(
        id: map['id'] as String,
        journeyId: map['journeyId'] as String,
        name: map['name'] as String,
        category: map['category'] as String,
        quantity: map['quantity'] as int,
        weight: (map['weight'] as num).toDouble(),
        checked: map['checked'] as bool,
      );
}
