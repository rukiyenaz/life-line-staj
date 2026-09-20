class DoctorUser {
  final String? id;
  final String email;
  final String ad;
  final List<String>? hastaKayitlar; 

  DoctorUser({
    this.id,
    required this.email,
    required this.ad,
    this.hastaKayitlar,
  });


  @override
  String toString() {
    return 'User(id: $id, email: $email, ad: $ad)';
  } 

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'ad': ad,
      'hastaKayitlar': hastaKayitlar ?? [],
    };
  }

  factory DoctorUser.fromJson(Map<String, dynamic> json, [String? docId]) {
    return DoctorUser(
      id: docId ?? json['id'],
      email: json['email'],
      ad: json['ad'],
      hastaKayitlar: List<String>.from(json['hastaKayitlar'] ?? []),
    );
  }
}