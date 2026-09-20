import 'package:life_line/features/home/domain/entities/analizSonuclari.dart';
import 'package:life_line/features/home/domain/entities/yapayZeka_bulgulari.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class HastaModel {
  final String? id;
  final String name;
  final String surName;
  final int age;
  final bool cinsiyet;
  final String? hastaSikayeti;
  final String? hastalik;
  final String? tani;  
  final List<String>? kullandigiIlaclar;
  final AnalizSonuclari? analizSonuclari;
  final YapayzekaBulgulari? yapayzekaBulgulari;
  final DateTime? cihazTakmaGunu;
  final DateTime? cihazCikarmaGunu;
  final String? doctorId;
  final List<double>? ecgSamplePoints;

  HastaModel({
    this.id,
    required this.name,
    required this.surName,
    required this.age,
    required this.cinsiyet,
    this.hastaSikayeti,
    this.hastalik,
    this.tani,
    this.kullandigiIlaclar,
    this.analizSonuclari,
    this.yapayzekaBulgulari,
    this.cihazTakmaGunu,
    this.cihazCikarmaGunu,
    this.doctorId,
    this.ecgSamplePoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': '$name $surName'.trim(),
      'name': name, 
      'surName': surName, 
      'age': age,
      'cinsiyet': cinsiyet,
      'hastaSikayeti': hastaSikayeti,
      'hastalik': hastalik,
      'tani': tani,
      'medications': kullandigiIlaclar?.map((e) => {'name': e, 'dosage': '', 'purpose': ''}).toList() ?? [],
      'latest_analysis': {
        'ecg_intervals': {
          'pr_interval_ms': analizSonuclari?.PR_araligi ?? 0,
          'qrs_duration_ms': analizSonuclari?.QRS_suresi ?? 0,
          'qt_interval_ms': analizSonuclari?.QT_araligi ?? 0,
        },
        'mean_bpm': analizSonuclari?.kalp_hizi ?? 0,
        'ai_rhythm_prediction': yapayzekaBulgulari?.aritmi ?? '',
        'risk_score': int.tryParse(yapayzekaBulgulari?.kalp_krizi_riski ?? '0') ?? 0,
      },
      'cihazTakmaGunu': cihazTakmaGunu != null ? Timestamp.fromDate(cihazTakmaGunu!) : null,
      'cihazCikarmaGunu': cihazCikarmaGunu != null ? Timestamp.fromDate(cihazCikarmaGunu!) : null,
      'doctorId': doctorId,
      'ecg_sample_points': ecgSamplePoints,
    };
  }

  factory HastaModel.fromJson(Map<String, dynamic> json, String? id) {
    List<String> parsedIlaclar = [];
    if (json['medications'] != null && json['medications'] is List) {
      parsedIlaclar = (json['medications'] as List).map((e) => e is Map ? (e['name']?.toString() ?? '') : e.toString()).toList();
    } else {
      parsedIlaclar = List<String>.from(json['kullandigiIlaclar'] ?? []);
    }

    List<double>? parsedEcgPoints;
    if (json['ecg_sample_points'] != null && json['ecg_sample_points'] is List) {
      parsedEcgPoints = (json['ecg_sample_points'] as List).map((e) => (e as num).toDouble()).toList();
    }

    AnalizSonuclari? parsedAnaliz;
    YapayzekaBulgulari? parsedYapayZeka;

    if (json['latest_analysis'] != null) {
      var la = json['latest_analysis'];
      var intervals = la['ecg_intervals'] ?? {};
      parsedAnaliz = AnalizSonuclari.fromJson({
        'pr_interval_ms': intervals['pr_interval_ms'],
        'qrs_duration_ms': intervals['qrs_duration_ms'],
        'qt_interval_ms': intervals['qt_interval_ms'],
        'mean_bpm': la['mean_bpm'],
      });
      parsedYapayZeka = YapayzekaBulgulari.fromJson({
        'ai_rhythm_prediction': la['ai_rhythm_prediction'] ?? json['ritim_durumu'],
        'risk_score': la['risk_score'] ?? json['risk_skoru'],
      });
    } else {
      if (json['analizSonuclari'] != null) parsedAnaliz = AnalizSonuclari.fromJson(json['analizSonuclari']);
      if (json['yapayZekaBulgulari'] != null) parsedYapayZeka = YapayzekaBulgulari.fromJson(json['yapayZekaBulgulari']);
    }

    String parsedName = json['name'] ?? '';
    String parsedSurname = json['surName'] ?? '';
    if (json['full_name'] != null && json['full_name'].toString().isNotEmpty) {
      List<String> parts = json['full_name'].toString().split(' ');
      parsedName = parts.first;
      if (parts.length > 1) {
        parsedSurname = parts.skip(1).join(' ');
      }
    }

    DateTime? parsedTakmaGunu;
    if (json['cihazTakmaGunu'] != null) {
      if (json['cihazTakmaGunu'] is Timestamp) {
        parsedTakmaGunu = (json['cihazTakmaGunu'] as Timestamp).toDate();
      } else if (json['cihazTakmaGunu'] is String) {
        parsedTakmaGunu = DateTime.tryParse(json['cihazTakmaGunu']);
      }
    }

    DateTime? parsedCikarmaGunu;
    if (json['cihazCikarmaGunu'] != null) {
      if (json['cihazCikarmaGunu'] is Timestamp) {
        parsedCikarmaGunu = (json['cihazCikarmaGunu'] as Timestamp).toDate();
      } else if (json['cihazCikarmaGunu'] is String) {
        parsedCikarmaGunu = DateTime.tryParse(json['cihazCikarmaGunu']);
      }
    }

    return HastaModel(
      id: id ?? json['patient_id']?.toString(),
      name: parsedName,
      surName: parsedSurname,
      age: (json['age'] as num?)?.toInt() ?? 0,
      hastaSikayeti: json['hastaSikayeti'],
      hastalik: json['hastalik'] ?? json['patient_type'],
      tani: json['tani'],
      cinsiyet: _parseCinsiyet(json),
      kullandigiIlaclar: parsedIlaclar,
      analizSonuclari: parsedAnaliz,
      yapayzekaBulgulari: parsedYapayZeka,
      cihazTakmaGunu: parsedTakmaGunu,
      cihazCikarmaGunu: parsedCikarmaGunu,
      doctorId: json['doctorId'],
      ecgSamplePoints: parsedEcgPoints,
    );
  }

  static bool _parseCinsiyet(Map<String, dynamic> json) {
    if (json.containsKey('cinsiyet') && json['cinsiyet'] is bool) {
      return json['cinsiyet'] as bool;
    }
    if (json.containsKey('gender') && json['gender'] is bool) {
      return json['gender'] as bool;
    }
    if (json['cinsiyet'] == 'Kadın' || json['cinsiyet'] == 'Kadın ' || json['cinsiyet'] == 'Female') return true;
    if (json['cinsiyet'] == 'Erkek' || json['cinsiyet'] == 'Male') return false;
    //varsayılan kadın
    return true; 
  }
}