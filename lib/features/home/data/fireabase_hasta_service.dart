import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_line/features/home/domain/entities/analizSonuclari.dart';
import 'package:life_line/features/home/domain/entities/hastaModel.dart';
import 'package:life_line/features/home/domain/entities/yapayZeka_bulgulari.dart';
import 'package:life_line/features/home/domain/repositories/hasta_repo.dart';

class FirebaseHastaService implements HastaRepository{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> addHasta(String doctorId, HastaModel hasta) async {
   try {
    final data = hasta.toJson();
    data['doctorId'] = doctorId;
    
    DocumentReference docRef;
    if (hasta.id != null && hasta.id!.isNotEmpty) {
      docRef = firestore.collection('patients').doc(hasta.id);
      await docRef.set(data);
    } else {
      docRef = await firestore.collection('patients').add(data);
    }

  } catch (e) {
    throw Exception('Hasta eklenemedi: $e');
  }
  }

  @override
  Future<void> deleteHasta(String doctorId, String hastaId) async {
    try {
      await firestore.collection('patients').doc(hastaId).delete();
    } catch (e) {
      throw Exception('Hasta silinemedi: $e');
    }
  }

  @override
  Future<List<HastaModel>> getAllHasta(String doctorId) async {
    try {
      final snapshot = await firestore.collection('patients').where('doctorId', isEqualTo: doctorId).get();
      return snapshot.docs.map((doc) => HastaModel.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Future<HastaModel?> getHastaById(String doctorId, String patientId) async {
    try{
        final patientDoc = await firestore
          .collection('patients')
          .doc(patientId)
          .get();

      if (!patientDoc.exists) return null;
      final patientData = patientDoc.data()!;

      return HastaModel.fromJson(patientData, patientDoc.id);
    } catch (e) {
      debugPrint('Hasta bulunamadı: $e');
      return null;
    }
  }
  

  @override
  Future<void> updateHasta(HastaModel hasta) async {
    try {
      await firestore.collection('patients').doc(hasta.id).update(hasta.toJson());
    } catch (e) {
      throw Exception('Hasta güncellenemedi: $e');
    }
  }
  
  @override
  Future<void> addAnalizSonucu(String doctorId, String hastaId, AnalizSonuclari analiz) async {
    try {
      await firestore.collection('patients').doc(hastaId).collection('analizSonuclari').add(analiz.toJson());
    } catch (e) {
      throw Exception('Analiz sonucu eklenemedi: $e');
    }
  }
  
  @override
  Future<void> addYapayZekaSonucu(String doctorId, String hastaId, YapayzekaBulgulari yapayZeka) async {
    try {
      await firestore.collection('patients').doc(hastaId).collection('yapayZeka_bulgulari').add(yapayZeka.toJson());
    } catch (e) {
      throw Exception('Yapay zeka sonucu eklenemedi: $e');
    }
  }

  @override
  Future<void> deleteAnalizSonucu(String doctorId, String hastaId, String analizId) async {
    try {
      await firestore.collection('patients').doc(hastaId).collection('analizSonuclari').doc(analizId).delete();
    } catch (e) {
      throw Exception('Analiz sonucu silinemedi: $e');
    }
  }

  @override
  Future<void> deleteYapayZekaSonucu(String doctorId, String hastaId, String yapayZekaId) async {
    try {
      await firestore.collection('patients').doc(hastaId).collection('yapayZeka_bulgulari').doc(yapayZekaId).delete();
    } catch (e) {
      throw Exception('Yapay zeka sonucu silinemedi: $e');
    }
  }
  

  @override
  Future<List<AnalizSonuclari>> getAnalizSonuclari(String doctorId, String hastaId) async{
    try {
      final snapshot = await firestore.collection('patients').doc(hastaId).collection('analizSonuclari').get();
      return snapshot.docs.map((doc) => AnalizSonuclari.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Analiz sonuçları getirilemedi: $e');
    }
  }
  
  @override
  Future<List<YapayzekaBulgulari>> getYapayZekaSonucu(String doctorId, String hastaId) async{
    try {
      final snapshot = await firestore.collection('patients').doc(hastaId).collection('yapayZeka_bulgulari').get();
      return snapshot.docs.map((doc) => YapayzekaBulgulari.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Yapay zeka sonuçları getirilemedi: $e');
    }
  }

  
  @override
  Future<void> updateAnalizSonucu(String doctorId, String hastaId, AnalizSonuclari analiz) async {
    try {
      await firestore.collection('patients').doc(hastaId).collection('analizSonuclari').doc(analiz.id).update(analiz.toJson());
    } catch (e) {
      throw Exception('Analiz sonucu güncellenemedi: $e');
    }
  }
  
  
  @override
  Future<void> updateYapayZekaSonucu(String doctorId, String hastaId, YapayzekaBulgulari yapayZeka) async {
    try {
      await firestore.collection('patients').doc(hastaId).collection('yapayZeka_bulgulari').doc(yapayZeka.id).update(yapayZeka.toJson());
    } catch (e) {
      throw Exception('Yapay zeka sonucu güncellenemedi: $e');
    }
  }

}