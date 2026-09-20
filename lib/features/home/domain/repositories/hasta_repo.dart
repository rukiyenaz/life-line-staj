import 'package:life_line/features/home/domain/entities/analizSonuclari.dart';
import 'package:life_line/features/home/domain/entities/hastaModel.dart';
import 'package:life_line/features/home/domain/entities/yapayZeka_bulgulari.dart';

abstract class HastaRepository {
  Future<List<HastaModel>> getAllHasta(String doctorId);
  Future<HastaModel?> getHastaById(String doctorId, String patientId);
  Future<void> addHasta(String doctorId, HastaModel hasta);
  Future<void> updateHasta(HastaModel hasta);
  Future<void> deleteHasta(String doctorId, String hastaId);
  Future<void> addAnalizSonucu(String doctorId, String hastaId, AnalizSonuclari analiz);
  Future<void> updateAnalizSonucu(String doctorId, String hastaId, AnalizSonuclari analiz);
  Future<void> deleteAnalizSonucu(String doctorId, String hastaId, String analizId);
  Future<void> addYapayZekaSonucu(String doctorId, String hastaId, YapayzekaBulgulari yapayZeka);
  Future<void> updateYapayZekaSonucu(String doctorId, String hastaId, YapayzekaBulgulari yapayZeka);
  Future<void> deleteYapayZekaSonucu(String doctorId, String hastaId, String yapayZekaId);
  Future<List<AnalizSonuclari>> getAnalizSonuclari(String doctorId, String hastaId);
  Future<List<YapayzekaBulgulari>> getYapayZekaSonucu(String doctorId, String hastaId);
}