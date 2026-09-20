import 'package:flutter_bloc/flutter_bloc.dart';

class IlacCubit extends Cubit<List<String>> {
  IlacCubit() : super([]);

  void ilacEkle(String ilac) {
    final yeniListe = List<String>.from(state);
    yeniListe.add(ilac);
    emit(yeniListe);
  }

  void ilacSil(String ilac) {
    final yeniListe = List<String>.from(state)..remove(ilac);
    emit(yeniListe);
  }

  List<String> get sonIlaclar {
    return state.toList();
  }

  void ilaclariTemizle() {
  emit([]);
}
}
