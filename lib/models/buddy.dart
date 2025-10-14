class Buddy {
  final String id;
  final String name;
  final String email;

  const Buddy({
    required this.id,
    required this.name,
    required this.email,
  });

  Buddy copyWith({String? id, String? name, String? email}) => Buddy(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
      };

  factory Buddy.fromMap(Map<String, dynamic> map) => Buddy(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
      );
}
