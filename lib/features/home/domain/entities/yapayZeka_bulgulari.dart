class YapayzekaBulgulari {
  final String? id;
  final String aritmi;
  final String kalp_krizi_riski;


  YapayzekaBulgulari({
    this.id,
    required this.aritmi,
    required this.kalp_krizi_riski,
  });

  Map<String, dynamic> toJson() {
    return {
      'ai_rhythm_prediction': aritmi,
      'risk_score': int.tryParse(kalp_krizi_riski) ?? 0,
    };
  }

  factory YapayzekaBulgulari.fromJson(Map<String, dynamic> json, [String? id]) {
    return YapayzekaBulgulari(
      id: id,
      aritmi: json['ai_rhythm_prediction'] ?? json['ritim_durumu'] ?? json['aritmi'] ?? '',
      kalp_krizi_riski: (json['risk_score'] ?? json['risk_skoru'] ?? json['kalp_krizi_riski'] ?? '').toString(),
    );
  }
}