import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_line/features/home/domain/entities/hastaModel.dart';
import 'package:life_line/features/home/domain/repositories/hasta_repo.dart';
import 'package:life_line/features/home/presenatation/cubits/hasta_state.dart';

class HastaCubit extends Cubit<HastaState> {
  HastaRepository hastaRepository;
  HastaCubit(this.hastaRepository) : super(HastaInitial());
  final User user = FirebaseAuth.instance.currentUser!;
  String get doctorId => user.uid;


  Future<void> loadHastaList() async {
    emit(HastaLoading());
    try {
      final hastaList = await hastaRepository.getAllHasta(doctorId);
      emit(HastaLoaded(hastaList));
    } catch (e) {
      emit(HastaError('Hasta listesi yüklenemedi: $e'));
    }
  }

  void loadHastaDetail(HastaModel hasta) {
    emit(HastaLoading());
    try {
      final HastaModel?  hastaDetail = hastaRepository.getHastaById(doctorId, hasta.id ?? "") as HastaModel?;
      if (hastaDetail == null) {
        emit(HastaError('Hasta bulunamadı'));
        return;
      }else{
        emit(HastaDetailLoaded(hastaDetail));
      }
    } catch (e) {
      emit(HastaError('Hasta detayları yüklenemedi: $e'));
    }
  }

  Future<void> addHasta( HastaModel hasta) async {
    emit(HastaLoading());
    try {
      await hastaRepository.addHasta(doctorId, hasta);
      emit(HastaAdded(hasta));
    } catch (e) {
      emit(HastaError('Hasta eklenemedi: $e'));
    }
  }

  void updateHasta( HastaModel hasta) {
    emit(HastaLoading());
    try {
      final existingHasta = hastaRepository.getHastaById(doctorId, hasta.id ?? "");
      if (existingHasta == null) {
        emit(HastaError('Hasta bulunamadı'));
        return;
      }else {
        hastaRepository.updateHasta(hasta);
      }
      emit(HastaUpdated(hasta));
    } catch (e) {
      emit(HastaError('Hasta güncellenemedi: $e'));
    }
  }

  Future<void> deleteHasta(String hastaId) async {
    emit(HastaLoading());
    try {
      await hastaRepository.deleteHasta(doctorId, hastaId);
      emit(HastaDeleted(hastaId));
    } catch (e) {
      emit(HastaError('Hasta silinemedi: $e'));
    }
  }

  

  
}