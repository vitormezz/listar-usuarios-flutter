class User {
  final String id;
  final String nome;
  final String matricula;
  final String email;

  User({
    required this.id,
    required this.nome,
    required this.matricula,
    required this.email,
  });

  // Getters para compatibilidade com código otimizado
  String get name => nome;
  String get registration => matricula;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['matricula']?.toString() ?? '',
      nome: json['nome']?.toString().trim() ?? '',
      matricula: json['matricula']?.toString().trim() ?? '',
      email: json['email']?.toString().trim() ?? '${json['matricula']?.toString().trim() ?? ''}@example.com',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'matricula': matricula,
      'email': email,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && 
           other.id == id && 
           other.nome == nome && 
           other.matricula == matricula &&
           other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ nome.hashCode ^ matricula.hashCode ^ email.hashCode;

  @override
  String toString() => 'User(id: $id, nome: $nome, matricula: $matricula, email: $email)';
}
