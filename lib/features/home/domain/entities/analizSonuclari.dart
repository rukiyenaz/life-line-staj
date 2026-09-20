class AnalizSonuclari {
  final String? id;
  final int PR_araligi;
  final int QRS_suresi;
  final int QT_araligi;
  final int kalp_hizi;

  AnalizSonuclari({
     this.id,
    required this.PR_araligi,
    required this.QRS_suresi,
    required this.QT_araligi,
    required this.kalp_hizi,
  });

  Map<String, dynamic> toJson() {
    return {
      'pr_interval_ms': PR_araligi,
      'qrs_duration_ms': QRS_suresi,
      'qt_interval_ms': QT_araligi,
      'mean_bpm': kalp_hizi,
    };
  }

  factory AnalizSonuclari.fromJson(Map<String, dynamic> json, [String? id]) {
    return AnalizSonuclari(
      id: id,
      PR_araligi: (json['pr_interval_ms'] ?? json['PR_araligi'] as num?)?.toInt() ?? 0,
      QRS_suresi: (json['qrs_duration_ms'] ?? json['QRS_suresi'] as num?)?.toInt() ?? 0,
      QT_araligi: (json['qt_interval_ms'] ?? json['QT_araligi'] as num?)?.toInt() ?? 0,
      kalp_hizi: (json['mean_bpm'] ?? json['kalp_hizi'] as num?)?.toInt() ?? 0,
    );
  }


}