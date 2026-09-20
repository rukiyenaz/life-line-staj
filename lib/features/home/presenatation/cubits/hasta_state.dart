import 'package:life_line/features/home/domain/entities/analizSonuclari.dart';
import 'package:life_line/features/home/domain/entities/hastaModel.dart';
import 'package:life_line/features/home/domain/entities/yapayZeka_bulgulari.dart';

abstract class HastaState {}
class HastaInitial extends HastaState {}
class HastaLoading extends HastaState {}
class HastaLoaded extends HastaState {
  final List<HastaModel> hastaList;

  HastaLoaded(this.hastaList);
}

class HastaDetailLoaded extends HastaState {
  final HastaModel? hasta;

  HastaDetailLoaded(this.hasta);
}

class HastaAdded extends HastaState {
  final HastaModel hasta;

  HastaAdded(this.hasta);
}

class HastaUpdated extends HastaState {
  final HastaModel hasta;

  HastaUpdated(this.hasta);
}

class HastaDeleted extends HastaState {
  final String message;

  HastaDeleted(this.message);
}
class HastaError extends HastaState {
  final String message;

  HastaError(this.message);
}

class HastaAnalizLoaded extends HastaState {
  final AnalizSonuclari analizSonuclari;

  HastaAnalizLoaded(this.analizSonuclari);
}



class HastaYapayZekaLoaded extends HastaState {
  final YapayzekaBulgulari yapayzekaBulgulari;

  HastaYapayZekaLoaded(this.yapayzekaBulgulari);
}

